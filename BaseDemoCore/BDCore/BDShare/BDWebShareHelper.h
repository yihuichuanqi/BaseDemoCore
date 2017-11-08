//
//  BDWebShareHelper.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol BDWebShareHelperDelegate<JSExport>

//纯文本
JSExportAs(shareText,-(void)shareTexrForPlatForm:(NSString *)platformType text:(NSString *)text);
//URL
JSExportAs(shareUrl,-(void)shareUrlForPlatForm:(NSString *)platformType shareUrl:(NSString *)shareUrl title:(NSString *)title desc:(NSString *)desc thumImageUrl:(NSString *)thumImageUrl);
//图文
JSExportAs(shareImageText,-(void)shareImageTextForPlatForm:(NSString *)platformType shareImageUrl:(NSString *)shareImageUrl title:(NSString *)title desc:(NSString *)desc thumImageUrl:(NSString *)thumImageUrl);

@end

@interface BDWebShareHelper : NSObject

@property (nonatomic,weak) JSContext *jsContext;
@property (nonatomic,weak) UIWebView *webView;

@end
