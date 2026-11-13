/// A video the coordinator can stop when another one starts.
protocol LineBlogVideoPlayer: AnyObject {
    /// Pauses the video, or withdraws it while its file is still opening.
    func pause()
}
