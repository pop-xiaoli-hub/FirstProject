//
//  MusicSlider.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/3/5.
//

#import "MusicSlider.h"

@implementation MusicSlider

- (instancetype)init {
  if (self = [super init]) {
    _trackHeight = 4;
  }
  return self;
}

- (CGRect)trackRectForBounds:(CGRect)bounds {
  return CGRectMake(bounds.origin.x, bounds.size.height / 2 - self.trackHeight / 2, bounds.size.width, self.trackHeight);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
