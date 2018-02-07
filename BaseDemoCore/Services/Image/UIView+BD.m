//
//  UIView+BD.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/29.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "UIView+BD.h"

CGRect getCenterSquareRectOfSize(CGSize originSize)
{
    CGFloat originWidth=originSize.width;
    CGFloat originHeight=originSize.height;
    CGRect rect=CGRectMake(0, 0, originWidth, originHeight);
    
    if (originWidth>originHeight)
    {
        //矩形宽度>高度
        rect=CGRectMake(originWidth/2-originHeight/2, 0, originHeight, originHeight);
    }
    else
    {
        rect=CGRectMake(0, originHeight/2-originWidth/2, originWidth, originWidth);
    }
    return rect;
}



@implementation UIView (BD)

@end
