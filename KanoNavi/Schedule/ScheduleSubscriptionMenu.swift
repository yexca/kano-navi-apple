import Foundation
import SwiftUI

/// The toolbar menu for the calendar subscription: subscribe in the Calendar
/// app through the `webcal://` link, or share the HTTPS link.
struct ScheduleSubscriptionMenu: View {
    let feedURL: URL

    @Environment(\.locale) private var locale
    @Environment(\.openURL) private var openURL

    var body: some View {
        Menu(.Schedule.subscriptionMenu, systemImage: "calendar.badge.plus") {
            if let webcal = CalendarSubscription.webcalURL(from: feedURL, interfaceLocale: locale) {
                Button(.Schedule.subscribe, systemImage: "calendar.badge.plus") {
                    openURL(webcal)
                }
            }
            if let link = CalendarSubscription.feedURL(from: feedURL, interfaceLocale: locale) {
                ShareLink(item: link) {
                    Label(.Schedule.shareSubscription, systemImage: "square.and.arrow.up")
                }
            }
        }
    }
}
