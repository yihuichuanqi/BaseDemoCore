# EasyNavigation

一款超级简单的导航条管理工具。完全自定义导航条。没有`UINavigationBar` 和 `UINavigationItem` 这两个类。完全是对`UIView`的操作。
所有操作都能一行代码，操作之间完全独立，互不影响。

# 操作介绍

## 配置全局导航栏属性
这一步操作可以确保每一个控制器上头都有一个自定义的导航条。

* (1) 包涵头文件
* (2) (可省略)改变一些导航条的全局设置，但是如果省略的就会默认使用其单例里面的设置信息
* (3) 用navigationcontroller包裹controller的时候，使用EasyNavigationController。如果是tabbar的话，则tabbar的每一个item都需要使用EasyNavigationController。如果使用的xib，则需要把xib中的导航控制器改成EasyNavigationController。

```
//（1）包涵头文件
#import "EasyNavigation.h"
```
```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //（2）(可省略)改变一些导航条的全局设置，但是如果省略的就会默认使用其单例里面的设置信息
    EasyNavigationOptions *options = [EasyNavigationOptions shareInstance];
    options.titleColor = [UIColor blackColor];
    options.buttonTitleFont = [UIFont systemFontOfSize:18];
    options.navBackgroundImage = [UIImage imageNamed:@"nav_background_image.png"];
    
    //(3) 用navigationcontroller包裹controller的时候，使用EasyNavigationController。如果是tabbar的话，则tabbar的每一个item都需要使用EasyNavigationController。如果使用的xib，则需要把xib中的导航控制器改成EasyNavigationController。
    EasyNavigationController *navVC = [[EasyNavigationController alloc]initWithRootViewController:[ViewController new]];
    self.window.rootViewController  = navVC ;

    return YES;
}
```
_【preview】_

![image](https://github.com/chenliangloveyou/EasyNavigation/blob/master/EasyNavigationDemo/EasyNavigationDemo/nav_preview/home@2x.png)


## 导航栏上的控件增删改操作

下面所有的操作，首先需要包含头文件
`#import "EasyNavigation.h"`
#### 1,添加标题
```
  [self.navigationView setTitle:@"我是标题"];
  //需要改变标题上的文字
  [self.navigationView setTitle:@"我是改变后的标题"];
  //改变标题上面的属性
   self.navigationView.titleLabel.font = [UIFont systemFontOfSize:12] ;
   self.navigationView.titleLabel.textColor = [UIColor redColor];
  
  //需要添加一个titleview
  [self.navigationView addtitleView:customView];
```

#### 2,添加按钮

```
//添加一个文字按钮 ，可以用全局变量记下这个rightButton。在你接下来的操作中使用这个按钮，
self.rightButton = [self.navigationView addRightButtonWithTitle:@"添加" clickCallBack:nil];
 //在某处使用这个按钮
 [self.rightButton setTitle:@"改变了" forState:UIControlStateNormal];

```
```
//添加一个带图片的按钮，如果这个按钮只有点击事件，可以这样写，更加简洁。
[self.navigationView addRightButtonWithImage:kImage(@"button_normal.png") hightImage:kImage(@"button_select.png") clickCallBack:^(UIView *view) {
        NSLog(@"点击了“图片按钮按钮”");
}];
```
```
//添加自定义按钮(clickCallback会对self强引用)
 kWeakSelf(self)
 UIButton *addButton  =[UIButton buttonWithType:UIButtonTypeCustom];
 [addButton setImage:kImage(@"nav_btn_back.png") forState:UIControlStateNormal];
 [addButton setTitle:@"返回" forState:UIControlStateNormal];
 [self.navigationView addLeftView:addButton clickCallback:^(UIView *view) {
       [weakself.navigationController popViewControllerAnimated:YES];
}];
```

#### 3,添加/移除一个左右两边视图

添加/移除左右两边的视图后，都会重新布局两边的控件。
```
  //添加视图
    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.navigationView addLeftView:addButton clickCallback:^(UIView *view) {
           NSLog(@"click on leftView !");
    }];
  
  //移除视图 
  [self.navigationView removeLeftView:self.navigationView.leftButton];
```

#### 4,添加一个view 
* view直接添加到导航栏上(不是两边控件)不会重新布局控件
* 添加上view的frame不会受到导航条的约束。但是根据点击事件传递原理，它只会在导航条里面接受到事件。
```
  __block UIView *view = [[UIView alloc]initWithFrame:CGRectMake(100, -10, SCREEN_WIDTH-180, NAV_HEIGHT + 20)];
view.backgroundColor = [UIColor purpleColor];
[self.navigationView addSubview:view clickCallback:^(UIView *view) {
    [view removeFromSuperview];
}];
```

#### 5,添加/移除导航条

* 删除操作会把当前的导航条彻底重内存中删除。如果在以后还会使用建议使用` self.navigationView.hidden = YES ;`隐藏导航条
* 添加操作会重新创建一个新导航条，需要自己往上面添加子控件。
```
  if (self.navigationView) {
      [self.navigationView removeFromSuperview];
      self.navigationView = nil ;
   }
```
```
if (!self.navigationView) {
     EasyNavigationView *nav = [[EasyNavigationView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH , NAV_HEIGHT)];
     [self setNavigationView:nav];
     [self.view addSubview:nav];
 }
 ```
_【preview】_

![image](https://github.com/chenliangloveyou/EasyNavigation/blob/master/EasyNavigationDemo/EasyNavigationDemo/nav_preview/operate.gif)



## 透明度改变

#### 1,设置导航条为透明背景
  ```
     [self.navigationView setNavigationBackgroundAlpha:0];
     //当不想让导航条下面的细线变为透明
     self.navigationView.lineView.alpha = 1 ;
  ```
  
#### 2,导航条颜色渐变
```
//self.tableView 为支持导航条渐变的scrollview，
//NAV_HEIGHT为开始渐变的位置，NAV_HEIGHT*4为结束渐变的位置。在其中间的移动会均匀变化
[self.navigationView navigationAlphaSlowChangeWithScrollow:self.tableView];

[self.navigationView navigationAlphaSlowChangeWithScrollow:self.tableView start:NAV_HEIGHT end:NAV_HEIGHT*4];
```

_【preview】_

![image](https://github.com/chenliangloveyou/EasyNavigation/blob/master/EasyNavigationDemo/EasyNavigationDemo/nav_preview/alpha.gif)

## 导航条隐藏 

#### 1,无导航条
  可以移除，或者隐藏导航条
```
#if 1//以下两个2选1
    if (self.navigationView) {
        [self.navigationView removeFromSuperview];
        self.navigationView = nil ;
    }
#else
    self.navigationView.hidden = YES ;
#endif
```


#### 2,导航条随scrollview滚动而慢慢隐藏

```
//self.tableView 为支持导航条渐变的scrollview，
//NAV_HEIGHT 为开始渐变self.tableView需要滚动的距离，也就是说，只有在self.tableView滚动NAV_HEIGHT后导航条才开始移动。
//0.5 为导航条向上滚动的速度。（它的值为:导航条滚动距离/self.tableView滚动距离）
//NO 为是否需要在statusBar下面停止。（statusBar颜色为导航条的背景）
 [self.navigationView navigationSmoothScroll:self.tableView start:NAV_HEIGHT speed:0.5 stopToStatusBar:NO];
```

#### 3,导航条在scrollview滚动某个位置时以`UIView`动画隐藏
```
//self.tableView 为支持导航条渐变的scrollview，
//NAV_HEIGHT 为触发导航条隐藏的点。也就是当scrollview的contentOffset.y值操作这个数的时候，导航条就会隐藏
//NO 为是否需要在statusBar下面停止。（statusBar颜色为导航条的背景）
 [self.navigationView navigationAnimationScroll:self.tableView criticalPoint:NAV_HEIGHT stopToStatusBar:NO];
```

【图片】
![image](https://github.com/chenliangloveyou/EasyNavigation/blob/master/EasyNavigationDemo/EasyNavigationDemo/nav_preview/hidden.gif)


## 导航条手势返回手势

#### 1,系统返回手势

```
//是否禁止掉系统自带的侧滑返回手势，只会作用于当前控制器。无论在什么时候设置都。
 self.disableSlidingBackGesture = YES;
```
#### 2,自定义拖动屏幕手势返回

    设置自定义手势，不要关闭系统自带的侧滑手势。
    以下两个属性都可以随时变化
```
//是否开启 手势侧滑返回
 self.customBackGestureEnabel = YES ;
 //侧滑距离左边最大的距离,
 self.customBackGestureEdge = 100 ;
```

#### 3,嵌套scrollview返回

_【preview】_

![image](https://github.com/chenliangloveyou/EasyNavigation/blob/master/EasyNavigationDemo/EasyNavigationDemo/nav_preview/sliding.gif)


## 状态栏改变

默认状态栏为有状态栏，并且为黑色。每一次状态栏设置只会对当前控制器有效
```
//是否隐藏状态栏
 self.statusBarHidden = YES ;
 //设置当前状态栏的样式
 self.statusBarStyle =  UIStatusBarStyleDefault ; //UIStatusBarStyleLightContent 
```
_【preview】_

![image](https://github.com/chenliangloveyou/EasyNavigation/blob/master/EasyNavigationDemo/EasyNavigationDemo/nav_preview/statusBar.gif)


# 实现原理


由于这个库的原理是隐藏系统导航条，自定义一个`view`作为导航条，所以有2点需要注意点地方。
1，self.automaticallyAdjustsScrollViewInsets = NO ;
2，控制器中的view会从左上角的{0,0}开始计算。
    在添加视图的时候，可以重导航条高度的下面开始添加。
    当为scrollview的时候可以设置。`scrollview.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);` 也就是向下收缩导航条高度的距离。
