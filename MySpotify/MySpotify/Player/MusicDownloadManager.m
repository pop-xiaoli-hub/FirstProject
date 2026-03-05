//
//  MusicDownloadManager.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/30.
//

#import "MusicDownloadManager.h"
#import <objc/runtime.h>

@interface MusicDownloadManager()<NSURLSessionDelegate, NSURLSessionDownloadDelegate, NSURLSessionTaskDelegate>
@property (nonatomic, strong)NSURLSession* session;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSURLSessionDownloadTask *> *downloadTasks;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSData *> *resumeDataMap;
@end

static MusicDownloadManager* manager = nil;
@implementation MusicDownloadManager
+ (instancetype)sharedManager {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    manager = [[MusicDownloadManager alloc] init];
    manager.resumeDataMap = [NSMutableDictionary dictionary];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];//获取一个默认的网络会话配置
    /*
     这个session是负责会话的工厂、任务的调度中心、网络回调的分发中心，在这里将所有的网络事件交给manager来处理
     */
    manager.session = [NSURLSession sessionWithConfiguration:config delegate:manager delegateQueue:[[NSOperationQueue alloc] init]];//所有delegate的回调都在主线程操作，默认是在后台线程
    manager.downloadTasks = [NSMutableDictionary dictionary];
  });
  return manager;
}

- (void)pauseDownloadForURL:(NSURL *)url {
  NSString* key = url.absoluteString;
  NSURLSessionDownloadTask *task = self.downloadTasks[key];
  if (!task) {
    return;
  }
  [task cancelByProducingResumeData:^(NSData *resumeData) {
    if (resumeData) {
      self.resumeDataMap[key] = resumeData;
    }
    [self.downloadTasks removeObjectForKey:key];
  }];
}

//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
//
//  if (!error) return;
//
//  NSData *resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
//
//
//  if (resumeData) {
//    NSString *key = task.originalRequest.URL.absoluteString;
//    self.resumeDataMap[key] = resumeData;
//  }
//
//  void(^completionBlock)(NSURL *, NSError *) =
//  objc_getAssociatedObject(task, "completionBlock");
//
//  if (completionBlock) {
//    completionBlock(nil, error);
//  }
//}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {

  if (!error) {
    return;
  }

  NSString *key = task.originalRequest.URL.absoluteString;

  NSData *resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];

  if (!self.resumeDataMap[key] && resumeData) {
    self.resumeDataMap[key] = resumeData;
  }

  void(^completionBlock)(NSURL *, NSError *) = objc_getAssociatedObject(task, "completionBlock");

  if (completionBlock) {
    completionBlock(nil, error);
  }
}



- (void)downloadSongWithURL:(NSURL *)url progress:(void(^)(float))progressBlock completion:(void(^)(NSURL *, NSError *))completionBlock {
  // 检查文件是否已存在
  NSString* key = url.absoluteString;
  NSString *fileName = url.lastPathComponent;
  NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:fileName];
  if ([[NSFileManager defaultManager] fileExistsAtPath:docPath]) {
    NSLog(@"歌曲已经下载完成");
    if (completionBlock) {
      completionBlock([NSURL fileURLWithPath:docPath], nil);
    }
    return;
  }

  NSURLSessionDownloadTask *task = nil;
  NSData *resumeData = self.resumeDataMap[key];

  if (resumeData) {
    //从断点继续
    task = [self.session downloadTaskWithResumeData:resumeData];
    [self.resumeDataMap removeObjectForKey:key];
  } else {
    //全新下载
    task = [self.session downloadTaskWithURL:url];
  }
  /*
   这一步在系统内部会先创建请求，然后包装任务，设置状态位还未执行
   CFNetwork是apple写的网络引擎，直接与内核socket、文件系统、TCP/IP相关联
   */

  // 保存回调
  objc_setAssociatedObject(task, "progressBlock", progressBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
  objc_setAssociatedObject(task, "completionBlock", completionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);

  // 开始下载
  [task resume];
  /*
   DNS解析域名，找到IP，创建socket
   */

  // 保存 task
  self.downloadTasks[key] = task;
}


- (void)cancelDownloadForURL:(NSURL *)url {
  NSString* key = url.absoluteString;
  NSURLSessionDownloadTask *task = self.downloadTasks[key];
  if (task) {
    [task cancel];
    [self.downloadTasks removeObjectForKey:key];
    [self.resumeDataMap removeObjectForKey:key];
  }
}

#pragma mark - NSURLSessionDownloadDelegate

// 下载进度
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
  NSLog(@"正在下载");
  void(^progressBlock)(float) = objc_getAssociatedObject(downloadTask, "progressBlock");
  if (!progressBlock) {
    return;
  }
  if (totalBytesExpectedToWrite > 0) {
    float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    progressBlock(progress);
  }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {

  NSLog(@"下载完成");

  NSString *fileName = downloadTask.originalRequest.URL.lastPathComponent;
  NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:fileName];
  NSFileManager *fm = [NSFileManager defaultManager];

//  //如果目标文件已存在，先删除
//  if ([fm fileExistsAtPath:docPath]) {
//    NSLog(@"歌曲重新下载");
//    [fm removeItemAtPath:docPath error:nil];
//  }

  //再 move
  NSError *error = nil;
  BOOL success = [fm moveItemAtURL:location toURL:[NSURL fileURLWithPath:docPath] error:&error];

  // 回调 completion
  void(^completionBlock)(NSURL *, NSError *) = objc_getAssociatedObject(downloadTask, "completionBlock");

  if (completionBlock) {
    completionBlock(success ? [NSURL fileURLWithPath:docPath] : nil, error);
  }

  // 移除任务
  NSString *key = downloadTask.originalRequest.URL.absoluteString;
  [self.downloadTasks removeObjectForKey:key];
  [self.resumeDataMap removeObjectForKey:key];
}

- (NSString *)localPathForDownloadURL:(NSURL *)url {
    NSString *fileName = url.lastPathComponent;
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES ).firstObject;
    return [docDir stringByAppendingPathComponent:fileName];
}


@end
