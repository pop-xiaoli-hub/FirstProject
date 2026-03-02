//
//  MySpotifyWidgetExtensionBundle.swift
//  MySpotifyWidgetExtension
//
//  Created by xiaoli pop on 2026/2/22.
//

import WidgetKit
import SwiftUI

@main
struct MySpotifyWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        MySpotifyWidgetExtension()
        MySpotifyWidgetExtensionControl()
        MySpotifyWidgetExtensionLiveActivity()
    }
}
