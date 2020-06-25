//
//  KRRequestManager.m
//  KRNetworkManager
//
//  Created by 戴培琼 on 2020/6/25.
//  Copyright © 2020 戴培琼. All rights reserved.
//

#import "KRRequestManager.h"
#import "AFNetworking.h"
#import "KRNetworkConfig.h"
#import "ShoveGeneralRestGateway.h"

typedef void(^KRRequestSuccessBlock)(NSURLSessionDataTask *task, id responseObject);


@implementation KRRequestManager
// 请求API
+ (void)sendRequestWithRequestMethodType:(RequestType)type
                          requestAPICode:(NSString *)code
                       requestParameters:(NSDictionary *)parameters
                           requestHeader:(NSDictionary *)headerParameters
                                 success:(KRSuccessBlock)success
                                   faild:(KRFaildBlock)faild {
    [self sendRequestWithRequestMethodType:type requestAPICode:code baseURL:nil requestParameters:parameters requestHeader:headerParameters success:success faild:faild];
}

+ (void)sendRequestWithRequestMethodType:(RequestType)type
                          requestAPICode:(NSString *)code
                                 baseURL:(NSString*)baseURL
                       requestParameters:(NSDictionary *)parameters
                           requestHeader:(NSDictionary *)headerParameters
                                 success:(KRSuccessBlock)success
                                   faild:(KRFaildBlock)faild {
    [KRRequestManager sendRequestWithRequestMethodType:type requestAPICode:code baseURL:baseURL requestParameters:parameters requestHeader:headerParameters useJSONRequestSerializer:NO isRetry:NO success:success faild:faild];
}

+ (void)sendRequestWithRequestMethodType:(RequestType)type
                          requestAPICode:(NSString *)code
                                 baseURL:(NSString*)baseURL
                       requestParameters:(NSDictionary *)parameters
                           requestHeader:(NSDictionary *)headerParameters
                useJSONRequestSerializer:(BOOL)useJSONRequestSerializer
                                 isRetry:(BOOL)isRetry
                                 success:(KRSuccessBlock)success
                                   faild:(KRFaildBlock)faild {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:Baseurl]];
    if (useJSONRequestSerializer) {
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
    } else {
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 20;
    //无条件的信任服务器上的证书
    AFSecurityPolicy *securityPolicy =  [AFSecurityPolicy defaultPolicy];
    // 客户端是否信任非法证书
    securityPolicy.allowInvalidCertificates = YES;
    // 是否在证书域字段中验证域名
    securityPolicy.validatesDomainName = NO;
    manager.securityPolicy = securityPolicy;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html" ,@"text/plain", nil];
    if (headerParameters) {
        // 有自定义的请求头
        for (NSString *httpHeaderField in headerParameters.allKeys) {
            NSString *value = headerParameters[httpHeaderField];
            [manager.requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
        }
    }
    NSString *requestUrl;
//    if (baseURL) {
//        requestUrl = [NSString stringWithFormat:@"%@%@", baseURL, code];
//    }else{
//        requestUrl = [NSString stringWithFormat:@"%@%@", Baseurl, code];
//    }
    
      NSString *restUrl = [ShoveGeneralRestGateway buildUrl:code key:MD5key parameters:parameters];
    
    KRRequestSuccessBlock onSuccess = ^(NSURLSessionDataTask *task, id responseObject) {
//        NRLog(@"%@", [NRRequestManager logRequestWithPost:type == RequestPOST urlString:requestUrl parameters:parameters responseObject:responseObject error:nil]);
        if ([responseObject[@"code"] integerValue] == -4) {//重新登录
            if (isRetry) {
                success(responseObject);
            }
        } else {
            success(responseObject);
        }
    };
    
    [KRRequestManager sendReqeustViaManager:manager post:type == RequestPOST urlString:restUrl parameters:nil success:onSuccess failure:^(NSURLSessionDataTask *task, NSError *error) {
        // 请求失败后重试一次
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [KRRequestManager sendReqeustViaManager:manager post:type == RequestPOST urlString:requestUrl parameters:parameters success:onSuccess failure:^(NSURLSessionDataTask *task, NSError *error) {
//                NRLog(@"%@", [NRRequestManager logRequestWithPost:type == RequestPOST urlString:requestUrl parameters:parameters responseObject:nil error:error]);
                if ([error.domain isEqualToString:NSURLErrorDomain]) {
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:error.userInfo.allKeys.count];
                    dict[NSLocalizedDescriptionKey] = [NSString stringWithFormat:NSLocalizedString(@"NRRequest_error_network", nil), error.code];
                    error = [NSError errorWithDomain:error.domain code:error.code userInfo:dict];
                } else if ([error.domain isEqualToString:NSCocoaErrorDomain] && error.code == 3840) {
                    // 返回格式错误
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:error.userInfo.allKeys.count];
                    dict[NSLocalizedDescriptionKey] = [NSString stringWithFormat:NSLocalizedString(@"NRRequest_error_server", nil), error.code];
                    error = [NSError errorWithDomain:error.domain code:error.code userInfo:dict];
                }
                faild(error);
            }];
        });
    }];
}

+ (void)sendReqeustViaManager:(AFHTTPSessionManager *)manager post:(BOOL)post urlString:(NSString *)urlString parameters:(NSDictionary *)parameters success:(void(^)(NSURLSessionDataTask *, id))success failure:(void(^)(NSURLSessionDataTask *, NSError *))failure {
//      NSLog(@"抢红包开始1");
    if (post) {
        [manager POST:urlString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (success) {
                success(task, responseObject);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failure) {
                failure(task, error);
            }
//            //监控接口错误
//            [TGMonitoringEventClient monitoringInternalApiErrWithMethod:urlString task:task error:error];
        }];
    } else {
        [manager GET:urlString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (success) {
                success(task, responseObject);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failure) {
                failure(task, error);
            }
//            //监控接口错误
//            [TGMonitoringEventClient monitoringInternalApiErrWithMethod:urlString task:task error:error];
        }];
    }
}

+ (NSString *)logRequestWithPost:(BOOL)post urlString:(NSString *)urlString parameters:(NSDictionary *)parameters responseObject:(id)responseObject error:(NSError *)error {
    NSMutableString *log = [NSMutableString stringWithString:@"=================🌟🌟Start🌟🌟==================\nRequest:\n"];
    if (post) {
        [log appendFormat:@"URL: %@", urlString];
        [log appendString:@"\nMethod: POST"];
        [log appendFormat:@"\nParameters: %@", parameters];
    } else {
        NSURLComponents *components = [NSURLComponents componentsWithString:urlString];
        NSMutableArray *mItems = [NSMutableArray arrayWithCapacity:parameters.allKeys.count];
        for (NSString *key in parameters.allKeys) {
            NSObject *value = parameters[key];
            NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:key value:[NSString stringWithFormat:@"%@", value]];
            [mItems addObject:item];
        }
        components.queryItems = mItems;
        [log appendFormat:@"URL: %@", components.URL.absoluteString];
        [log appendString:@"\nMethod: GET"];
    }
    [log appendString:@"\n---------------------------------"];
    [log appendFormat:@"\nResponse:\n %@", responseObject];
    if (error) {
        [log appendFormat:@"\nError: %@", error];
    }
    [log appendString:@"\n================End==================="];
    return log;
}
@end
