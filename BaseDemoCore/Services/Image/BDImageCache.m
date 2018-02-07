//
//  BDImageCache.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/24.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDImageCache.h"
#import "NSString+BD.h"
//默认缓存图片个数
#define kImageCache_DefaultCapacity 100

@interface BDImageCache ()
{
    NSMutableDictionary *_images;
    NSMutableArray *_imageKeys;
    NSLock *_lock;
}
@end

@implementation BDImageCache


+(instancetype)sharedCache
{
    static BDImageCache *cache=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache=[[BDImageCache alloc]init];
    });
    return cache;
}

-(id)init
{
    if (self=[super init])
    {
        _capacity=kImageCache_DefaultCapacity;
        _images=[NSMutableDictionary dictionaryWithCapacity:_capacity];
        _imageKeys=[NSMutableArray arrayWithCapacity:_capacity];
        _lock=[[NSLock alloc]init];
        
    }
    return self;
}

-(void)addNotificationObservers
{
    //内存警告
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}
-(void)handleMemoryWarning
{
    [self removeAllImage];
    NSLog(@"BDImageCache Reveice Memeory Warning!!!!");
}

-(UIImage *)imageNamed:(NSString *)name
{
    if (name==nil)
    {
        return nil;
    }
    UIImage *image=_images[name];
    if (image==nil)
    {
        //内存不存在 则获取然后添加到内存中
        image=[UIImage imageNamed:name];
        if (image!=nil)
        {
            [self addImageToCache:image withKey:name];
        }
    }
    return image;
}
-(UIImage *)imageWithContentOfFile:(NSString *)file
{
    if (file==nil)
    {
        return nil;
    }
    
    UIImage *image=_images[file.bd_MD5];
    if (image==nil)
    {
        NSData *data=[NSData dataWithContentsOfFile:file];
        image=[[UIImage alloc]initWithData:data scale:2];
        if (image!=nil)
        {
            [self addImageToCache:image withKey:file.bd_MD5];
        }
    }
    return image;
}
-(void)removeImageWithKey:(NSString *)key
{
    [_lock lock];
    if (key!=nil)
    {
        [_images removeObjectForKey:key];
        [_imageKeys removeObject:key];
    }
    [_lock unlock];
}
-(void)removeAllImage
{
    [_lock lock];
    [_images removeAllObjects];
    [_imageKeys removeAllObjects];
    [_lock unlock];
}


#pragma mark-Private Method
-(void)addImageToCache:(UIImage *)image withKey:(NSString *)key
{
    [_lock lock];
    if (_images.count>=self.capacity)
    {
        //如果超过最大值 则移除第一个
        NSString *imageKey=_imageKeys[0];
        [_images removeObjectForKey:imageKey];
        [_imageKeys removeObjectAtIndex:0];
    }
    //然后添加
    _images[key]=image;
    [_imageKeys addObject:key];
    [_lock unlock];
}
-(void)setCapacity:(NSInteger)capacity
{
    [_lock lock];
    //外部设置最大值 如果超过则移除前面多余图片
    if (capacity<_images.count)
    {
        NSInteger i;
        NSInteger count=_images.count-capacity;
        NSString *imageKey;
        for (i=0; i<count; ++i)
        {
            //循环移除第一个
            imageKey=_imageKeys[0];
            [_images removeObjectForKey:imageKey];
            [_imageKeys removeObjectAtIndex:0];
        }
    }
    _capacity=capacity;
    [_lock unlock];
}


-(void)dealloc
{
    [self removeAllImage];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
