import Foundation

/// Time rules for the Now tab. Japan-time text comes from `JSTTimeFormat`
/// in `KanoNaviComponents`.
enum NowTimeFormat {
    /// Whether a countdown to `date` reads better as a running timer than as
    /// a relative phrase such as "in 3 days".
    static func usesTimer(until date: Date, now: Date) -> Bool {
        date.timeIntervalSince(now) < 24 * 60 * 60
    }
}
