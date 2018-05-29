//
//  DDGDataCache.h
//  DDGDataCache
//
//  Created by dudongge on 2018/5/29.
//  Copyright © 2018年 dudongge. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DDGDataCacheCompletionBlock)(BOOL result);

@interface DDGDataCache : NSObject
/**
 *  写入/更新缓存(同步) [按APP版本号缓存,不同版本APP,同一接口缓存数据互不干扰]
 *
 *  @param jsonResponse 要写入的数据(JSON)
 *  @param URL    数据请求URL
 * - parameter path:        一级文件夹路径path（必须设置）
 * - parameter subPath:     二级文件夹路径subPath（可设置-可不设置）
 *  @return 是否写入成功
 */
+(BOOL)saveJsonResponseToCacheFile:(id)jsonResponse andURL:(NSString *)URL path:(NSString *)path andSubPath:(NSString *)subPath ;
/**
 *  写入/更新缓存(异步) [按APP版本号缓存,不同版本APP,同一接口缓存数据互不干扰]
 *
 *  @param jsonResponse    要写入的数据(JSON)
 *  @param URL             数据请求URL
 * - parameter path:        一级文件夹路径path（必须设置）
 * - parameter subPath:     二级文件夹路径subPath（可设置-可不设置）
 *  @param completedBlock  异步完成回调(主线程回调)
 */
+(void)save_asyncJsonResponseToCacheFile:(id)jsonResponse andURL:(NSString *)URL path:(NSString *)path andSubPath:(NSString *)subPath  completed:(nullable DDGDataCacheCompletionBlock)completedBlock;


/**
 *  获取缓存的对象(同步)
 *
 *  @param URL 数据请求URL
 *  @param subPath 数据请求二级目录(选填)
 *
 *  @return 缓存对象
 */
+(id)cacheJsonWithURL:(NSString *)URL subPath:(NSString *)subPath;

/**
 *  获取缓存路径
 *
 *  @return 缓存路径
 */
+(NSString *)cachePath;

/**
 *  获取子缓存路径
 *
 *  @return 缓存路径
 */
+(NSString *)cacheSubPath:(NSString *)subPath ;

/**
 *  清除所有缓存
 */

+(BOOL)clearAllCache;

/**
 *  清除指定缓存大小(单位:M)
 ** @param subPath 二级缓存路径
 *  @return 缓存大小
 */
+(BOOL)clearCacheWithSubPath:(NSString *) subPath;

/**
 *  获取缓存大小(单位:M)
 *
 *  @return 缓存大小
 */
+(float)cacheAllSize;

/**
*  获取指定缓存大小(单位:M)
 ** @param subPath 二级缓存路径
*  @return 缓存大小
*/
+ (float)cacheSizeWithSubPath:(NSString *)subPath;

/**
 *  获取缓存大小,(以..kb/..M)形式获取
 *  小于1M,以kb形式返回,大于1M,以M形式返回
 *  @return 缓存大小+单位
 */
+(NSString *)cacheAllSizeFormat;
/**
 *  获取指定缓存大小,(以..kb/..M)形式获取
 *  小于1M,以kb形式返回,大于1M,以M形式返回
  ** @param subPath 二级缓存路径
 *  @return 缓存大小+单位
 */
+(NSString *)cacheAllSizeFormatWithSubPath:(NSString *)subPath;

@end
