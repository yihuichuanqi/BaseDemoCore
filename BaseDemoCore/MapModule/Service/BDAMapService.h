//
//  BDAMapService.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/12.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapNaviKit/AMapNaviKit.h>

@protocol BDAMapServiceDelegate <NSObject>

@optional
-(void)didCloseNaviServiceAndView;
@end

@interface BDAMapService : NSObject
@property (nonatomic,weak) id<BDAMapServiceDelegate>delegate;

-(void)navWithPoint:(AMapNaviPoint *)startPoint endPoint:(AMapNaviPoint *)endPoint delegate:(id<BDAMapServiceDelegate>)delegate;

//根据路线覆盖物返回地图范围
+(MAMapRect)mapRectOfOverlays:(NSArray<id<MAOverlay>> *)overlays;
+(MAMapRect)mapRectOfOverlayArrays:(NSArray<NSArray<id<MAOverlay>> *>*)overlayArrays;







@end
