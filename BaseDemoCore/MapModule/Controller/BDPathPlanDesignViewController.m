//
//  BDPathPlanDesignViewController.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/13.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDPathPlanDesignViewController.h"
#import "BDPathPlanViewController.h"

#import "BDPlanTripModel.h"
#import "BDPlanTripPointModel.h"
#import "BDStationAnnotation.h"
#import "BDSpotModel.h"
#import "BDSpotFilter.h"
#import "BDUserSearchFilter.h"

#import "BDMapTripService.h"
#import "BDAMapService.h"
#import "BDLocationService.h"

#import "NSArray+BD.h"
#import "BDCustomAnnotationView.h"

@interface MAPointSetAnnoattion : MAPointAnnotation

@property (nonatomic,assign) NSInteger count;
@property (nonatomic,assign) MAMapRect unionSetRect;

@end

@implementation MAPointSetAnnoattion

@end


//路线处理结果
typedef NS_ENUM(UInt8,FinishedTripResult) {
    
    FinishedTripResult_SuspendNoPoints=0,//查找中断 没找到充电点
    FinishedTripResult_SuspendCannotArrive=1,//查找中断 剩余里程无法到达
    FinishedTripResult_Success=2, //已找到 但还未到达终点
    FinishedTripResult_Finished=3,//已经到达终点
};


@interface BDPathPlanDesignViewController ()<MAMapViewDelegate,BDCustomAnnotationViewDelegate>

@property (nonatomic,strong) MAMapView *mapView;

@property (nonatomic,strong) NSMutableArray<AMapPath *> *tripPaths; //途径点间的路径数组
@property (nonatomic,strong) NSMutableArray<BDPlanTripPointModel *> *tripPoints; //途径点数组 比tripPaths数量多一个 首尾不附带站点信息,中间则有
@property (nonatomic,strong) NSMutableArray<BDStationAnnotation *> *selectedAnnotations; //曾经选择过的点 为了回退
@property (nonatomic,strong) NSMutableArray<MAPointAnnotation *> *selectedPointAnnotations; //选择的途径点
@property (nonatomic,strong) NSMutableArray<NSNumber *> *selectedLeftMileages; //曾经选择过的剩余里程

@property (nonatomic,assign) BOOL designFinished; //是否设计完毕

@property (nonatomic,strong) BDStationAnnotation *currentSelectAnnotation; //当前地图标点
//地图元素
@property (nonatomic,strong) NSMutableArray<NSArray<MAPolyline *> *> *pathLines; //路线图
@property (nonatomic,strong) MACircle *circleOverlay;
@property (nonatomic,strong) MAPointAnnotation *farestAnnotation; //达到最大里程的点
@property (nonatomic,strong) MAPointAnnotation *fromAnnotation; //起点
@property (nonatomic,strong) MAPointAnnotation *toAnnotation; //终点
@property (nonatomic,assign) CGFloat zoomLevel; //记录地图缩放级别

@property (nonatomic,strong) NSMutableArray *nearbyAnnotations;
@property (nonatomic,strong) NSMutableSet <BDSpotModel *> *nearbySpots; //沿路充电点
@property (nonatomic,strong) NSMutableSet <BDSpotModel *> *filteredNearbySpots; //过滤后沿路充电点
@property (nonatomic,strong) NSMutableArray <MACircle *> *searchedCircles;
@property (nonatomic,strong) NSMutableArray <AMapGeoPolygon *> *avoidPolygons;
@property (nonatomic,strong) NSMutableArray <MAPolygon *> *debugPolygons;

@property (nonatomic,assign) CLLocationCoordinate2D naviLocation; //当前位置信息
@property (nonatomic,assign) BOOL isOut; //是否超出范围
@property (nonatomic,assign) NSInteger safeDistance;
@property (nonatomic,assign) NSInteger searchRadius;
@property (nonatomic,strong) BDSpotFilter *spotFilter;
@end

@implementation BDPathPlanDesignViewController

-(MAMapView *)mapView
{
    if (!_mapView)
    {
        _mapView=[[MAMapView alloc]initWithFrame:self.view.bounds];
        _mapView.delegate=self;
        [_mapView setRotateEnabled:NO];
        [_mapView setRotateCameraEnabled:NO];
        _mapView.showsScale=NO;
        _mapView.showsCompass=NO;

    }
    return _mapView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setupCustomUI];
    [self initializeViewData];
    // Do any additional setup after loading the view.
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self deSelectAnnotationsWithAnimated:NO];
}

-(void)initializeViewData
{
     //首次可添加引导视图
    
    self.searchRadius=[self pathSpotSearchRadius];
    self.safeDistance=[self carSafeDistance];
    
    self.searchedCircles=[NSMutableArray array];
    self.debugPolygons=[NSMutableArray array];
    self.avoidPolygons=[NSMutableArray array];
    self.nearbyAnnotations=[NSMutableArray array];
    self.nearbySpots=[NSMutableSet set];
    self.filteredNearbySpots=[NSMutableSet set];
    self.pathLines=[NSMutableArray array];
    
    self.tripPaths=[NSMutableArray array];
    self.selectedAnnotations=[NSMutableArray array];
    self.selectedPointAnnotations=[NSMutableArray array];
    self.selectedLeftMileages=[NSMutableArray array];
    if (!_tripModel)
    {
        //获取本地搜索偏好设置
        NSDictionary *attDic=[NSDictionary dictionaryWithContentsOfFile:[kMapPlanFolderPath stringByAppendingPathComponent:@"spotFilter"]];
        BDSpotFilter *filter=[[BDSpotFilter alloc]initWithAttributes:attDic];
        if (!attDic)
        {
            filter=[BDSpotFilter defaultFilter];
        }
        self.spotFilter=filter;
        
        self.tripPoints=[NSMutableArray array];
        if (_fromPosition&&_toPosition)
        {
            [_tripPoints addObject:_fromPosition];
            [_tripPoints addObject:_toPosition];
            self.title=[self navTitleForIndex:0];
        }
        [_selectedLeftMileages addObject:@(_currentLeftMileage)];
    }
    else
    {
        self.tripPoints=[NSMutableArray arrayWithArray:_tripModel.tripPoints];
        self.fromPosition=_tripPoints.firstObject;
        self.toPosition=_tripPoints.lastObject;
        self.designFinished=YES;
        
        if (_tripPoints.count>2)
        {
            //添加站点Annotation
            for (NSInteger i=0; i<_tripPoints.count-1; i++)
            {
                BDSpotModel *spot=_tripPoints[i].spot;
                BDStationAnnotation *annotation=[[BDStationAnnotation alloc]initWithSpotModel:spot];
                [_mapView addAnnotation:annotation];
            }
        }
    }
    
    //页面添加路线
    if (_originPath||_tripModel.tripPathString)
    {
        NSArray *originPathLine=nil;
        if (_originPath)
        {
            [_tripPaths addObject:_originPath];
            originPathLine=[BDMapTripService makePolyLinesWithAMapPath:_originPath];
        }
        else if (_tripModel.tripPathString)
        {
            originPathLine=[BDMapTripService makePolyLinesWithCoordinatesString:_tripModel.tripPathString];
        }
        [_pathLines addObject:originPathLine];
        self.fromAnnotation=[[MAPointAnnotation alloc]init];
        [_fromAnnotation setCoordinate:_fromPosition.location];
        _fromAnnotation.bd_exObject=@(1);
        self.toAnnotation=[[MAPointAnnotation alloc]init];
        [_toAnnotation setCoordinate:_toPosition.location];
        _toAnnotation.bd_exObject=@(2);
        [_mapView addAnnotations:@[_fromAnnotation,_toAnnotation]];
        [_mapView addOverlays:originPathLine];
    }
    
    //添加站点半页视图
    
    self.naviLocation=_fromPosition.location;
    
    //页面 路线存在则显示路线区域
    if (_pathLines.count>0)
    {
        NSArray *originPathLine=_pathLines[0];
        [_mapView setVisibleMapRect:[BDAMapService mapRectOfOverlays:originPathLine] edgePadding:UIEdgeInsetsMake(64+45, 25, 25, 25) animated:NO];
    }
    if (!_tripModel)
    {
        //默认执行一次站点搜索
        [self performSelector:@selector(findNextTripLocation) withObject:nil afterDelay:0.1];
    }
    else
    {
        [self.mapView setVisibleMapRect:[BDAMapService mapRectOfOverlayArrays:self.pathLines] edgePadding:UIEdgeInsetsMake(25, 25, 25, 25) animated:NO];
        [self performSelector:@selector(tripPathDesignFinished:) withObject:@"share" afterDelay:0.5];
    }
}
-(void)setupCustomUI
{
    [self.view addSubview:self.mapView];
    //去掉高德地图字样
    for (UIView *view in _mapView.subviews)
    {
        if ([view isKindOfClass:[UIImageView class]]&&view.width==_mapView.logoSize.width)
        {
            [view removeFromSuperview];
            break;
        }
    }
    _mapView.showsUserLocation=YES;
}

#pragma mark- Method
//路线上电站搜索半径
-(NSInteger)pathSpotSearchRadius
{
    return 500000;
}
//爱车安全行驶距离
-(NSInteger)carSafeDistance
{
    return 60000;
}
//选择充电时长
-(NSInteger)chargeTimeForSliderValue:(NSInteger)index
{
    NSArray *timeArray=@[@1,@2,@3,@5,@10000];
    return [[timeArray objectAtIndex:index] integerValue];
    
}
//页面标题
-(NSString *)navTitleForIndex:(NSInteger)index
{
    return [NSString stringWithFormat:@"第%zd次停留",index+1];
}
//
-(void)deSelectAnnotationsWithAnimated:(BOOL)animate
{
    MAPointAnnotation *annotation=[_mapView.selectedAnnotations bd_safeObjectAtIndex:0];
    if (annotation)
    {
        [_mapView deselectAnnotation:annotation animated:animate];
    }
}
-(void)makeFilterNearBySpots
{
    if (_spotFilter)
    {
        [_filteredNearbySpots setSet:[_nearbySpots objectsPassingTest:^BOOL(BDSpotModel * _Nonnull obj, BOOL * _Nonnull stop) {
            
            BOOL pass=YES;
            if ((_spotFilter.searchFilter.propertyType&2)==2)
            {
                pass &=((obj.propertyType&2)==2);
            }
            if (_spotFilter.searchFilter.operatorKeys.length>0)
            {
                pass &=([_spotFilter.searchFilter containOperators:obj.oreatorTypes]);
            }
            return pass;
            
        }]?:[NSSet set]];
    }
    else
    {
        [_filteredNearbySpots setSet:_nearbySpots];
    }
}
//尝试添加途径点 如果为nil则返回当前状态
-(void)tryToAddTripSpot:(BDSpotModel *)spot tripPoints:(NSArray *)tripPoints tripPaths:(NSArray *)tripPaths leftMileage:(NSInteger)leftMileage avoidPolygons:(NSArray<AMapGeoPolygon *> *)avoidPolygons complete:(void(^)(BOOL success,NSArray *modifiedTripPoints,NSArray *modifiedTripPath))complete
{
    NSMutableArray *tempTripPoints=[NSMutableArray arrayWithArray:tripPoints];
    __block NSMutableArray *tempTripPaths=[NSMutableArray arrayWithArray:tripPaths];
    if (!spot)
    {
        if (complete)
        {
            complete(YES,tripPoints,tripPaths);
        }
    }
    else
    {
        __block BDPlanTripPointModel *tripPoint=[[BDPlanTripPointModel alloc]init];
        tripPoint.spot=spot;
        tripPoint.leftMileage=leftMileage;
        //*******注意 存在Bug
        tripPoint.stayTime=[self chargeTimeForSliderValue:1];
        [tempTripPoints insertObject:tripPoint atIndex:tempTripPoints.count-1];
        //1、tripPaths移除最后一段路程
        __block AMapPath *lastPath=tempTripPaths.lastObject;
        [tempTripPaths removeLastObject];
        //2、分别请求路线1和路线2 顺序替代占位tripPath
        CLLocationCoordinate2D fromLocation=((BDPlanTripPointModel *)[tempTripPoints objectAtIndex:tempTripPoints.count-3]).location;
        CLLocationCoordinate2D stopLocation=((BDPlanTripPointModel *)[tempTripPoints objectAtIndex:tempTripPoints.count-2]).location;
        CLLocationCoordinate2D toLocation=((BDPlanTripPointModel *)[tempTripPoints objectAtIndex:tempTripPoints.count-1]).location;
        
        WEAKSELF_DEFINE
        [self requestDrivingPathWithFromLocation:fromLocation toLocation:stopLocation avoidPolygons:avoidPolygons complete:^(AMapPath *path1) {
            
            STRONGSELF_DEFINE
            if (path1)
            {
                [strongSelf requestDrivingPathWithFromLocation:stopLocation toLocation:toLocation avoidPolygons:avoidPolygons complete:^(AMapPath *path2) {
                    
                    if (path2)
                    {
                        [tempTripPaths addObject:path1];
                        [tempTripPaths addObject:path2];
                        BDPlanTripPointModel *lastPoint=[tempTripPoints objectAtIndex:([tempTripPoints indexOfObject:tripPoint]-1)];
                        tripPoint.distance=lastPoint.distance+path1.distance;
                        BDPlanTripPointModel *endPoint=[tempTripPoints lastObject];
                        endPoint.distance=tripPoint.distance+path2.distance;
                        if (complete)
                        {
                            complete(YES,tempTripPoints,tempTripPaths);
                        }
                    }
                    else
                    {
                        [tempTripPaths addObject:lastPath];
                        if (complete)
                        {
                            complete(NO,nil,nil);
                        }
                    }
                }];
            }
            else
            {
                [tempTripPaths addObject:lastPath];
                if (complete)
                {
                    complete(NO,nil,nil);
                }
            }
        }];

    }
}
//请求两个经纬坐标之间的驾驶路线
-(void)requestDrivingPathWithFromLocation:(CLLocationCoordinate2D)fromLocation toLocation:(CLLocationCoordinate2D)toLocation avoidPolygons:(NSArray<AMapGeoPolygon *> *)avoidPolygons complete:(void(^)(AMapPath *path))complete
{
    [[BDLocationService sharedService] searchDrivingPathFromCoordinate:fromLocation ToCoordinate:toLocation Strategy:_stregety AvoidPolygons:avoidPolygons complete:^(AMapRoute *route, NSError *error) {
        
        if (error==nil)
        {
            if (route.paths.count>0)
            {
                //默认选择第一条方案
                AMapPath *path=route.paths[0];
                if(complete)
                {
                    complete(path);
                }
            }
            else
            {
                if (complete)
                {
                    complete(nil);
                }
            }
        }
        else
        {
            if (complete)
            {
                complete(nil);
            }
        }
        
    }];
}
//聚合所有站点
-(void)clusterAllSpots
{
    @autoreleasepool{
        
        CGFloat y=_mapView.zoomLevel-(CGFloat)((NSInteger)_mapView.zoomLevel);
        CGFloat zoomLevel=(NSInteger)_mapView.zoomLevel;
        zoomLevel+=(y>=0.5)?0.5:0;
        if (zoomLevel!=_zoomLevel)
        {
            self.zoomLevel=zoomLevel;
            [_mapView removeAnnotations:_nearbyAnnotations];
            [_nearbyAnnotations removeAllObjects];
            NSInteger radius=40*_mapView.metersPerPointForCurrentZoom;
            if (_mapView.zoomLevel==_mapView.maxZoomLevel)
            {
                radius=0;
            }
            NSMutableDictionary *dict=[NSMutableDictionary dictionary];
            NSMutableDictionary *distanceDict=[NSMutableDictionary dictionary];
            NSMutableDictionary *spotDict=[NSMutableDictionary dictionary];
            NSMutableDictionary *spotSetDict=[NSMutableDictionary dictionary];
            for (BDSpotModel *model in _filteredNearbySpots)
            {
                spotDict[model.spotId]=model;
                NSMutableSet *set=[NSMutableSet set];
                NSString *setKey=[NSString stringWithFormat:@"%p",set];
                MAMapPoint spotPoint=MAMapPointForCoordinate(model.coordinate2D);
                CLLocationDistance totalDistance=0;
                for (BDSpotModel *subModel in _filteredNearbySpots)
                {
                    if (model!=subModel)
                    {
                        MAMapPoint subSpotPoint=MAMapPointForCoordinate(subModel.coordinate2D);
                        CLLocationDistance distance=MAMetersBetweenMapPoints(spotPoint, subSpotPoint);
                        if (distance<radius)
                        {
                            totalDistance+=distance;
                            [set addObject:subModel];
                        }
                    }
                }
                if (set.count==0)
                {
                    totalDistance=CLLocationDistanceMax;
                    distanceDict[setKey]=@(totalDistance);
                }
                else
                {
                    distanceDict[setKey]=@((totalDistance/set.count));
                }
                dict[model.spotId]=set;
                spotSetDict[setKey]=model;
            }
            NSMutableArray *allSetsArray=[NSMutableArray arrayWithArray:dict.allValues];
            while (allSetsArray.count>0)
            {
                [allSetsArray sortUsingComparator:^NSComparisonResult(NSSet *obj1, NSSet *obj2) {
                   
                    NSComparisonResult r=NSOrderedDescending;
                    if (obj1.count>obj2.count)
                    {
                        r=NSOrderedAscending;
                    }
                    else if(obj1.count==obj2.count)
                    {
                        CLLocationDistance distance1=[distanceDict[[NSString stringWithFormat:@"%p",obj1]] doubleValue];
                        CLLocationDistance distance2=[distanceDict[[NSString stringWithFormat:@"%p",obj2]] doubleValue];
                        if (distance1<distance2)
                        {
                            r=NSOrderedAscending;
                        }
                        else
                        {
                            r=NSOrderedSame;
                        }
                    }
                    return r;
                    
                }];
            }
        }
        
        
    }
}
#pragma mark-核心算法
-(void)handleTripPoints:(NSArray *)modifiedTripPoints tripPaths:(NSArray *)modifiedTripPaths selectedAnnotation:(BDStationAnnotation *)selectedAnnotation leftMileage:(NSInteger)leftMiLeage successFinishedBlock:(void(^)(FinishedTripResult result,id extraObject))successFinish
{
    //上一站充电里程是否可到达所选充电点
    BOOL lastPathCanArrive=YES;
    if (modifiedTripPaths.count>2)
    {
        AMapPath *lastTripPath=[modifiedTripPaths objectAtIndex:modifiedTripPaths.count-2];
        BDPlanTripPointModel *lastTripPoint=[modifiedTripPoints objectAtIndex:modifiedTripPoints.count-3];
        if (lastTripPoint.leftMileage<lastTripPath.distance)
        {
            lastPathCanArrive=NO;
        }
    }
    if (lastPathCanArrive)
    {
        //所选充电点后面的里程是否可到达
        WEAKSELF_DEFINE
        NSInteger roadMileage=leftMiLeage;
    [BDMapTripService findFarestLocationWhichExistSpotInRoadDistance:roadMileage
                                                            amapPath:modifiedTripPaths.lastObject
                                                              radius:weakSelf.searchRadius
                                                       finishedBlock:^(BOOL noNeedToFind,CLLocationCoordinate2D farestLocationCoor,NSInteger farestLocationRadius,NSArray *spots,NSArray<NSDictionary *> *searchCircles){
            STRONGSELF_DEFINE
            //返回的Spots中排除掉当前选择的目标站点
            NSArray *selectedSpots=[modifiedTripPoints subarrayWithRange:NSMakeRange(1, modifiedTripPoints.count-2)];
            spots=[spots filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                
                if ([evaluatedObject isKindOfClass:[BDSpotModel class]])
                {
                    BDSpotModel *spotModel=(BDSpotModel *)evaluatedObject;
                    return ![[selectedSpots valueForKeyPath:@"spot.spotId"] containsObject:spotModel.spotId];
                }
                else
                {
                    return YES;
                }
            }]];
            NSLog(@"周边区域充电点%zd",spots.count);
            //判断是否可直接到达
            AMapPath *lastTripPath=[modifiedTripPaths objectAtIndex:modifiedTripPaths.count-1];
            if (leftMiLeage>=lastTripPath.distance)
            {
                noNeedToFind=YES;
            }
            if (!noNeedToFind)
            {
                //判断最远能到达的位置安全距离范围内是否有终点
                MAMapPoint farestLocation=MAMapPointForCoordinate(farestLocationCoor);
                MAMapPoint endLocation=MAMapPointForCoordinate(weakSelf.toPosition.location);
                CLLocationDistance distance=MAMetersBetweenMapPoints(farestLocation, endLocation);
                if (distance<=farestLocationRadius)
                {
                    noNeedToFind=YES;
                }
            }
            weakSelf.designFinished=noNeedToFind;
            if (noNeedToFind||spots.count>0)
            {
                //所选择的Spot可进入路线
                [weakSelf cleanLastPathTripUI];
                if (selectedAnnotation)
                {
                    //绘制所选择的充电点
                    MAPointAnnotation *selectPointAnnotation=[[MAPointAnnotation alloc]init];
                    [selectPointAnnotation setCoordinate:selectedAnnotation.coordinate];
                    selectPointAnnotation.bd_exObject=@3;
                    [weakSelf.mapView addAnnotation:selectPointAnnotation];
                    
                    [weakSelf.selectedAnnotations addObject:selectedAnnotation];
                    [weakSelf.selectedLeftMileages addObject:@(leftMiLeage)];
                    [weakSelf.selectedPointAnnotations addObject:selectPointAnnotation];
                    weakSelf.currentSelectAnnotation=nil;
                }
                [weakSelf.tripPoints setArray:modifiedTripPoints];
                [weakSelf.tripPaths setArray:modifiedTripPaths];
                
                //绘制所选择的两条路线
                AMapPath *path2=[weakSelf.tripPaths bd_safeObjectAtIndex:weakSelf.tripPaths.count-2];
                if (path2)
                {
                    NSArray *path2Overlay=[BDMapTripService makePolyLinesWithAMapPath:path2];
                    [weakSelf.pathLines addObject:path2Overlay];
                    [weakSelf.mapView addOverlays:path2Overlay];
                }
                
                AMapPath *path1=[weakSelf.tripPaths bd_safeObjectAtIndex:weakSelf.tripPaths.count-1];
                if (path1)
                {
                    NSArray *path1Overlay=[BDMapTripService makePolyLinesWithAMapPath:path1];
                    [weakSelf.pathLines addObject:path1Overlay];
                    [weakSelf.mapView addOverlays:path1Overlay];
                }
                
                [weakSelf updateMapViewUI];
            }
            
            if (!noNeedToFind)
            {
                if (spots.count>0)
                {
                    //绘制新的途径点
                    weakSelf.farestAnnotation=[[MAPointAnnotation alloc]init];
                    [weakSelf.farestAnnotation setCoordinate:farestLocationCoor];
                    [weakSelf.mapView addAnnotation:weakSelf.farestAnnotation];
                    
                    //绘制新圆圈
                    weakSelf.circleOverlay =[MACircle circleWithCenterCoordinate:farestLocationCoor radius:farestLocationRadius];
                    [weakSelf.mapView addOverlay:weakSelf.circleOverlay];
                    [weakSelf.searchedCircles removeAllObjects];
                    
                    [weakSelf.nearbySpots addObjectsFromArray:spots];
                    [weakSelf makeFilterNearBySpots];
                    
                    //调整镜头
                    if (weakSelf.circleOverlay)
                    {
                        BDPlanTripPointModel *beginPoint=(BDPlanTripPointModel *)[weakSelf.tripPoints objectAtIndex:weakSelf.tripPoints.count-2];
                        MAMapPoint tripBeginPoint=MAMapPointForCoordinate(beginPoint.location);
                        MAMapRect tripBeginRect=(MAMapRect){tripBeginPoint,{1,1}};
                        MAMapRect camerRect=MAMapRectUnion([BDAMapService mapRectOfOverlays:@[weakSelf.circleOverlay]], tripBeginRect);
                        [weakSelf.mapView setVisibleMapRect:camerRect edgePadding:UIEdgeInsetsMake(25, 25, 25, 25) animated:YES];
                    }
                    
                    if (successFinish)
                    {
                        successFinish(FinishedTripResult_Success,searchCircles);
                    }
                }
                else
                {
                    if (successFinish)
                    {
                        successFinish(FinishedTripResult_SuspendNoPoints,nil);
                    }

                }
            }
            else
            {
                if (successFinish)
                {
                    successFinish(FinishedTripResult_Finished,nil);
                }
            }
            
            
        }];
        
    }
    else
    {
        if (successFinish)
        {
            successFinish(FinishedTripResult_SuspendCannotArrive,nil);
        }
    }
    
    
}

#pragma mark-交互事件
//清空上次的路线视图
-(void)cleanLastPathTripUI
{
    //清除最大里程点
    [_mapView removeAnnotation:_farestAnnotation];
    //清除可选充电点
    [_mapView removeAnnotations:_nearbyAnnotations];
    [_nearbyAnnotations removeAllObjects];
    [_nearbySpots removeAllObjects];
    [_filteredNearbySpots removeAllObjects];
    //清除圆圈
    [_mapView removeOverlay:self.circleOverlay];
    [_mapView removeOverlays:self.searchedCircles];
    //清除前一条路径
    NSArray *lastPathLine=_pathLines.lastObject;
    [_mapView removeOverlays:lastPathLine];
    [_pathLines removeObject:lastPathLine];
}
-(void)updateMapViewUI
{
    
}
//AMapPath上找到停靠点 并标注半径范围内的充电点
-(void)findNextTripLocation
{
    self.zoomLevel=0;
    WEAKSELF_DEFINE
    [self tryToAddTripSpot:_currentSelectAnnotation.spot tripPoints:_tripPoints tripPaths:_tripPaths leftMileage:_currentLeftMileage avoidPolygons:_avoidPolygons complete:^(BOOL success, NSArray *modifiedTripPoints, NSArray *modifiedTripPath) {
        
        STRONGSELF_DEFINE
        if (success)
        {
            [strongSelf handleTripPoints:modifiedTripPoints tripPaths:modifiedTripPath selectedAnnotation:strongSelf.currentSelectAnnotation leftMileage:strongSelf.currentLeftMileage successFinishedBlock:^(FinishedTripResult result, id extraObject) {
               
                if (!strongSelf.isOut)
                {
                    switch (result) {
                        case FinishedTripResult_SuspendCannotArrive:
                            NSLog(@"剩余里程无法到达该充电点");
                            break;
                        case FinishedTripResult_SuspendNoPoints:
                        {
                            NSLog(@"剩余里程未找到合适的充电点，可调整充电时间或者更换其他充电点");
                            [strongSelf.avoidPolygons removeAllObjects];
                        }
                            break;
                        case FinishedTripResult_Success:
                        {
                            [strongSelf.avoidPolygons removeAllObjects];
                        }
                            break;
                        case FinishedTripResult_Finished:
                        {
                            NSLog(@"无需再次充电即刻到达 行程规划成功");
                        }
                            break;
                        default:
                            break;
                    }
                }
                
            }];
        }
        else
        {
            NSLog(@"无法查询行车路线");
        }
        
        
    }];
    
}
//下一步站点设计
-(void)nextButtonDesignDidPressed:(id)sender
{
    [_mapView removeOverlays:self.debugPolygons];
    [self.debugPolygons removeAllObjects];
    [self findNextTripLocation];
    
}
//跳转到结果页面
-(void)pushToPathPlanResultViewController
{
    NSInteger duration=0;
    for (AMapPath *path in _tripPaths)
    {
        duration+=path.duration;
    }
    BDPlanTripModel *model=[[BDPlanTripModel alloc]initWithTitle:@"" avatarUrl:@"" tripPoints:_tripPoints tripPathString:[BDMapTripService makeCoordinatesStringWithAMapPathsArray:_tripPaths] timeStampString:[@([[NSDate date] timeIntervalSince1970]) stringValue] duration:duration];
    if (model)
    {
        
        
    }
    
}
//路线设计完毕 可执行分享、保存等后续操作
-(void)tripPathDesignFinished:(NSString *)afterFinishedKey
{
    if ([afterFinishedKey isEqualToString:@"save"])
    {
        NSLog(@"保存路线");
    }
    else if ([afterFinishedKey isEqualToString:@"share"])
    {
        NSLog(@"分享路线");
    }
    else
    {
        
    }
    NSArray *overlays=_mapView.overlays;
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView addOverlays:overlays];
    
    if (!_tripModel)
    {
        [_mapView setVisibleMapRect:[BDAMapService mapRectOfOverlayArrays:self.pathLines] edgePadding:UIEdgeInsetsMake(25, 25, 25, 25) animated:YES];
        
    }
}

#pragma mark-MAMapViewDelegate
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    self.naviLocation=userLocation.coordinate;
    _mapView.showsUserLocation=NO;
}
-(void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    if ([view isKindOfClass:[MACustomCalloutView class]])
    {
        if (view.annotation)
        {
            
        }
    }
    else
    {
        //点击到聚合点
        if ([view.annotation isKindOfClass:[MAPointSetAnnoattion class]])
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                MAMapRect rect=((MAPointSetAnnoattion *)view.annotation).unionSetRect;
                [_mapView setVisibleMapRect:rect edgePadding:UIEdgeInsetsMake(20, 30, 30, 30) animated:YES];
            });
        }
    }
}
-(void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view
{
    if ([view isKindOfClass:[MACustomCalloutView class]])
    {
        
    }
}
-(MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if (overlay==_circleOverlay)
    {
        MACircle *circle=(MACircle *)overlay;
        MACircleRenderer *render=[[MACircleRenderer alloc]initWithCircle:circle];
        render.lineWidth=1;
        render.fillColor=[UIColor colorWithRed:0.3 green:0.2 blue:0.1 alpha:0.3];
        render.strokeColor=[UIColor blueColor];
        return render;
    }
    else if ([overlay isKindOfClass:[MACircle class]])
    {
        MACircle *circle=(MACircle *)overlay;
        MACircleRenderer *render=[[MACircleRenderer alloc]initWithCircle:circle];
        render.lineWidth=1;
        render.fillColor=[UIColor redColor];
        render.strokeColor=[UIColor purpleColor];
        return render;
    }
    else if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolyline *polyLine=(MAPolyline *)overlay;
        MAPolylineRenderer *render=[[MAPolylineRenderer alloc]initWithPolyline:polyLine];
        render.strokeColor=[UIColor blueColor];
        render.lineWidth=5;
        render.lineDash=!_designFinished;
        render.lineJoinType=kMALineJoinMiter;
        render.lineCapType=kMALineCapSquare;
        return render;
    }
    return nil;
}
-(MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if (annotation==_farestAnnotation)
    {
        //最远距离点
        return nil;
    }
    if([annotation isMemberOfClass:[MAPointAnnotation class]])
    {
        //起点 终点 红色中途点
        MAPointAnnotation *pointAnnotation=(MAPointAnnotation *)annotation;
        NSString *identity=[(NSNumber *)pointAnnotation.bd_exObject stringValue];
        MAAnnotationView *annotationView=(MAAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identity];
        if (!annotationView)
        {
            annotationView=[[MAAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:identity];
            annotationView.centerOffset=CGPointMake(0, -39/2);
        }
        switch ([(NSNumber *)pointAnnotation.bd_exObject integerValue]) {
            case 1:
                annotationView.image=kImage(@"pathplanAnnotationFrom");
                break;
            case 2:
                annotationView.image=kImage(@"pathplanAnnotationTo");
                break;
            case 3:
                annotationView.image=kImage(@"pathplanAnnotationSelect");
                break;
            default:
                break;
        }
        return annotationView;
    }
    else if ([annotation isMemberOfClass:[MAPointSetAnnoattion class]])
    {
        //聚合点
        NSString *identity=@"annotationSet";
        MAPointSetAnnoattion *singgleAnnotation=(MAPointSetAnnoattion *)annotation;
        MAAnnotationView *annotationView=(MAAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identity];
        UILabel *label=[annotationView viewWithTag:100];
        if (!annotationView)
        {
            annotationView=[[MAAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:identity];
            annotationView.centerOffset=CGPointMake(0, -39/2);
            annotationView.image=kImage(@"pathplanAnnotationSelect");
            label=[[UILabel alloc]initWithFrame:CGRectMake(1, -2, 30, 32)];
            [annotationView addSubview:label];
            label.textColor=[UIColor grayColor];
            label.tag=100;
            
        }
        label.text=[NSString stringWithFormat:@"%zd",singgleAnnotation.count];
        return annotationView;
    }
    else if ([annotation isMemberOfClass:[BDStationAnnotation class]])
    {
        
        //可以点击的充电点
        BDStationAnnotation *singleAnnotation=(BDStationAnnotation *)annotation;
        BDSpotModel *spot=singleAnnotation.spot;
        NSString *identity=@"customAnnotationView";
        if (!_tripModel)
        {
            BDCustomAnnotationView *customAnnotationView=(BDCustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identity];
            if (!customAnnotationView)
            {
                customAnnotationView=[[BDCustomAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:identity];
                customAnnotationView.delegate=self;
            }
            [customAnnotationView setupBackImage:spot.spotAnnotationBackgroundImage iconImage:spot.spotTypeIconImage detailText:spot.spotSummary];
        }
        
    }
    return nil;
}
-(void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction
{
    [self clusterAllSpots];
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

#pragma mark-设计规划最优路线--思路
/*
 前提条件:根据高德地图(其他三方地图)获取推荐的行车路线
 页面所需参数：地图路线、起点、终点、爱车最大可行里程、当前爱车剩余里程
 (起点、终点)入数组(TripPoints 路线沿途停留站点)
 (出发时的剩余里程)入数组(SelectedLeftMileages 所选择过的剩余里程)
 (所推荐路线)入数组(TripPaths)
 (推荐路线的地图元素《多段线》)入数组(PathLines 收尾相连线集合)
 1.根据TripPoints、TripPaths、LeftMileage处理筛选逻辑
 1.1判断所选站点后面的里程是否可到达
 1.1.1 获取最远的存在充电点的位置（路线、搜索半径、行走里程）
    高德steps(116.39785,39.90012;116.399033,39.90015;116.399666,39.900188)
 
 */





































