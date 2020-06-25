//
//  KRRequestManager.h
//  KRNetworkManager
//
//  Created by 戴培琼 on 2020/6/25.
//  Copyright © 2020 戴培琼. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// 网络请求类型
typedef NS_ENUM (NSInteger, RequestType)
{
    RequestGET     = 0,
    RequestPOST    = 1,
};
typedef void(^KRSuccessBlock)(id responseObject);

typedef void(^KRFaildBlock)(NSError *error);

@interface KRRequestManager : NSObject

/**
 *  请求API
 *  type : 请求方式
 *  code : 请求接口API
 *  parameters :  请求参数， 可为nil
 *  headerParameters  : 请求头参数, 可为nil
 *  success  : 请求成功返回
 *  faild  : 请求失败返回
 */
+ (void)sendRequestWithRequestMethodType:(RequestType)type
                          requestAPICode:(NSString *)code
                       requestParameters:(NSDictionary *)parameters
                           requestHeader:(NSDictionary *)headerParameters
                                 success:(KRSuccessBlock)success
                                   faild:(KRFaildBlock)faild;

/**
 *  请求API
 *  type : 请求方式
 *  code : 请求接口API
 *  baseURL: 基础地址。不传 则 用默认 REQUEST
 *  parameters :  请求参数， 可为nil
 *  headerParameters  : 请求头参数, 可为nil
 *  success  : 请求成功返回
 *  faild  : 请求失败返回
 */
+ (void)sendRequestWithRequestMethodType:(RequestType)type
                          requestAPICode:(NSString *)code
                                 baseURL:(NSString*)baseURL
                       requestParameters:(NSDictionary *)parameters
                           requestHeader:(NSDictionary *)headerParameters
                                 success:(KRSuccessBlock)success
                                   faild:(KRFaildBlock)faild;

+ (void)sendRequestWithRequestMethodType:(RequestType)type
                          requestAPICode:(NSString *)code
                                 baseURL:(NSString*)baseURL
                       requestParameters:(NSDictionary *)parameters
                           requestHeader:(NSDictionary *)headerParameters
                useJSONRequestSerializer:(BOOL)useJSONRequestSerializer
                                 isRetry:(BOOL)isRetry
                                 success:(KRSuccessBlock)success
                                   faild:(KRFaildBlock)faild;


@end

NS_ASSUME_NONNULL_END
