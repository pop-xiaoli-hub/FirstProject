//
//  PlayerController.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/24.
//

#import "LZPlayerController.h"
#import <AVFoundation/AVFoundation.h>
#import "LZStreamingURLBuilder.h"
#import "LZResourceLoader.h"

@interface LZPlayerController ()
@property AVPlayer *player;
@property LZResourceLoader *loader;
@end

@implementation LZPlayerController

+(instancetype)sharedPlayer {
  NSLog(@"当前执行：%s",__func__);
  static LZPlayerController* playerManager;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    playerManager = [[LZPlayerController alloc] init];
    playerManager.loader = [[LZResourceLoader alloc] init];
  });
  return playerManager;
}

- (void)playWithURL:(NSURL *)url {
  NSLog(@"当前执行：%s",__func__);
  NSURL *streamURL = [LZStreamingURLBuilder buildStreamingURL:url];
  AVURLAsset *asset = [AVURLAsset URLAssetWithURL:streamURL options:nil];
  // self.loader = [LZResourceLoader new];
  [asset.resourceLoader setDelegate:self.loader queue:dispatch_queue_create("loader.queue", DISPATCH_QUEUE_SERIAL)];
  AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
  self.player = [AVPlayer playerWithPlayerItem:item];
  [self.player play];
}

@end
