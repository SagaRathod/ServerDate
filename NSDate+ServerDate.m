//
//  NSDate+ServerDate.m
//
//  Created by Sagar Rathode on 29/10/18.
//  Copyright (c) 2018 Sagar Rathode. All rights reserved.
//

#import "NSDate+ServerDate.h"

static NSTimeInterval   _SDInterval;

@interface NSDate (ServerDateExtras)
+(void)_SDresetServerTime;
@end

@implementation NSDate (ServerDate)

+(NSDate *)serverDate{
    if(!_SDInterval){
        [self _SDresetServerTime];
    }
    
     return [[NSDate date] dateByAddingTimeInterval: _SDInterval];
}

#pragma mark - Private Helpers
+(void)_SDresetServerTime{
    NSHTTPURLResponse *resp;
    NSError *err;
    
    NSMutableURLRequest *req        = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:_SD_SERVER]];
    req.HTTPMethod                  = @"HEAD";
    
    [NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&err];
    NSString *httpDate              = [resp allHeaderFields][@"Date"];
    
    NSDateFormatter *df             = [[NSDateFormatter alloc] init];
    df.dateFormat                   = _SD_FORMAT;
    df.locale                       = [NSLocale localeWithLocaleIdentifier:@"UTC"]; //en_US
    
    NSDate *serverDate             = [df dateFromString: httpDate];
    _SDInterval                    = [serverDate timeIntervalSinceNow];
    
    [[NSNotificationCenter defaultCenter] removeObserver:[self class] name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:[self class] selector:@selector(_SDresetServerTime) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    #ifdef DEBUG
    NSLog(@"Server Clock resetted to: %@", serverDate);
    #endif
}

@end
