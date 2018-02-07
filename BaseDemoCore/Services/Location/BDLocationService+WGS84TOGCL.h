//
//  BDLocationService+WGS84TOGCL.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/22.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*经纬度转换*/
#import "BDLocationService.h"

@interface BDLocationService (WGS84TOGCL)
//是否越出国内经纬度
+(BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location;
//转GCL-02
+(CLLocationCoordinate2D)transformFromWGSToGCL:(CLLocationCoordinate2D)wgsLoc;



@end
