//
//  CLWebBridge.m
//  CLTableViewDemo
//
//  Created by Apple on 2018/7/30.
//  Copyright © 2018年 chilim. All rights reserved.
//

#import "CLWebBridge.h"

@implementation CLWebBridge

- (void)protocolMatch:(NSURLComponents *)components{
    if (self.callBackDic[components.scheme]) {
        webProtocolCallback callBack = self.callBackDic[components.scheme];
        if (callBack) {
            callBack(components);
        }
    }
}

- (void)sendData:(NSDictionary *)data handleName:(NSString *)handleName callBack:(webHandleCallback)callBack{
    NSString *messageJSON = [self serializeMessage:data pretty:NO];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
    NSString* javascriptCommand = [NSString stringWithFormat:@"%@('%@');", handleName,messageJSON];
    if ([[NSThread currentThread] isMainThread]) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(evaluateJavascript:callBack:)]){
            [self.delegate evaluateJavascript:javascriptCommand callBack:callBack];
        }
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if(self.delegate && [self.delegate respondsToSelector:@selector(evaluateJavascript:callBack:)]){
                [self.delegate evaluateJavascript:javascriptCommand callBack:callBack];
            }
        });
    }
}

- (NSString *)serializeMessage:(id)message pretty:(BOOL)pretty{
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message options:(NSJSONWritingOptions)(pretty ? NSJSONWritingPrettyPrinted : 0) error:nil] encoding:NSUTF8StringEncoding];
}

- (NSMutableDictionary *)callBackDic{
    if (!_callBackDic) {
        _callBackDic = [[NSMutableDictionary alloc] init];
    }
    return _callBackDic;
}

@end
