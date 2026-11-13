import Foundation

/// Incremental decoder for `text/event-stream` byte streams.
///
/// Handles `\n`, `\r\n` and `\r` line endings, strips an optional leading
/// UTF-8 byte-order mark, ignores `:` keepalive comments, and bounds buffered
/// line and event sizes.
public struct SSEDecoder: Sendable {
    public let maxBufferBytes: Int

    private var lineBytes: [UInt8] = []
    private var leadingBytes: [UInt8] = []
    private var checkedBOM = false
    private var previousWasCarriageReturn = false

    private var eventType: String?
    private var dataLines: [String] = []
    private var dataByteCount = 0
    private var lastEventID: String?
    private var pendingRetryMilliseconds: Int?

    public init(maxBufferBytes: Int = 65_536) {
        self.maxBufferBytes = maxBufferBytes
    }

    /// Feeds one byte and returns a completed event when an empty line ends a
    /// non-empty block.
    public mutating func feed(_ byte: UInt8) throws -> SSEEvent? {
        if !checkedBOM {
            leadingBytes.append(byte)
            let bom: [UInt8] = [0xEF, 0xBB, 0xBF]
            if bom.starts(with: leadingBytes) {
                if leadingBytes.count == bom.count {
                    leadingBytes.removeAll(keepingCapacity: true)
                    checkedBOM = true
                }
                return nil
            }
            checkedBOM = true
            let buffered = leadingBytes
            leadingBytes.removeAll(keepingCapacity: false)
            var emitted: SSEEvent?
            for item in buffered {
                if let event = try processByte(item) {
                    emitted = event
                }
            }
            return emitted
        }
        return try processByte(byte)
    }

    /// Feeds a sequence of bytes and returns every completed event in order.
    public mutating func feed<S: Sequence>(_ bytes: S) throws -> [SSEEvent] where S.Element == UInt8 {
        var events: [SSEEvent] = []
        for byte in bytes {
            if let event = try feed(byte) {
                events.append(event)
            }
        }
        return events
    }

    private mutating func processByte(_ byte: UInt8) throws -> SSEEvent? {
        if previousWasCarriageReturn {
            previousWasCarriageReturn = false
            if byte == 0x0A {
                return nil
            }
        }

        if byte == 0x0D {
            previousWasCarriageReturn = true
            return try consumeCurrentLine()
        }
        if byte == 0x0A {
            return try consumeCurrentLine()
        }

        guard lineBytes.count < maxBufferBytes else {
            throw SSEDecoderError.bufferLimitExceeded
        }
        lineBytes.append(byte)
        return nil
    }

    private mutating func consumeCurrentLine() throws -> SSEEvent? {
        if lineBytes.isEmpty {
            return dispatchBlock()
        }
        let line = String(decoding: lineBytes, as: UTF8.self)
        lineBytes.removeAll(keepingCapacity: true)
        try processLine(line)
        return nil
    }

    private mutating func processLine(_ line: String) throws {
        if line.hasPrefix(":") {
            return
        }

        let field: Substring
        let rawValue: Substring
        if let colon = line.firstIndex(of: ":") {
            field = line[..<colon]
            let afterColon = line.index(after: colon)
            if afterColon < line.endIndex, line[afterColon] == " " {
                rawValue = line[line.index(after: afterColon)...]
            } else {
                rawValue = line[afterColon...]
            }
        } else {
            field = line[...]
            rawValue = ""
        }

        switch field {
        case "data":
            let nextCount = dataByteCount + rawValue.utf8.count + (dataLines.isEmpty ? 0 : 1)
            guard nextCount <= maxBufferBytes else {
                throw SSEDecoderError.bufferLimitExceeded
            }
            dataByteCount = nextCount
            dataLines.append(String(rawValue))
        case "event":
            eventType = String(rawValue)
        case "id":
            if !rawValue.contains("\0") {
                lastEventID = String(rawValue)
            }
        case "retry":
            if !rawValue.isEmpty, rawValue.utf8.allSatisfy({ $0 >= 0x30 && $0 <= 0x39 }),
                let milliseconds = Int(rawValue)
            {
                pendingRetryMilliseconds = milliseconds
            }
        default:
            break
        }
    }

    private mutating func dispatchBlock() -> SSEEvent? {
        let hasData = !dataLines.isEmpty
        let retry = pendingRetryMilliseconds
        defer {
            eventType = nil
            dataLines.removeAll(keepingCapacity: true)
            dataByteCount = 0
            pendingRetryMilliseconds = nil
        }
        guard hasData || retry != nil else {
            return nil
        }
        return SSEEvent(
            event: eventType,
            data: hasData ? dataLines.joined(separator: "\n") : nil,
            id: lastEventID,
            retryMilliseconds: retry
        )
    }
}
