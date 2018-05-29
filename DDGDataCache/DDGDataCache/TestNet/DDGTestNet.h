//
//  DDGTestNet.h
//  DDGDataCache
//
//  Created by dudongge on 2018/5/29.
//  Copyright © 2018年 dudongge. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^NetworkSucess) (id response);
typedef void(^NetworkFailure) (NSError *error);
@interface DDGTestNet : NSObject
/**
 GET请求
 */
+(void)getWithURL:(NSString *)URL params:(NSDictionary *)params success:(NetworkSucess)success failure:(NetworkFailure)failure;
@end
