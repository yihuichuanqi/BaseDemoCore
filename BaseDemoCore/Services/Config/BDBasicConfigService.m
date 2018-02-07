//
//  BDBasicConfigService.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/18.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDBasicConfigService.h"
#import "BDVehicleConfigService.h"
#import "BDImageLoader.h"

#import "BDSpotTypeInfo.h"
#import "BDVehicleBrandModel.h"
#import "NSDictionary+BD.h"

@interface BDBasicConfigService ()

//站点类型保存字典
@property (nonatomic,strong) NSDictionary<NSNumber *, BDSpotTypeInfo *> *spotTypeInfoDict;
//保存品牌id
@property (nonatomic,strong) NSArray<NSString *> *socialBrandIdArray;

@end

@implementation BDBasicConfigService

+(instancetype)sharedService
{
    static BDBasicConfigService *service=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service=[[BDBasicConfigService alloc]init];
    });
    return service;
}
-(void)loadConfigWithAttributes:(id)attributes
{
    /*
     {
     "APP_NAME" = "<null>";
     clusterAnnotation = "icon/clusterAnnotation.png";
     countryList =     (
     {
     code = 86;
     name = "\U4e2d\U56fd";
     },
     {
     code = 852;
     name = "\U9999\U6e2f";
     },
     {
     code = 853;
     name = "\U6fb3\U95e8";
     },
     {
     code = 886;
     name = "\U53f0\U6e7e";
     }
     );
     imageRootUrl = "http://cl-fdfs.chargerlink.com/";
     pathPlanningHotCity =     (
     110000,
     310000,
     440400,
     420700,
     430700,
     512000,
     620400
     );
     shareDefaultImage = "http://cl-fdfs.chargerlink.com/img/ic_launcher.png";
     sharePageHost = "https://app-h5.chargerlink.com/";
     socialBrandList =     (
     149,
     151,
     163,
     165,
     173,
     157,
     153,
     171,
     175,
     189,
     169,
     167,
     203,
     161,
     147,
     201,
     177,
     181,
     183,
     199,
     179,
     155,
     185,
     193,
     195,
     159,
     187,
     197,
     191
     );
     spotFilterTags =     (
     {
     color = "#6fb875";
     id = 1;
     title = "\U4ea4\U6d41\U6869";
     },
     {
     color = "#6fb875";
     id = 2;
     title = "\U76f4\U6d41\U6869";
     },
     {
     color = "#2d98c9";
     id = 3;
     title = "\U5b9e\U6d4b\U53ef\U7528";
     },
     {
     color = "#f5644c";
     id = 4;
     title = "\U5bf9\U5916\U5f00\U653e";
     },
     {
     color = "#f5644c";
     id = 5;
     title = "\U514d\U8d39\U505c\U8f66";
     }
     );
     spotHotCity =     (
     110000,
     310000,
     440100,
     440300,
     510100,
     610100,
     330100,
     420100,
     500000,
     120000,
     230100,
     530100,
     410100
     );
     spotOperationTypes =     (
     {
     name = "\U516c\U5171";
     type = 2;
     },
     {
     name = "\U4e2a\U4eba";
     type = 1;
     },
     {
     name = "\U8425\U8fd0";
     type = 4;
     }
     );
     spotPropertyTypes =     (
     {
     icon = "";
     name = "\U4f4f\U5b85\U5c0f\U533a ";
     type = 1;
     },
     {
     icon = "";
     name = "\U5ea6\U5047\U9152\U5e97";
     type = 2;
     },
     {
     icon = "";
     name = "\U8d2d\U7269\U4e2d\U5fc3";
     type = 4;
     },
     {
     icon = "";
     name = "\U529e\U516c\U5927\U53a6";
     type = 8;
     },
     {
     icon = "";
     name = "\U4f53\U80b2\U5065\U8eab";
     type = 16;
     },
     {
     icon = "";
     name = "\U751f\U6d3b\U670d\U52a1";
     type = 32;
     },
     {
     icon = "";
     name = "\U6c7d\U8f66\U670d\U52a1";
     type = 64;
     },
     {
     icon = "";
     name = "\U4ea4\U901a\U67a2\U7ebd";
     type = 128;
     },
     {
     icon = "";
     name = "\U5176\U4ed6\U573a\U6240";
     type = 256;
     }
     );
     spotSortTypes =     (
     {
     key = 0;
     name = "\U667a\U80fd\U6392\U5e8f";
     },
     {
     key = 1;
     name = "\U8ddd\U79bb\U6700\U8fd1";
     },
     {
     key = 2;
     name = "\U8bc4\U5206\U6700\U9ad8";
     },
     {
     key = 3;
     name = "\U5145\U7535\U8d39\U7528\U6700\U4f4e";
     }
     );
     spotTypes =     (
     {
     annotationBackgroundImage = "icon/plug_annotation_0.png";
     "annotationBackgroundImage_linked" = "icon/plug_annotation_0_linked.png";
     annotationImage = "icon/plug_annotation_circle_0.png";
     color = "#000000";
     desc = "";
     icon = "";
     isSelected = 1;
     name = "\U5168\U90e8\U5145\U7535\U70b9";
     shortDesc = "";
     shortName = "\U5168\U90e8";
     timelineImage = "icon/ic_community_maintain.png";
     type = 0;
     },
     {
     annotationBackgroundImage = "icon/plug_annotation_1.png";
     "annotationBackgroundImage_linked" = "icon/plug_annotation_1_linked.png";
     annotationImage = "icon/plug_annotation_circle_1.png";
     color = "#42d6be";
     desc = "\U6700\U9ad8\U529f\U73873.3~7kW";
     icon = "icon/\U6162\U901f.png";
     isSelected = 0;
     name = "\U6162\U901f\U5145\U7535\U70b9";
     shortDesc = "3.3~7kW";
     shortName = "\U6162\U901f";
     timelineImage = "icon/ic_community_slow.png";
     type = 1;
     },
     {
     annotationBackgroundImage = "icon/plug_annotation_2.png";
     "annotationBackgroundImage_linked" = "icon/plug_annotation_2_linked.png";
     annotationImage = "icon/plug_annotation_circle_2.png";
     color = "#ffa524";
     desc = "\U6700\U9ad8\U529f\U738710~42kW";
     icon = "icon/\U5feb\U901f.png";
     isSelected = 0;
     name = "\U5feb\U901f\U5145\U7535\U70b9";
     shortDesc = "10~42kW";
     shortName = "\U5feb\U901f";
     timelineImage = "icon/ic_community_fast.png";
     type = 2;
     },
     {
     annotationBackgroundImage = "icon/plug_annotation_4.png";
     "annotationBackgroundImage_linked" = "icon/plug_annotation_4_linked.png";
     annotationImage = "icon/plug_annotation_circle_4.png";
     color = "#f54c61";
     desc = "\U6700\U9ad8\U529f\U7387\U226550kW";
     icon = "icon/\U8d85\U901f.png";
     isSelected = 0;
     name = "\U8d85\U901f\U5145\U7535\U70b9";
     shortDesc = "\U226550kW";
     shortName = "\U8d85\U901f";
     timelineImage = "icon/ic_community_super.png";
     type = 4;
     }
     );
     updateTime = 1516200167;
     webPageHost = "https://app-h5.chargerlink.com/";
     }
     */
    self.imageHost=[attributes bd_StringObjectForKey:@"imageRootUrl"];
    self.webPageHost=[attributes bd_StringObjectForKey:@"webPageHost"];
    self.sharePageHost=[attributes bd_StringObjectForKey:@"sharePageHost"];
    self.updateTime =[attributes bd_DateObjectForKey:@"updateTime"];
    
    
    self.spotTypeInfos=[attributes bd_modelArrayForKey:@"spotTypes" class:[BDSpotTypeInfo class]];
    self.spotTypeInfoDict=[NSDictionary bd_DictionaryWithArray:self.spotTypeInfos keyPropertyName:@"type"];
    
    
    self.spotHideInMap=[attributes bd_ArrayObjectForKey:@"spotHideInMap"];
    self.socialBrandIdArray=[attributes bd_ArrayObjectForKey:@"socialBrandList"];
    
    
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.updateTime.timeIntervalSince1970 forKey:kUCGetConfigTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//社区品牌
-(NSArray<BDVehicleBrandModel *> *)socialBrandArray
{
    return [[BDVehicleConfigService sharedService] getVehicleBrandArrayForIds:self.socialBrandIdArray];
}

-(UIImage *)clusterAnnotationImage
{
    return [[BDImageLoader sharedLoader] getLocalImageWithPath:@"icon/clusterAnnotation.png"];
}
-(UIImage *)shareDefaultImage
{
    return nil;
}





-(BOOL)supportSpotType:(BDSpotType)type
{
    return self.spotTypeInfoDict[@(type)]!=nil;
}
-(BDSpotTypeInfo *)spotTypeInfoWithType:(BDSpotType)type
{
    return self.spotTypeInfoDict[@(type)]?:self.spotTypeInfoDict[@(BDSpotType_Unknow)];
}









@end
