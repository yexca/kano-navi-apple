import SwiftUI

/// The time left until `date`: a running timer within a day, else a phrase
/// such as "in 3 days".
struct NowCountdown: View {
    let date: Date
    let now: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(.Now.startsIn)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Group {
                if NowTimeFormat.usesTimer(until: date, now: now) {
                    Text(timerInterval: now...date, countsDown: true)
                } else {
                    Text(date, format: .relative(presentation: .named))
                }
            }
            .font(.title2.weight(.semibold))
            .monospacedDigit()
        }
        .accessibilityElement(children: .combine)
    }
}
