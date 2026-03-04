# 缓存策略：Key、URL 与文件存储路径分析

## 一、三者关系总览

```
播放入口 (MusicPlayerManager)
    songId + 真实音频 URL
         ↓
LZStreamingURLBuilder.buildStreamingURLWithSongId(songId, realURL)
         ↓
streaming URL: streaming://{songId}     ← AVPlayer 请求用
realURL 存入 _urlMap[key]  (key = @"songId")
         ↓
LZResourceLoader 收到 AVPlayer 请求
         ↓
key = streamingURL.host (= songId 字符串)    ← 缓存唯一标识
realURL = realURLForStreamingURL(streamingURL) 或 DB 查回
         ↓
LZCacheRouter.getDataForKey:key url:realURL ...
         ↓
内存/磁盘/索引 全部用 key
磁盘路径 = cacheDir + SHA256(key)
```

- **Key**：缓存的唯一逻辑标识，推荐为 **songId 的字符串**，保证不随 URL 变化。
- **URL**：分 **streaming URL**（给 AVPlayer）和 **real URL**（给网络下载），通过 key 做映射。
- **文件路径**：由 **key** 唯一决定，`路径 = StreamCache 目录 + SHA256(key)`，与 URL 无直接关系。

---

## 二、Key 的定义与来源

### 2.1 Key 是什么

- 在整条缓存链路里，**同一个 key 代表同一首歌曲的同一份缓存**。
- 内存缓存（LZMemoryCache）、磁盘缓存（LZDiskCache）、范围索引（LZCacheIndex）、去重任务（LZCacheRouter 的 `pendingCallbacks`）、预加载（LZPreloadManager）都只认 **key**，不认 URL。

### 2.2 Key 从哪里来（LZResourceLoader.mm）

| 场景 | Key 取值 | 说明 |
|------|----------|------|
| **推荐** | `streamingURL.host` | URL 为 `streaming://{songId}` 时，host 即 songId 字符串，稳定、不随 CDN/鉴权变化。 |
| **兼容/兜底** | `realURL.absoluteString` | 非 streaming scheme 或 host 为空时用完整 URL 作 key，动态 URL 会导致 key 变化，缓存可能对不上。 |

代码依据：

```objc
// LZResourceLoader.mm 41-48
// 缓存 key 必须与写入时一致：始终用 songId（streaming://{songId} 的 host），避免重播时 fallback 成 url 导致 key 不同读不到盘
NSString *key = nil;
if ([streamingURL.scheme isEqualToString:@"streaming"] && streamingURL.host.length > 0) {
  key = streamingURL.host;
}
if (!key.length) {
  NSURL *realURL = [LZStreamingURLBuilder realURL:streamingURL];
  key = realURL.absoluteString;
}
```

设计意图：**写入和读取必须用同一套 key**。若播放时用 songId 写缓存，重播时却因某种原因用 URL 当 key，就会变成两个 key，读不到已缓存文件。

### 2.3 Key 在其它模块的用法

- **LZCacheRouter**：`getDataForKey:url:offset:length:completion:` 用 key 查内存/磁盘/索引，用 `key_offset_length` 做 `taskKey` 合并同一 range 的多次请求。
- **LZCacheRouter.syncCacheInfoToDBForKey:**：用 key 查库（先按 `longLongValue` 当 songId，再按 key 当 URL），取 `[disk filePath:key]` 和 `cachedTotalLengthForKey` 写回 DB。
- **LZPreloadManager**：`preloadWithKey:url:startOffset:length:` 的 key 与 ResourceLoader/CacheRouter 一致，预写磁盘/内存/索引都用同一 key。
- **LZCacheIndex**：所有接口都是 `xxxForKey:key`，按 key 维护已缓存 range、总长、loading 状态等。
- **LZDiskCache**：读/写/路径都基于 key，见下节。

---

## 三、URL 的两种形态与映射

### 3.1 Streaming URL（给 AVPlayer）

- **形式**：`streaming://{songId}`（推荐）或 `streaming://` + 原 URL 的 host/path（旧方案）。
- **作用**：让 AVPlayer 请求走 `AVAssetResourceLoader`，从而进入自定义的 `LZResourceLoader`，实现「按 range 从缓存/网络取数据」。
- **特点**：不直接用于下载；其 **host 被当作缓存 key**（推荐时为 songId）。

### 3.2 Real URL（真实音频地址）

- **形式**：原始 `https://...` 等可下载地址。
- **作用**：给 `LZRangeDownloader` 做 Range 请求，真正从网络拉数据。
- **特点**：可能带鉴权、CDN 会变，因此**不用 real URL 做缓存 key**，只用 songId。

### 3.3 Key 与 URL 的映射（LZStreamingURLBuilder）

- **写入**：`buildStreamingURLWithSongId:realURL:` 里  
  `key = [NSString stringWithFormat:@"%ld", songId]`，  
  `_urlMap[key] = url`（real URL），  
  返回 `streaming://{songId}`。
- **读取**：`realURLForStreamingURL:` 里  
  `key = streamingURL.host`，  
  `res = _urlMap[key]`。  
  即：**streaming URL 的 host（songId）→ 缓存 key → real URL**。

若进程内映射缺失（如重启后），ResourceLoader 会尝试用 key（songId）查 DB 拿 `model.url` 再转成 real URL，保证仍能下载。

---

## 四、文件存储路径（Key → Path）

### 4.1 路径公式

```
文件绝对路径 = [LZCachePathHelper streamCacheDirectory] + "/" + SHA256(key)
```

- **根目录**：`NSCachesDirectory`（系统 Caches 目录），每次通过 `LZCachePathHelper.cacheRootDirectory` 取，不持久化绝对路径。
- **子目录**：`StreamCache`，即 `streamCacheDirectory = cacheRoot + "StreamCache"`。
- **文件名**：对 **key 字符串**做 SHA256，得到 64 位十六进制字符串，无扩展名。

### 4.2 代码位置

**路径生成（LZDiskCache）：**

```objc
// LZDiskCache.m 37-39
- (NSString *)filePath:(NSString *)key {
  return [self.cacheDir stringByAppendingPathComponent:[self sha256String:key]];
}
```

**目录来源：**

```objc
// LZCachePathHelper.m
+ (NSString *)streamCacheDirectory {
  NSString *dir = [[self cacheRootDirectory] stringByAppendingPathComponent:@"StreamCache"];
  // ...
}
```

**SHA256**：对 key 的 UTF8 做 `CC_SHA256`，再格式化为 64 个十六进制字符（小写），保证同一 key 永远得到同一文件名。

### 4.3 路径的持久化与使用

- **持久化**：路径不直接存成「绝对路径」，而是通过 **key（songId）** 在需要时再算一次。  
  `syncCacheInfoToDBForKey:` 里用 `[self.disk filePath:key]` 得到当前路径，写入 DB（如 Song 的 filePath 字段），用于 UI 显示或离线判断。
- **读盘/写盘**：所有磁盘读写在 `LZDiskCache` 内都先 `filePath:key`，再在该路径上做 seek/read/write。  
  因此：**只要 key 一致，路径就一致；key 与 URL 解耦，换 CDN 也不影响已缓存文件。**

---

## 五、数据流小结（按请求走一遍）

1. **播放**  
   `MusicPlayerManager` 用 `buildStreamingURLWithSongId(songId, realURL)` 得到 `streaming://songId`，并登记 `_urlMap[@"songId"] = realURL`。

2. **AVPlayer 请求**  
   ResourceLoader 收到 `streaming://songId`，  
   key = host = `@"songId"`，  
   realURL = `_urlMap[key]` 或 DB 查到的 URL。

3. **取数据**  
   `getDataForKey:key url:realURL offset:length:completion:`  
   - 内存：`readDataForKey:key offset:length:`  
   - 磁盘：`readDataForKey:key offset:length:` → 内部 `path = filePath:key`  
   - 网络：用 realURL 做 Range 请求，得到数据后按 **key** 写内存、写盘、更新索引。

4. **写盘路径**  
   `[disk writeData:... key:key]` → `path = filePath:key` →  
   `StreamCache/SHA256(key)`。

5. **同步 DB**  
   `syncCacheInfoToDBForKey:key` → `path = [disk filePath:key]`，与 `cachedTotalLengthForKey` 等一起写回数据库。

整条链中：**key 唯一决定缓存内容与文件路径；URL 只负责网络拉流，通过 key 与缓存对应。**

---

## 六、设计要点与注意点

| 要点 | 说明 |
|------|------|
| **Key 稳定性** | 推荐 key = songId 字符串，不随 URL 变化，避免同一首歌多份缓存或读不到盘。 |
| **URL 与 Key 分离** | 缓存层只认 key；real URL 仅用于下载，通过 `_urlMap` 或 DB 按 key 找回。 |
| **路径不依赖 URL** | 路径 = `StreamCache` + SHA256(key)，与 real URL 无关，换域名/CDN 不影响已有文件。 |
| **路径不写死** | 根目录用系统 API 动态取，避免换设备/重装后绝对路径失效。 |
| **头注释过时** | LZPreloadManager.h 里写「key: 缓存key（url.lastComponent）」不准确，实际 key 应为 songId，与 URL 的 lastPathComponent 无必然关系，建议改为「key: 缓存 key，推荐为 songId 字符串」。 |
