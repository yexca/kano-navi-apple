import KanoNaviCore
import SwiftUI

/// The toolbar menu that jumps to a month of the article list: one submenu
/// per year, newest first, each month with its number of articles.
struct LineBlogMonthMenu: View {
    let years: [LineBlogIndexListing.Year]
    let jump: (LineBlogIndexListing.Month) -> Void

    @Environment(\.locale) private var locale

    var body: some View {
        Menu {
            ForEach(years) { year in
                Menu {
                    ForEach(year.months) { month in
                        Button {
                            jump(month)
                        } label: {
                            Text(.LineBlog.titleWithCount(month.key.title(locale: locale), month.posts.count))
                        }
                    }
                } label: {
                    Text(.LineBlog.titleWithCount(yearTitle(year), year.total))
                }
            }
        } label: {
            Label {
                Text(.LineBlog.monthMenu)
            } icon: {
                Image(systemName: "calendar")
            }
        }
    }

    /// The year as the interface language writes it, such as "2019" or
    /// "2019年".
    private func yearTitle(_ year: LineBlogIndexListing.Year) -> String {
        guard let first = year.months.first?.key.first, let instant = JapanTime.startOfDay(first) else {
            return String(year.year)
        }
        return instant.formatted(
            Date.FormatStyle(
                date: .omitted, time: .omitted, locale: locale, calendar: Calendar(identifier: .gregorian),
                timeZone: JapanDate.timeZone
            ).year())
    }
}
