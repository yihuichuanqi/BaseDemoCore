//
//  BDAMapService.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/12.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDAMapService.h"
#import "AppDelegate.h"

//导航视图宽/高
#define kNavScreenWidth ([[UIScreen mainScreen] bounds].size.width)
#define kNavScreenHeight ([[UIScreen mainScreen] bounds].size.height)

@interface BDAMapService ()<AMapNaviDriveViewDelegate,AMapNaviDriveManagerDelegate>
{
    AMapNaviPoint *_startPoint;
    AMapNaviPoint *_endPoint;
    
}
@property (nonatomic,strong) AMapNaviDriveManager *naviManager;
@property (nonatomic,strong) AMapNaviDriveView *naviView;




@end


@implementation BDAMapService


-(AMapNaviDriveView *)naviView
{
    if (_naviView==nil)
    {
        _naviView=[[AMapNaviDriveView alloc]initWithFrame:CGRectMake(0, 0, kNavScreenWidth, kNavScreenHeight-[UIApplication sharedApplication].statusBarFrame.size.height)];
        _naviView.delegate=self;
    }
    return _naviView;
}
-(AMapNaviDriveManager *)naviManager
{
    if (self.naviManager==nil)
    {
        _naviManager=[[AMapNaviDriveManager alloc]init];
        _naviManager.delegate=self;
    }
    return _naviManager;
}
-(id)init
{
    if (self=[super init])
    {
        [self.naviManager addDataRepresentative:self.naviView];
    }
    return self;
}

-(void)dealloc
{
    self.delegate=nil;
    _naviManager.delegate=nil;
    
}



-(void)navWithPoint:(AMapNaviPoint *)startPoint endPoint:(AMapNaviPoint *)endPoint delegate:(id<BDAMapServiceDelegate>)delegate
{
    _startPoint=startPoint;
    _endPoint=endPoint;
    self.delegate=delegate;
    [self routeCaluate];
}
//路线计算规划
-(void)routeCaluate
{
    NSArray *startPoints=@[_startPoint];
    NSArray *endPoints=@[_endPoint];
    [self.naviManager calculateDriveRouteWithStartPoints:startPoints endPoints:endPoints wayPoints:nil drivingStrategy:AMapNaviDrivingStrategySingleDefault];
}
//导航规划功能关闭
-(void)didCloseAMapServiceNamager
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didCloseNaviServiceAndView)])
    {
        [self.delegate didCloseNaviServiceAndView];
    }
}
+(MAMapRect)mapRectOfOverlays:(NSArray<id<MAOverlay>> *)overlays
{
    MAMapRect rect=MAMapRectZero;
    for (id<MAOverlay> overlay in overlays)
    {
        rect=MAMapRectUnion(rect, overlay.boundingMapRect);
    }
    return rect;
}
+(MAMapRect)mapRectOfOverlayArrays:(NSArray<NSArray<id<MAOverlay>> *> *)overlayArrays
{
    MAMapRect rect=MAMapRectZero;
    for (NSArray<id<MAOverlay>> *overlays in overlayArrays)
    {
        rect=MAMapRectUnion(rect, [self mapRectOfOverlays:overlays]);
    }
    return rect;
}


#pragma mark-AMapNaviDriveManager Delegate
-(void)driveManager:(AMapNaviDriveManager *)driveManager error:(NSError *)error
{
    [self didCloseAMapServiceNamager];
}
-(void)driveManagerOnCalculateRouteSuccess:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"%@",@(driveManager.naviRoute.routeTime));
    //可能需要初始化语音引擎
}
-(void)driveManager:(AMapNaviDriveManager *)driveManager onCalculateRouteFailure:(NSError *)error
{
    [self didCloseAMapServiceNamager];
}
//导航播报信息回调
-(void)driveManager:(AMapNaviDriveManager *)driveManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType
{
    
}


#pragma mark-AManNaviViewController Delegate
-(void)driveViewCloseButtonClicked:(AMapNaviDriveView *)driveView
{
    [self.naviManager stopNavi];
    // fixed 导航旋转的bug
}
-(void)driveViewMoreButtonClicked:(AMapNaviDriveView *)driveView
{
    if (driveView.trackingMode==AMapNaviViewTrackingModeCarNorth)
    {
        driveView.trackingMode=AMapNaviViewTrackingModeMapNorth;
    }
    else
    {
        driveView.showMode=AMapNaviDriveViewShowModeCarPositionLocked;
    }
}
-(void)driveViewTrunIndicatorViewTapped:(AMapNaviDriveView *)driveView
{
    [self.naviManager readNaviInfoManual];
}


#pragma mark-其他方法
//导航页面消失
-(void)naviViewDidDismiss
{
    [self didCloseAMapServiceNamager];
}
//导航页面弹出
-(void)naviViewDidPresent
{
    [self.naviManager startGPSNavi];
}






@end
