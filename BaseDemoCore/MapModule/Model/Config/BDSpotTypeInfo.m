//
//  BDSpotTypeInfo.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/21.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDSpotTypeInfo.h"
#import "NSDictionary+BD.h"
#import "UIColor+HEX.h"

@interface BDSpotTypeInfo ()

@property (nonatomic,copy) NSString *iconImagePath;
@property (nonatomic,copy) NSString *timeLineImagePath;
@property (nonatomic,copy) NSString *annotationImagePath;
@property (nonatomic,copy) NSString *annotationBackgroundImagePath;
@property (nonatomic,copy) NSString *annotationBackground_linkedImagePath;


@end

@implementation BDSpotTypeInfo


-(id)initWithAttributes:(NSDictionary *)aAttributes
{
    if (self=[super initWithAttributes:aAttributes])
    {
        self.type=[aAttributes bd_IntergerForKey:@"type"];
        self.name=[aAttributes bd_StringObjectForKey:@"name"];
        self.shortName=[aAttributes bd_StringObjectForKey:@"shortName"];
        self.desc=[aAttributes bd_StringObjectForKey:@"desc"];
        self.shortDesc=[aAttributes bd_StringObjectForKey:@"shortDesc"];
        self.color=[UIColor colorWithHexString:[aAttributes bd_StringObjectForKey:@"name"]];
        
        self.iconImagePath=[aAttributes bd_StringObjectForKey:@"icon"];
        self.timeLineImagePath=[aAttributes bd_StringObjectForKey:@"timelineImage"];
        self.annotationImagePath=[aAttributes bd_StringObjectForKey:@"annotationImage"];
        self.annotationBackgroundImagePath=[aAttributes bd_StringObjectForKey:@"annotationBackgroundImage"];
        self.annotationBackground_linkedImagePath=[aAttributes bd_StringObjectForKey:@"annotationBackgroundImage_linked"];

    }
    return self;
}

-(UIImage *)iconImage
{
    return nil;
}
-(UIImage *)timeLineImage
{
    return nil;
}
-(UIImage *)annotationImage
{
    return nil;
}
-(UIImage *)annotationBackgroundImage
{
    return nil;
}
-(UIImage *)annotationBackground_linkedImage
{
    return nil;
}

-(void)checkSpotConfigImage
{
    if (self.iconImagePath.length==0)
    {
        NSLog(@"PackageImage Loss:(%zd--%@)",self.type,@"icon");
    }
}


@end
