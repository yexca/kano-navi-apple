import Foundation
import Testing

@testable import KanoNaviCore

struct SSEDecoderTests {
    @Test func decodesInitialRetryAndRevisionEvent() throws {
        var decoder = SSEDecoder()
        let stream = "retry: 5000\ndata: 42\n\n: keepalive\n\ndata: 43\n\n"
        let events = try decoder.feed(Array(stream.utf8))

        #expect(
            events == [
                SSEEvent(event: nil, data: "42", id: nil, retryMilliseconds: 5000),
                SSEEvent(event: nil, data: "43", id: nil, retryMilliseconds: nil),
            ]
        )
    }

    @Test func handlesCRLFAndBareCRAndLeadingBOM() throws {
        var decoder = SSEDecoder()
        var bytes: [UInt8] = [0xEF, 0xBB, 0xBF]
        bytes.append(contentsOf: "data: 10\r\n\rdata: 11\r\r".utf8)

        let events = try decoder.feed(bytes)
        #expect(
            events == [
                SSEEvent(data: "10"),
                SSEEvent(data: "11"),
            ]
        )
    }

    @Test func decodesSplitMultiByteUTF8ByteByByte() throws {
        var decoder = SSEDecoder()
        let payload = "event: message\nid: rev-9\ndata: 鹿乃まほろ\ndata: line2\n\n"
        var emitted: [SSEEvent] = []
        for byte in payload.utf8 {
            if let event = try decoder.feed(byte) {
                emitted.append(event)
            }
        }

        #expect(
            emitted == [
                SSEEvent(event: "message", data: "鹿乃まほろ\nline2", id: "rev-9", retryMilliseconds: nil)
            ]
        )
    }

    @Test func rejectsOversizedLine() throws {
        var decoder = SSEDecoder(maxBufferBytes: 16)
        let oversized = Array("data: 01234567890123456789\n\n".utf8)

        #expect(throws: SSEDecoderError.bufferLimitExceeded) {
            _ = try decoder.feed(oversized)
        }
    }
}
