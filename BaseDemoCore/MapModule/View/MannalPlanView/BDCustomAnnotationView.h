//
//  BDCustomAnnotationView.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/21.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@class BDCustomAnnotationView;
@protocol BDCustomAnnotationViewDelegate <NSObject>

-(void)BDCustomAnnotationView:(BDCustomAnnotationView *)annotationView DidSelected:(BOOL)selected;

@end

@interface BDCustomAnnotationView : MAAnnotationView

@property (nonatomic,assign) id<BDCustomAnnotationViewDelegate>delegate;
@property (nonatomic,assign) BOOL normalAnnotation; //不包含选择状态


-(instancetype)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;

-(void)animateToShowAnnotationViewDetail;
-(void)animateToHideAnnotationViewDetail;
-(void)setupBackImage:(UIImage *)backImage iconImage:(UIImage *)iconImage detailText:(NSString *)detailText;


@end
