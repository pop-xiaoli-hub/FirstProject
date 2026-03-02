//
//  MySpotifyWidgetExtensionLiveActivity.swift
//  MySpotifyWidgetExtension
//
//  Created by xiaoli pop on 2026/2/22.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MySpotifyWidgetExtensionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct MySpotifyWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MySpotifyWidgetExtensionAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension MySpotifyWidgetExtensionAttributes {
    fileprivate static var preview: MySpotifyWidgetExtensionAttributes {
        MySpotifyWidgetExtensionAttributes(name: "World")
    }
}

extension MySpotifyWidgetExtensionAttributes.ContentState {
    fileprivate static var smiley: MySpotifyWidgetExtensionAttributes.ContentState {
        MySpotifyWidgetExtensionAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: MySpotifyWidgetExtensionAttributes.ContentState {
         MySpotifyWidgetExtensionAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: MySpotifyWidgetExtensionAttributes.preview) {
   MySpotifyWidgetExtensionLiveActivity()
} contentStates: {
    MySpotifyWidgetExtensionAttributes.ContentState.smiley
    MySpotifyWidgetExtensionAttributes.ContentState.starEyes
}
