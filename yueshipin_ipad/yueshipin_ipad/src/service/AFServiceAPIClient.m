// AFGowallaAPI.m
//
// Copyright (c) 2011 Gowalla (http://gowalla.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AFServiceAPIClient.h"
#import "AFJSONRequestOperation.h"
#import "ServiceConstants.h"
#import "ContainerUtility.h"
#import "CMConstants.h"
#import "Reachability.h"
#import "StringUtility.h"

NSString * const kABaseURLString = @"http://test.joyplus.tv/";
//NSString * const kABaseURLString = @"http://api.joyplus.tv/";

@implementation AFServiceAPIClient

+ (AFServiceAPIClient *)sharedClient {
    static AFServiceAPIClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kABaseURLString]];
        [_sharedClient setDefaultHeader:@"app_key" value:kAppKey];
        [_sharedClient setDefaultHeader:@"Connection" value:@"keep-alive"];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    //    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
    //	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    //    // X-Gowalla-API-Key HTTP Header; see http://api.gowalla.com/api/docs
    //	[self setDefaultHeader:@"X-Gowalla-API-Key" value:kAFGowallaClientID];
	
    //	// X-Gowalla-API-Version HTTP Header; see http://api.gowalla.com/api/docs
    //	[self setDefaultHeader:@"X-Gowalla-API-Version" value:@"1"];
	
    //	// X-UDID HTTP Header
    //	[self setDefaultHeader:@"X-UDID" value:[[UIDevice currentDevice] uniqueIdentifier]];
    
    return self;
}

- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self generateUserId:path parameters:parameters success:success failure:failure];
}

- (void)generateUserId:(NSString *)path
            parameters:(NSDictionary *)parameters
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    if([kPathGenerateUIID isEqualToString:path]){
        [super getPath:path parameters:parameters success:success failure:failure];
        return;
    }
    NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
    if(userId == nil){
        Reachability *tempHostReach = [Reachability reachabilityForInternetConnection];
        if([tempHostReach currentReachabilityStatus] != NotReachable) {
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [StringUtility createUUID], @"uiid", nil];
            [[AFServiceAPIClient sharedClient] getPath:kPathGenerateUIID parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                NSString *responseCode = [result objectForKey:@"res_code"];
                if (responseCode == nil) {
                    NSString *user_id = [result objectForKey:@"user_id"];
                    NSString *nickname = [result objectForKey:@"nickname"];
                    NSString *username = [result objectForKey:@"username"];
                    [[ContainerUtility sharedInstance] setAttribute:user_id forKey:kUserId];
                    [[ContainerUtility sharedInstance] setAttribute:[NSString stringWithFormat:@"%@", nickname] forKey:kUserNickName];
                    [[ContainerUtility sharedInstance] setAttribute:username forKey:kUserName];
                    [super setDefaultHeader:@"user_id" value:user_id];
                    [super getPath:path parameters:parameters success:success failure:failure];
                }
            } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@", error);
            }];
        }
    } else {
        [super setDefaultHeader:@"user_id" value:userId];
        [super getPath:path parameters:parameters success:success failure:failure];
    }
}


- (void)postPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	[self generateUserIdForPost:path parameters:parameters success:success failure:failure];
}

- (void)generateUserIdForPost:(NSString *)path
            parameters:(NSDictionary *)parameters
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
    if(userId == nil){
        Reachability *tempHostReach = [Reachability reachabilityForInternetConnection];
        if([tempHostReach currentReachabilityStatus] != NotReachable) {
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [StringUtility createUUID], @"uiid", nil];
            [[AFServiceAPIClient sharedClient] getPath:kPathGenerateUIID parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                NSString *responseCode = [result objectForKey:@"res_code"];
                if (responseCode == nil) {
                    NSString *user_id = [result objectForKey:@"user_id"];
                    NSString *nickname = [result objectForKey:@"nickname"];
                    NSString *username = [result objectForKey:@"username"];
                    [[ContainerUtility sharedInstance] setAttribute:user_id forKey:kUserId];
                    [[ContainerUtility sharedInstance] setAttribute:[NSString stringWithFormat:@"用户%@", nickname] forKey:kUserNickName];
                    [[ContainerUtility sharedInstance] setAttribute:username forKey:kUserName];
                    [super setDefaultHeader:@"user_id" value:user_id];
                    [super postPath:path parameters:parameters success:success failure:failure];
                }
            } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@", error);
            }];
        }
    } else {
        [super setDefaultHeader:@"user_id" value:userId];
        [super postPath:path parameters:parameters success:success failure:failure];
    }
}

@end
