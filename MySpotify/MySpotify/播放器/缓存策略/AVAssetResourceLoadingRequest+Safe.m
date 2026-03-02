//
//  AVAssetResourceLoadingRequest+Safe.m
//  GCD
//
//  Created by xiaoli pop on 2026/2/26.
//

#import "AVAssetResourceLoadingRequest+Safe.h"
#import <objc/runtime.h>

static const void *kLZFinishedKey = &kLZFinishedKey;

@implementation AVAssetResourceLoadingRequest (Safe)

- (void)setLz_finished:(BOOL)val {
    objc_setAssociatedObject(self, kLZFinishedKey, @(val), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)lz_finished {
    return [objc_getAssociatedObject(self, kLZFinishedKey) boolValue];
}

@end
