//
//  DDGDataCache.m
//  DDGDataCache
//
//  Created by dudongge on 2018/5/29.
//  Copyright © 2018年 dudongge. All rights reserved.
//

#import "DDGDataCache.h"
#import <CommonCrypto/CommonDigest.h>

#ifdef DEBUG
#define DebugLog(...) NSLog(__VA_ARGS__)
#else
#define DebugLog(...)
#endif

@implementation DDGDataCache


+(BOOL)saveJsonResponseToCacheFile:(id)jsonResponse andURL:(NSString *)URL path:(NSString *)path andSubPath:(NSString *)subPath {
    
    if(jsonResponse==nil || URL.length==0) return NO;
    NSData * data= [self jsonToData:jsonResponse];
    return[[NSFileManager defaultManager] createFileAtPath:[self cacheFilePathWithURL:URL path:path andSubPath:subPath] contents:data attributes:nil];
}

+(void)save_asyncJsonResponseToCacheFile:(id)jsonResponse andURL:(NSString *)URL path:(NSString *)path andSubPath:(NSString *)subPath  completed:(nullable DDGDataCacheCompletionBlock)completedBlock{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        BOOL result=[self saveJsonResponseToCacheFile:jsonResponse andURL:URL path:path andSubPath:subPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completedBlock)  completedBlock(result);
        });
    });
}


+(id )cacheJsonWithURL:(NSString *)URL subPath:(NSString *)subPath{
    
    if(URL==nil) return nil;
    NSString *keyPath = [NSUserDefaults.standardUserDefaults stringForKey:@"DDGCacheKeyPath"];
    if (keyPath != nil && ![keyPath  isEqual: @""]) {
        NSString *path = [self cacheFilePathWithURL:URL path:keyPath andSubPath:subPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path isDirectory:nil] == YES) {
            NSData *data = [fileManager contentsAtPath:path];
            return [self dataToJson:data];
        }
    }
    return nil;
}

+(BOOL)clearAllCache
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [self cachePath];
    BOOL result = [fileManager removeItemAtPath:path error:nil];
    [self checkDirectory:[self cachePath]];
    return result;
}
+(BOOL)clearCacheWithSubPath:(NSString *)subPath {
    if (subPath == nil) {
        return NO;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [self cacheSubPath:subPath];
    BOOL result = [fileManager removeItemAtPath:path error:nil];
    [self checkDirectory:[self cachePath]];
    return result;
}


+ (float)cacheSizeWithSubPath:(NSString *)subPath {
    NSString *directoryPath = [self cacheSubPath:subPath];
    BOOL isDir = NO;
    unsigned long long total = 0;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDir]) {
        if (isDir) {
            NSError *error = nil;
            NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
            
            if (error == nil) {
                for (NSString *subpath in array) {
                    NSString *path = [directoryPath stringByAppendingPathComponent:subpath];
                    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path
                                                                                          error:&error];
                    if (!error) {
                        total += [dict[NSFileSize] unsignedIntegerValue];
                    }
                }
            }
        }
    }
    return total/(1024.0*1024.0);
}
+ (float)cacheAllSize {
    NSString *directoryPath = [self cachePath];
    BOOL isDir = NO;
    unsigned long long total = 0;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDir]) {
        if (isDir) {
            NSError *error = nil;
            NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
            
            if (error == nil) {
                for (NSString *subpath in array) {
                    NSString *path = [directoryPath stringByAppendingPathComponent:subpath];
                    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path
                                                                                          error:&error];
                    if (!error) {
                        total += [dict[NSFileSize] unsignedIntegerValue];
                    }
                }
            }
        }
    }
    return total/(1024.0*1024.0);
}
+(NSString *)cacheAllSizeFormat
{
    NSString *sizeUnitString;
    float size = [self cacheAllSize];
    if(size < 1)
    {
        size *= 1024.0;//小于1M转化为kb
        sizeUnitString = [NSString stringWithFormat:@"%.1fkb",size];
    }
    else{
        
        sizeUnitString = [NSString stringWithFormat:@"%.1fM",size];
    }
    
    return sizeUnitString;
}
+(NSString *)cacheAllSizeFormatWithSubPath:(NSString *)subPath {
    NSString *sizeUnitString;
    float size = [self cacheSizeWithSubPath:subPath];
    if(size < 1)
    {
        size *= 1024.0;//小于1M转化为kb
        sizeUnitString = [NSString stringWithFormat:@"%.1fkb",size];
    }
    else{
        
        sizeUnitString = [NSString stringWithFormat:@"%.1fM",size];
    }
    
    return sizeUnitString;
}

#pragma mark - private
+ (NSString *)cacheFilePathWithURL:(NSString *)URL path:(NSString *)path andSubPath: (NSString *)subPath {
    
    NSString *newPath = @"";
    if ([subPath  isEqual: @""] || subPath == nil ) {
        //保存最新的一级目录
        [NSUserDefaults.standardUserDefaults setValue:path forKeyPath:@"DDGCacheKeyPath"];
        [NSUserDefaults.standardUserDefaults synchronize];
        newPath = [self cachePath];
    } else {
        newPath = [self cacheSubPath:subPath];
    }
    
    //checkDirectory
    [self checkDirectory:newPath];
    //fileName
    NSString *cacheFileNameString = [NSString stringWithFormat:@"URL:%@AppVersion:%@",URL,[self appVersionString]];
    NSString *cacheFileName = [self md5StringFromString:cacheFileNameString];
    
    newPath = [NSString stringWithFormat:@"%@/%@",newPath,cacheFileName];
    return newPath;
}

+ (NSString *)cacheFilePathWithURL:(NSString *)URL params:(NSDictionary *)params{
    
    NSString *path = [self cachePath];
    //checkDirectory
    [self checkDirectory:path];
    //fileName
    NSString *cacheFileName = [self cacheFileNameWithURL:URL params:params];
    path = [path stringByAppendingPathComponent:cacheFileName];
    return path;
}

+(NSData *)jsonToData:(id)jsonResponse
{
    if(jsonResponse==nil) return nil;
    NSError *error;
    NSData *data =[NSJSONSerialization dataWithJSONObject:jsonResponse options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        DebugLog(@"ERROR, faild to get json data");
        return nil;
    }
    return data;
}

+(id)dataToJson:(NSData *)data
{
    if(data==nil) return nil;
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}

+(NSString *)cachePath
{
    NSString *keyPath = [NSUserDefaults.standardUserDefaults stringForKey:@"DDGCacheKeyPath"];
    if (keyPath != nil && ![keyPath  isEqual: @""]) {
        NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *path = [pathOfLibrary stringByAppendingPathComponent:keyPath];
        return path;
    } else {
        return @"";
    }
}

+(NSString *)cacheSubPath:(NSString *)subPath {
    NSString *newPath = [NSString stringWithFormat:@"%@%@%@",[self cachePath],@"/",subPath];
    return newPath;
    
}
+(NSString *)cacheFileNameWithURL:(NSString *)URL params:(NSDictionary *)params
{
    if(URL== nil || URL.length == 0) return nil;
    NSString *fileName = [NSString stringWithFormat:@"URL:%@%@ AppVersion:%@",URL,[self paramsStringWithParams:params],[self appVersionString]];
    //DebugLog(@"flieName=%@",fileName);
    return  [self md5StringFromString:fileName];
}
+(NSString *)paramsStringWithParams:(NSDictionary *)params
{
    if(params==nil) return @"";
    NSArray *keyArray = [params allKeys];
    NSArray *sortArray = [keyArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSMutableArray *valueArray = [NSMutableArray array];
    for (NSString *sortString in sortArray) {
        [valueArray addObject:[params objectForKey:sortString]];
    }
    NSMutableArray *keyValueArray = [NSMutableArray array];
    for (int i = 0; i < sortArray.count; i++) {
        NSString *keyValueStr = [NSString stringWithFormat:@"%@=%@",sortArray[i],valueArray[i]];
        [keyValueArray addObject:keyValueStr];
    }
    return [NSString stringWithFormat:@"?%@",[keyValueArray componentsJoinedByString:@"&"]];
}
+(void)checkDirectory:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createBaseDirectoryAtPath:path];
    } else {
        
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
}

+ (void)createBaseDirectoryAtPath:(NSString *)path {
    __autoreleasing NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                               attributes:nil error:&error];
    if (error) {
        DebugLog(@"create cache directory failed, error = %@", error);
    } else {
        
        DebugLog(@"path = %@",path);
        [self addDoNotBackupAttribute:path];
    }
}

+ (void)addDoNotBackupAttribute:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (error) {
        DebugLog(@"error to set do not backup attribute, error = %@", error);
    }
}

+ (NSString *)md5StringFromString:(NSString *)string {
    
    if(string == nil || [string length] == 0)  return nil;
    
    const char *value = [string UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

+ (NSString *)appVersionString {
    
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

@end
