import ActivityKit
import Foundation

@available(iOS 16.1, *)
public struct MusicAttributes: ActivityAttributes {

    public struct ContentState: Codable, Hashable {
        public var isPlaying: Bool
        public var progress: Double   // 0.0 ~ 1.0
    }

    public var songName: String
    public var artistName: String
    public var albumArtURL: String
}
