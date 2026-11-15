import Foundation

/// The web addresses About links to.
enum AboutLinks {
    /// The Kano Navi web board.
    static let webBoard = URL(string: "https://kano.yexca.net")
    /// The app's source repository, `kano-navi-apple`.
    static let appRepository = URL(string: "https://github.com/yexca/kano-navi-apple")
    /// The app's license text, GNU AGPL v3.0, in its repository.
    static let appLicense = URL(string: "https://github.com/yexca/kano-navi-apple/blob/main/LICENSE")
    /// The service's source repository, `kano-navi`.
    static let serviceRepository = URL(string: "https://github.com/yexca/kano-navi")
}
