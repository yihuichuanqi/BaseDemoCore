//
//  BDPathPlanViewController.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/12.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDPathPlanViewController.h"
#import "BDPathPlanDesignViewController.h"

#import <MAMapKit/MAMapKit.h>

#import "BDLocationService.h"
#import "BDMapTripService.h"
#import "BDAMapService.h"

#import "BDPlanTripPointModel.h"
#import "BDPlanTripModel.h"
#import "BDGeoObject.h"

@interface BDPathPlanViewController ()<MAMapViewDelegate>

@property (nonatomic,strong) MAMapView *mapView;

@property (nonatomic,strong) UIImageView *centerAnnotationImage;//中心起点
@property (nonatomic,strong) UIButton *beginNavBtn;//导航按钮
@property (nonatomic,strong) UIButton *navLocationBtn; //定位按钮

@property (nonatomic,strong) BDPlanTripPointModel *fromPosition; //起点
@property (nonatomic,strong) BDPlanTripPointModel *toPosition;//终点
@property (nonatomic,strong) NSMutableArray<MAPolyline *> *originLandPathLines; //最初计划的路面线路
@property (nonatomic,strong) AMapPath *path;//所选路线

@property (nonatomic,assign) BOOL isSelectToLocation; //记录当前是否是在选择终点位置
@property (nonatomic,assign) CLLocationCoordinate2D currentLocation;//记录当前位置信息
@property (nonatomic,assign) NSInteger leftMileage; //剩余里程
@property (nonatomic,assign) NSInteger carMileage;//爱车最大可行里程

@property (nonatomic,assign) NSInteger aMapStrategy; //高德驾驶策略(0高速优先 6不走高速)
//目前仅两种策略
@property (nonatomic,strong) AMapPath *leftStrategyPath;
@property (nonatomic,strong) AMapPath *rightStrategyPath;
@property (nonatomic,strong) NSMutableArray<MAPolyline *> *leftStrategyPathLines;//高速优先线路
@property (nonatomic,strong) NSMutableArray<MAPolyline *> *rightStrategyPathLines;//不走高速线路

@end

@implementation BDPathPlanViewController

-(MAMapView *)mapView
{
    if (!_mapView)
    {
        _mapView=[[MAMapView alloc]initWithFrame:self.view.bounds];
        _mapView.delegate=self;
        [_mapView setRotateEnabled:NO];
        [_mapView setRotateCameraEnabled:NO];
        _mapView.showsCompass=NO;

    }
    return _mapView;
}
-(UIImageView *)centerAnnotationImage
{
    if (!_centerAnnotationImage)
    {
        _centerAnnotationImage=[[UIImageView alloc]init];
        _centerAnnotationImage.image=kBDImage(@"pathplanAnnotationFrom");
        _centerAnnotationImage.hidden=YES;
    }
    return _centerAnnotationImage;
}
-(UIButton *)beginNavBtn
{
    if (!_beginNavBtn)
    {
        _beginNavBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [_beginNavBtn setImage:kBDImage(@"tripPlan_start") forState:UIControlStateNormal];
        [_beginNavBtn sizeToFit];
        _beginNavBtn.hidden=YES;
        [_beginNavBtn addTarget:self action:@selector(beginMapNavigate) forControlEvents:UIControlEventTouchUpInside];
    }
    return _beginNavBtn;
}
-(UIButton *)navLocationBtn
{
    if (!_navLocationBtn)
    {
        _navLocationBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [_navLocationBtn setImage:kBDImage(@"location_normal") forState:UIControlStateNormal];
        [_navLocationBtn setImage:kBDImage(@"location_press") forState:UIControlStateHighlighted];
        [_navLocationBtn sizeToFit];
        [_navLocationBtn setFrame:UIEdgeInsetsInsetRect(_navLocationBtn.frame, UIEdgeInsetsMake(-5, -5, -5, -5))];
        [_navLocationBtn addTarget:self action:@selector(navigateLocationButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _navLocationBtn;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建存储目录
    NSLog(@"存储目录====：%@",kMapPlanFolderPath);
    if (![[NSFileManager defaultManager] fileExistsAtPath:kMapPlanFolderPath isDirectory:NULL])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:kMapPlanFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    [self setupCustomUI];
    [self initializeViewData];
    
    if (self.fromPosition&&self.toPosition)
    {
        [self beginMapNavigate];
    }
    
    
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshOriginAndDestiantionView];
}


#pragma mark-初始化页面布局及数据
-(void)initializeViewData
{
    self.title=@"手动规划";
    self.currentLocation=kCLLocationCoordinate2DInvalid;
    
    self.carMileage=[[kMapPlanFolderPath stringByAppendingPathComponent:@"carMileage"] integerValue];
    if (_carMileage==0)
    {
        self.carMileage=300000;
    }
    _mapView.showsUserLocation=YES;
    
}
-(void)setupCustomUI
{
    [self.view addSubview:self.mapView];
    //去掉高德字样
    for (UIView *view in _mapView.subviews)
    {
        if ([view isKindOfClass:[UIImageView class]]&&view.width==_mapView.logoSize.width)
        {
            [view removeFromSuperview];
            break;
        }
    }
    
    [self.view addSubview:self.centerAnnotationImage];
    [self.centerAnnotationImage mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.center.equalTo(self.mapView);
    }];
    [self.view addSubview:self.beginNavBtn];
    [self.beginNavBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(self.centerAnnotationImage.mas_top).with.offset(5);
        make.centerX.equalTo(self.centerAnnotationImage.mas_centerX);
    }];
    [self.view addSubview:self.navLocationBtn];
    [self.navLocationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.right.equalTo(self.mapView.mas_right).with.offset(-20);
        make.bottom.equalTo(self.mapView.mas_bottom).with.offset(-15);
        
    }];
}

-(UIButton *)set_RightButton
{
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"设计" forState:UIControlStateNormal];
    btn.frame=CGRectMake(0, 0, 60, 30);
    btn.backgroundColor=[UIColor redColor];
    [btn sizeToFit];
    return btn;
}
-(void)right_Button_Event:(UIButton *)sender
{
    [self mapPathFinishedToDesignSpotInfo];
}

//重新刷新页面UI
-(void)refreshOriginAndDestiantionView
{
    self.centerAnnotationImage.image=_isSelectToLocation?kBDImage(@"pathplanAnnotationTo"):kBDImage(@"pathplanAnnotationFrom");
    if (!_isSelectToLocation)
    {
        [_mapView setCenterCoordinate:_fromPosition.location animated:NO];
    }
    else
    {
        [_mapView setCenterCoordinate:_toPosition.location animated:NO];
    }
    
#ifdef DEBUG
    //保存起始点数据
#endif
    
    if(!self.beginNavBtn.hidden)
    {
        //如果起始坐标合法 则显示跳动效果 提醒前去规划路线
        if (_fromPosition&&_toPosition)
        {
            [_mapView addSubview:self.beginNavBtn];
            self.beginNavBtn.hidden=NO;
            [self.beginNavBtn.layer removeAnimationForKey:@"jump"];
            CAKeyframeAnimation *jumpAnimation=[CAKeyframeAnimation animationWithKeyPath:@"position.y"];
            jumpAnimation.values=@[@(self.beginNavBtn.layer.position.y),@(self.beginNavBtn.layer.position.y-2)];
            jumpAnimation.duration=0.2;
            jumpAnimation.repeatCount=2;
            jumpAnimation.autoreverses=YES;
            jumpAnimation.removedOnCompletion=NO;
            
            CAAnimationGroup *group=[CAAnimationGroup animation];
            group.removedOnCompletion=NO;
            group.repeatCount=NSIntegerMax;
            group.duration=2*jumpAnimation.duration*jumpAnimation.repeatCount+0.5;
            group.animations=@[jumpAnimation];
            [self.beginNavBtn.layer addAnimation:group forKey:@"jump"];
        }
    }
    else
    {
        [self beginMapNavigate];
    }
    
    
    
}

#pragma mark-Set Method
-(void)setCarMileage:(NSInteger)carMileage
{
    _carMileage=carMileage;
    
}
-(void)setIsSelectToLocation:(BOOL)isSelectToLocation
{
    _isSelectToLocation=isSelectToLocation;
}

-(void)setupMapOrigin:(BDPathPlanPOIModel *)origin andDestination:(BDPathPlanPOIModel *)destination
{
    self.fromPosition=[BDPlanTripPointModel pointWithPathPlanPOI:origin];
    self.toPosition=[BDPlanTripPointModel pointWithPathPlanPOI:destination];
    self.isSelectToLocation=self.toPosition!=nil;
}
-(void)changeToSelectStrategyState
{
    //设置子视图显示隐藏效果
    [self animationToShowView:nil animate:NO showOrHide:NO aboveHeight:0 complete:nil];
    
    CGFloat bottomFloat=(MIN(10, 15)+15);
    [self.navLocationBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.mapView.mas_right).with.offset(-20);
        make.bottom.equalTo(self.mapView.mas_bottom).with.offset(-bottomFloat);
    }];

}
-(void)resetToSelectLocationState
{
    self.beginNavBtn.hidden=NO;
    self.isSelectToLocation=NO;
    self.centerAnnotationImage.hidden=NO;
    self.centerAnnotationImage.image=kBDImage(@"pathplanAnnotationFrom");
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
    
    //设置子视图显示隐藏效果
    
}
#pragma mark-交互事件
//动画显示或隐藏指定视图
-(void)animationToShowView:(UIView *)view animate:(BOOL)animate showOrHide:(BOOL)show aboveHeight:(CGFloat)aboveHeight complete:(void(^)(void))complete
{
    if(!view)
    {
        return;
    }
    CGFloat fromTop=show?_mapView.height:(_mapView.height-view.height-aboveHeight);
    CGFloat toTop=!show?_mapView.height:(_mapView.height-view.height-aboveHeight);
    [view setTop:fromTop];
    if (animate)
    {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [view setTop:toTop];
        } completion:^(BOOL finished) {
           
            if (complete)
            {
                complete();
            }
        }];
    }
    else
    {
        [view setTop:toTop];
    }
}
//切换路线策略（）
-(void)changedPathStrategyDidPressedWithGaodeStrategyTag:(NSInteger)strategyTag
{
    if (strategyTag==0)
    {
        //高德地图 高速优先
        self.aMapStrategy=0;
        self.originLandPathLines=_leftStrategyPathLines;
        self.path=_leftStrategyPath;
    }
    else
    {
        self.aMapStrategy=6;
        self.originLandPathLines=_rightStrategyPathLines;
        self.path=_rightStrategyPath;
    }
    
    if (_mapView.overlays)
    {
        [_mapView removeOverlays:_mapView.overlays];
    }
    NSMutableArray<MAPolyline *> *selectedLines=strategyTag==0?_leftStrategyPathLines:_rightStrategyPathLines;
    NSMutableArray<MAPolyline *> *unSelectedLines=strategyTag==0?_rightStrategyPathLines:_leftStrategyPathLines;
    [_mapView addOverlays:selectedLines];
    [_mapView addOverlays:unSelectedLines];
    
}
//重新定位当前位置
-(void)navigateLocationButtonPressed
{
    [self resetToSelectLocationState];
    [_mapView setCenterCoordinate:_mapView.userLocation.location.coordinate animated:YES];
}
//开始导航
-(void)beginMapNavigate
{
    if (_fromPosition&&_toPosition&&_fromPosition.address.length>0&&_toPosition.address.length>0)
    {
        
        //有效起始点
        WEAKSELF_DEFINE
        [self requestDrivingPathInfoWithComplete:^(BOOL success) {
            
            STRONGSELF_DEFINE
            if(success)
            {
                [strongSelf drawMapPathLines];
            }
            
        }];
    }
    else
    {
        
    }
}
//绘制地图路线
-(void)drawMapPathLines
{
    self.beginNavBtn.hidden=YES;
    self.centerAnnotationImage.hidden=YES;
    [_mapView removeAnnotations:_mapView.annotations];
    
    //修改策略选项
    [self changedPathStrategyDidPressedWithGaodeStrategyTag:_aMapStrategy==0?0:6];
    //设置地图显示区域
    MAMapRect rect1=[BDAMapService mapRectOfOverlays:_leftStrategyPathLines];
    MAMapRect rect2=[BDAMapService mapRectOfOverlays:_rightStrategyPathLines];
    MAMapRect rect=MAMapRectUnion(rect1, rect2);//两种路线交汇重叠区域
    [_mapView setVisibleMapRect:rect edgePadding:UIEdgeInsetsMake(130, 30, 30, 30) animated:YES];
    
    //添加起始点
    MAPointAnnotation *fromAnnotation=[[MAPointAnnotation alloc]init];
    [fromAnnotation setCoordinate:_fromPosition.location];
    MAPointAnnotation *toAnnotation=[[MAPointAnnotation alloc]init];
    [toAnnotation setCoordinate:_toPosition.location];
    toAnnotation.bd_exObject=@YES;
    [_mapView addAnnotations:@[fromAnnotation,toAnnotation]];
    
    //移动定位坐标图片位置
    [self animationToShowView:self.navLocationBtn animate:YES showOrHide:YES aboveHeight:50 complete:nil];
    
}
//请求路线坐标点数据
-(void)requestDrivingPathInfoWithComplete:(void(^)(BOOL success))complete
{
    WEAKSELF_DEFINE
    //首先策略0
    [[BDLocationService sharedService] searchDrivingPathFromCoordinate:_fromPosition.location ToCoordinate:_toPosition.location Strategy:0 AvoidPolygons:nil complete:^(AMapRoute *route, NSError *error) {
        
        STRONGSELF_DEFINE
        if (route.paths.count>0)
        {
            //默认选择第一条方案
            AMapPath *strategy0Path=route.paths[0];
            strongSelf.leftStrategyPath=strategy0Path;
            strongSelf.leftStrategyPathLines=[BDMapTripService makePolyLinesWithAMapPath:strategy0Path];
            
            //其次策略6
            [[BDLocationService sharedService] searchDrivingPathFromCoordinate:strongSelf.fromPosition.location ToCoordinate:strongSelf.toPosition.location Strategy:6 AvoidPolygons:nil complete:^(AMapRoute *route, NSError *error) {
                
                if (route.paths.count>0)
                {
                    AMapPath *strategy6Path=route.paths[0];
                    strongSelf.rightStrategyPath=strategy6Path;
                    strongSelf.rightStrategyPathLines=[BDMapTripService makePolyLinesWithAMapPath:strategy6Path];
                    for (MAPolyline *line in strongSelf.rightStrategyPathLines)
                    {
                        line.bd_exObject=@6;
                    }
                }
                if (complete)
                {
                    complete(!(strongSelf.leftStrategyPath==nil||strongSelf.rightStrategyPathLines==nil));
                }
                
            }];
            
        }
        else
        {
            if (complete)
            {
                complete(NO);
            }
        }
        
        
    }];
}
//请求地址信息
-(void)requestGeoCodeCurrentLocationAfterDelay:(NSTimeInterval)delay
{
    [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(geoCurrentLocation:) object:nil];
    [self performSelector:@selector(geoCurrentLocation:) withObject:@(_isSelectToLocation) afterDelay:delay];
}
-(void)geoCurrentLocation:(NSNumber *)isSelectToLocation
{
    WEAKSELF_DEFINE
    [[BDLocationService sharedService] startGeoCode:_currentLocation Radius:100 complete:^(BOOL success, BDGeoObject *geoObject) {
       
        STRONGSELF_DEFINE
        if (success)
        {
            if (strongSelf.isSelectToLocation==[isSelectToLocation boolValue])
            {
                AMapPOI *poi=[BDGeoObject mapPOIFromGeoObject:geoObject];
                [strongSelf refreshGeoResultWithPOI:poi];
            }
        }
    }];
}
-(void)refreshGeoResultWithPOI:(AMapPOI *)poi
{
    if (!_isSelectToLocation)
    {
        self.fromPosition=[BDPlanTripPointModel objectFromAmapPOI:poi];
    }
    else
    {
        self.toPosition=[BDPlanTripPointModel objectFromAmapPOI:poi];
    }
}
//地图路线选择完毕 进而设计路线沿途站点
-(void)mapPathFinishedToDesignSpotInfo
{
    BDPathPlanDesignViewController *designPathVC=[[BDPathPlanDesignViewController alloc]init];
    designPathVC.fromPosition=_fromPosition;
    designPathVC.toPosition=_toPosition;
    designPathVC.originPath=_path;
//    designPathVC.currentLeftMileage=_leftMileage;
    designPathVC.currentLeftMileage=340000;
//    designPathVC.carMileage=_carMileage;
    designPathVC.carMileage=500000;
    designPathVC.stregety=_aMapStrategy;
    [self.navigationController pushViewController:designPathVC animated:YES];
}
#pragma mark-MAMapViewDelegate
-(void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    self.currentLocation=mapView.region.center;
    if (!_beginNavBtn.hidden&&animated)
    {
        [self requestGeoCodeCurrentLocationAfterDelay:1];
    }
}
//位置或设备方向发生变化回调
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (userLocation)
    {
        _mapView.showsUserLocation=NO;
    }
    if (userLocation.location)
    {
        if (!CLLocationCoordinate2DIsValid(_currentLocation))
        {
            self.currentLocation=userLocation.coordinate;
        }
        if(!_fromPosition)
        {
            MACoordinateRegion region;
            MACoordinateSpan span;
            span.latitudeDelta=0.1;
            span.longitudeDelta=0.1;
            region.span=span;
            region.center=_currentLocation;
            
            [_mapView setRegion:region animated:NO];
            [_mapView regionThatFits:region];
            [self geoCurrentLocation:@(_isSelectToLocation)];
        }
        
    }
}
-(MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    MAPolyline *polyline=(MAPolyline *)overlay;
    MAPolylineRenderer *renderer=[[MAPolylineRenderer alloc]initWithPolyline:polyline];
    renderer.lineWidth=4;
    renderer.lineDash=YES;
    renderer.lineJoinType=kMALineJoinMiter;
    renderer.lineCapType=kMALineCapSquare;
    
    if ([(NSNumber *)polyline.bd_exObject integerValue]==_aMapStrategy)
    {
        //被选择的线路颜色样式
        renderer.strokeColor=[UIColor redColor];
    }
    else
    {
        renderer.strokeColor=[UIColor lightGrayColor];
    }
    return renderer;
}
-(MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAUserLocation class]])
    {
        return nil;
    }
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        MAPointAnnotation *pointAnnotation=(MAPointAnnotation *)annotation;
        NSString *identity=@"bdAnnotationView";
        MAAnnotationView *annotationView=(MAAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identity];
        if (!annotationView)
        {
            annotationView=[[MAAnnotationView alloc]initWithAnnotation:pointAnnotation reuseIdentifier:identity];
            annotationView.userInteractionEnabled=NO;
            annotationView.centerOffset=CGPointMake(0, -39/2);
        }
        
        annotationView.image=[(NSNumber *)pointAnnotation.bd_exObject boolValue]?kBDImage(@"pathplanAnnotationTo"):kBDImage(@"pathplanAnnotationFrom");
        return annotationView;

    }
    return nil;
}








- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
