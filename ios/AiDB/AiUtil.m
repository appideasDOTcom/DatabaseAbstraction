//
//  AiUtil.m
//  AiDB
//
//  Created by Christopher Ostmo on 12/23/13.
//  Copyright (c) 2013 APPideas. All rights reserved.
//

#import "AiUtil.h"

@implementation AiUtil

/**
 * Strip characters from a string
 *
 * <pre>NSMutableArray *remove = [NSMutableArray arrayWithCapacity:2];
 * [remove insertObject:@";" atIndex:0]; // remove semicolons
 * [remove insertObject:@"^" atIndex:1]; // remove carets
 * NSString "resultString = [AiUtil stripChars:remove fromString:inputString];</pre>
 */
+(NSString *)stripChars:(NSMutableArray *)charArray fromString:(NSString *)inputString
{
    NSString *returnValue = inputString;
    
    for( int i = 0; i < [charArray count]; i++ )
    {
        returnValue = [returnValue stringByReplacingOccurrencesOfString:[charArray objectAtIndex:i] withString:@""];
    }
    
    return returnValue;
}

/**
 * Convert an epoch date to something for humans.
 *
 * <pre>NSString showDate = [AiUtil readableDateFromEpoch:epochDate withFormat:_shortDateTimeFormat];</pre>
 */
+(NSString *)readableDateFromEpoch:(NSInteger)epochDate withFormat:(NSString *)outputFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:outputFormat];
    NSDate *showDate = [NSDate dateWithTimeIntervalSince1970:epochDate];
    
    return [dateFormatter stringFromDate:showDate];
}

@end
