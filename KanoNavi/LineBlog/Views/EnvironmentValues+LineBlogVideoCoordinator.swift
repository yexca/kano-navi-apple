import SwiftUI

extension EnvironmentValues {
    /// The coordinator the reader's videos report to: the app's shared one
    /// unless a test or preview sets another.
    @Entry var lineBlogVideoCoordinator: LineBlogVideoCoordinator = .shared
}
