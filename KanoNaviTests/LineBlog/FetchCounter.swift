/// Counts the fetches a stubbed image loader was asked for.
actor FetchCounter {
    private(set) var count = 0

    func increment() {
        count += 1
    }
}
