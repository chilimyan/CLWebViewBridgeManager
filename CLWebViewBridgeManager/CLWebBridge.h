//
//  CLWebBridge.h
//  CLTableViewDemo
//
//  Created by Apple on 2018/7/30.
//  Copyright © 2018年 chilim. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^webProtocolCallback)(NSURLComponents *components);
typedef void (^webHandleCallback)(id item, NSError * _Nullable error);

/**
 执行js代理
 */
@protocol CLWebBridgeDelegate <NSObject>
- (void)evaluateJavascript:(NSString*)javascriptCommand callBack:(webHandleCallback)callBack;
@end

@interface CLWebBridge : NSObject

@property (nonatomic, strong) NSMutableDictionary *callBackDic;
@property (nonatomic, weak) id <CLWebBridgeDelegate> delegate;

- (void)protocolMatch:(NSURLComponents *)components;
- (void)sendData:(NSDictionary *)data handleName:(NSString *)handleName callBack:(webHandleCallback)callBack;


@end
