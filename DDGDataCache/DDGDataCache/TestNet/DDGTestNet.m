//
//  DDGTestNet.m
//  DDGDataCache
//
//  Created by dudongge on 2018/5/29.
//  Copyright © 2018年 dudongge. All rights reserved.
//

#import "DDGTestNet.h"

@implementation DDGTestNet
/**
 GET请求
 */
+(void)getWithURL:(NSString *)URL params:(NSDictionary *)params success:(NetworkSucess)success failure:(NetworkFailure)failure
{
    //此处仅做模拟请求,实际开发中请做真是请求
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSData *JSONData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Test" ofType:@"json"]];
        NSDictionary *json =  [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
        if(success) success(json);
    });
    
}
@end
