/// A screen the Works screen opens. `WorksView` registers them; the list
/// screens push them.
enum WorksDestination: Hashable {
    /// The personal releases by year.
    case releases
    /// One personal release, by release ID.
    case release(String)
    /// The works Kano took part in.
    case participation
    /// One participation work, by its ID.
    case participationWork(String)
    /// The uploads.
    case uploads
}
