import Foundation

/// Running text of an article: text, links and pictographs in reading order,
/// ready to be drawn as one piece of text.
nonisolated struct LineBlogRichText: Hashable, Sendable {
    /// Neighbouring text with the same link is one run.
    private(set) var runs: [LineBlogTextRun] = []

    init(runs: [LineBlogTextRun] = []) {
        for run in runs {
            append(run)
        }
    }

    /// Adds a run, joining text to the text before it when both have the
    /// same link. Empty text is dropped.
    mutating func append(_ run: LineBlogTextRun) {
        guard case .text(let text, let link) = run else {
            runs.append(run)
            return
        }
        guard text.isEmpty == false else { return }
        if case .text(let previous, link)? = runs.last {
            runs[runs.count - 1] = .text(previous + text, link: link)
        } else {
            runs.append(run)
        }
    }

    /// Whether there is nothing to read: no pictograph, and no text other
    /// than spaces and line breaks.
    var isBlank: Bool {
        runs.allSatisfy { run in
            if case .text(let text, _) = run {
                return text.allSatisfy { $0.isWhitespace }
            }
            return false
        }
    }

    /// The text alone, with each pictograph as its `alt` when it has one.
    var plainText: String {
        runs.reduce(into: "") { result, run in
            switch run {
            case .text(let text, _): result += text
            case .pictograph(let pictograph, _): result += pictograph.alt ?? ""
            }
        }
    }

    /// The pictographs' files, in reading order.
    var pictographSources: [MediaImageSource] {
        runs.compactMap { run in
            if case .pictograph(let pictograph, _) = run { pictograph.source } else { nil }
        }
    }

    /// This text without the spaces and line breaks at its two ends, which
    /// the blog's markup leaves around pictures.
    func trimmed() -> LineBlogRichText {
        var runs = runs
        if case .text(let text, let link)? = runs.first {
            runs[0] = .text(String(text.drop(while: Self.isEdgeSpace)), link: link)
        }
        if case .text(let text, let link)? = runs.last {
            let kept = text.reversed().drop(while: Self.isEdgeSpace).reversed()
            runs[runs.count - 1] = .text(String(kept), link: link)
        }
        return LineBlogRichText(runs: runs)
    }

    /// Line breaks and plain spaces; a full-width space is an indent the
    /// writer chose and stays.
    private static func isEdgeSpace(_ character: Character) -> Bool {
        character.isNewline || character == " " || character == "\t"
    }
}
