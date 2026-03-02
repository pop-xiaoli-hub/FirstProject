import WidgetKit
import SwiftUI
import ActivityKit

@available(iOS 16.1, *)
struct MySpotifyWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MusicAttributes.self) { context in

            // 🔒 锁屏界面
            VStack(alignment: .leading) {
                HStack {
                    AsyncImage(url: URL(string: context.attributes.albumArtURL)) { img in
                        img.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)

                    VStack(alignment: .leading) {
                        Text(context.attributes.songName)
                            .font(.headline)
                        Text(context.attributes.artistName)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                ProgressView(value: context.state.progress)
            }
            .padding()

        } dynamicIsland: { context in

            DynamicIsland {

                // 展开状态
                DynamicIslandExpandedRegion(.leading) {
                    AsyncImage(url: URL(string: context.attributes.albumArtURL)) { img in
                        img.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 40, height: 40)
                    .cornerRadius(6)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Image(systemName: context.state.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                }

                DynamicIslandExpandedRegion(.center) {
                    VStack {
                        Text(context.attributes.songName)
                            .font(.headline)
                            .lineLimit(1)
                        Text(context.attributes.artistName)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: context.state.progress)
                }

            } compactLeading: {
                Image(systemName: "music.note")
            } compactTrailing: {
                Image(systemName: context.state.isPlaying ? "pause.fill" : "play.fill")
            } minimal: {
                Image(systemName: "music.note")
            }
        }
    }
}
