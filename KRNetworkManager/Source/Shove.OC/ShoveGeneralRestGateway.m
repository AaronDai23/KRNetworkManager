//
//  ShoveGeneralRestGateway.m
//  Shove
//
//  Created by 英迈思实验室移动开发部 on 14-8-28.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//
// 通用的 REST 类型的网关

#import "ShoveGeneralRestGateway.h"

#import "NSString+Shove.h"

@implementation ShoveGeneralRestGateway


/**
 * 构建通用网关的请求 url，参数为键值对形式，不分顺序。不需要包含时间戳、签名等参数 ，系统会自动增加。
 *
 * @param urlBase
 *                  地址
 * @param key
 *                  加密的key
 * @param parameters
 *                  参数
 * @return  生成后的网关
 */
+ (NSString *) buildUrl:(NSString *)baseUrl key:(NSString *)key parameters:(NSMutableDictionary  *)parameters
{
    
    if ([[parameters allKeys] containsObject:@"_s"] || [[parameters allKeys] containsObject:@"_t"]){
//        DLOG(@"在使用 ShoveGeneralRestGateway buildUrl 方法构建通用 REST 接口 Url 时，不能使用 _s, _t 此保留字作为参数名。");
        return nil;
}

    if ([key isEmpty]) {
//        DLOG(@"在使用 ShoveGeneralRestGateway buildUrl 方法构建通用 REST 接口 Url 时，必须提供一个用于摘要签名用的 key (俗称 MD5 加盐)。");
        return nil;
    }
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
    NSString* currentDate = [formatter stringFromDate:date];
    [parameters setValue:currentDate forKey:@"_t"];
    
    NSArray *parameterNames = [parameters allKeys];
    parameterNames = [parameterNames sortedArrayUsingSelector:@selector(compare:)];// 字符串编码升序排序
    
    if (![baseUrl hasSuffix:@"?"] && ![baseUrl hasSuffix:@"&"]) {
        if([baseUrl rangeOfString:@"?"].length <= 0)
        {
            baseUrl = [baseUrl stringByAppendingString:@"?"];
        } else {
            baseUrl = [baseUrl stringByAppendingString:@"&"];
        }
    }
    
    NSString *signData = @"";
    
    for (int i = 0; i < [parameters count]; i++) {
        NSString *_key = parameterNames[i];
        NSString * _value = parameters[_key];
          NSString *unencodedString = _value;
           signData = [NSString stringWithFormat:@"%@%@=%@", signData, _key, _value];
        NSString *encodedString;
             encodedString = [ShoveGeneralRestGateway urlEncodeStr:unencodedString];
        baseUrl = [NSString stringWithFormat:@"%@%@=%@", baseUrl, _key, encodedString]; // 将value编码
        if (i < ([parameters count] - 1)) {
            signData = [signData stringByAppendingString:@"&"];
            baseUrl = [baseUrl stringByAppendingString:@"&"];
        }
    }
    NSString *signDataStr;
    if (![signData containsString:@"body"]) {
        signDataStr = [NSString stringWithFormat:@"%@&body=",signData];
    }else {
         signDataStr = [NSString stringWithFormat:@"%@",signData];
    }
    
    baseUrl = [NSString stringWithFormat:@"%@&_s=%@", baseUrl, [[signDataStr stringByAppendingString:key] md52]];
   
    return baseUrl;
}


//urlEncode编码
+(NSString *)urlEncodeStr:(NSString *)input{
    NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    NSString *upSign = [input stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    return upSign;
}


//urlEncode解码
+ (NSString *)decoderUrlEncodeStr: (NSString *) input{
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+" withString:@"" options:NSLiteralSearch range:NSMakeRange(0,[outputStr length])];
    return [outputStr stringByRemovingPercentEncoding];
}

@end
