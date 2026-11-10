/// Who wrote a post: an X account by handle, or a Bilibili account, which the
/// app names by its platform rather than its numeric mid.
enum PostAccount: Equatable {
    case x(handle: String)
    case bilibili
    /// An X post whose handle the API did not name.
    case unnamedX

    init(source: String, handle: String?) {
        if source == "bilibili" {
            self = .bilibili
        } else if let handle, handle.isEmpty == false {
            self = .x(handle: handle.hasPrefix("@") ? String(handle.dropFirst()) : handle)
        } else {
            self = .unnamedX
        }
    }
}
