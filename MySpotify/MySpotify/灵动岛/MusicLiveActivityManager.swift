import Foundation
import ActivityKit

@available(iOS 16.1, *)
@MainActor
@objc public class MusicLiveActivityManager: NSObject {

    private var activity: Activity<MusicAttributes>?

    /// 开始灵动岛
    @objc public func start(songName: String,
                            artistName: String,
                            albumArtURL: String) {

        let attr = MusicAttributes(songName: songName,
                                   artistName: artistName,
                                   albumArtURL: albumArtURL)

        let state = MusicAttributes.ContentState(isPlaying: true,
                                                 progress: 0)

        do {
            // iOS 16.2+ 新 API
            activity = try Activity.request(
                attributes: attr,
                content: .init(state: state, staleDate: nil)
            )
            print("✅ Live Activity 启动成功")
        } catch {
            print("❌ Live Activity 启动失败: \(error)")
        }
    }

    /// 更新状态
    @objc public func update(isPlaying: Bool, progress: Double) {
        Task { @MainActor in
            guard let activity else { return }
            await activity.update(
                ActivityContent(
                    state: MusicAttributes.ContentState(
                        isPlaying: isPlaying,
                        progress: progress
                    ),
                    staleDate: nil
                )
            )
        }
    }

    /// 关闭灵动岛
    @objc public func stop() {
        Task { @MainActor in
            guard let activity else { return }

            // ✅ iOS 16.2+ 新 API
            await activity.end(
                ActivityContent(
                    state: MusicAttributes.ContentState(
                        isPlaying: false,
                        progress: 1.0
                    ),
                    staleDate: nil
                ),
                dismissalPolicy: .immediate
            )

            self.activity = nil
        }
    }
}
