//
//  LZIdleTaskQueue.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/3/6.
//

#import "LZIdleTaskQueue.h"

@implementation LZIdleTaskQueue {
  CFRunLoopObserverRef _observer;
  NSMutableArray<IdleTask>* _tasks;
  BOOL _started;
}

- (instancetype)init {
  if (self = [super init]) {
    _tasks = [NSMutableArray array];
  }
  return self;
}

- (void)addTask:(IdleTask)task {
  if (task) {
    [_tasks addObject:[task copy]];
  }
}

static void RunLoopIdleCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
  LZIdleTaskQueue *queue = (__bridge LZIdleTaskQueue *)info;
  NSInteger burst = 3;    // 控制单次处理任务数，避免长时间占用
  while (burst-- > 0 && queue->_tasks.count > 0) {
    IdleTask t = queue->_tasks.firstObject;
    [queue->_tasks removeObjectAtIndex:0];
    t();
  }
}

- (void)start {
  if (_started) {
    _started = YES;
  }
  CFRunLoopObserverContext ctx = {0, (__bridge  void*)self, NULL, NULL, NULL};
  _observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopBeforeWaiting, true, INT_MAX, RunLoopIdleCallback, &ctx);
  CFRunLoopAddObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
}

- (void)stop {
  if (!_started) {
    return;
  }
  _started = NO;
  if (_observer) {
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
    CFRelease(_observer);
    _observer = nil;
  }
  [_tasks removeAllObjects];
}
@end
