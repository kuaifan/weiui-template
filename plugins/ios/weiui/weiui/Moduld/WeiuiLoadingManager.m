//
//  WeiuiLoadingManager.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/6.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "WeiuiLoadingManager.h"
#import "DGActivityIndicatorView.h"

@interface WeiuiLoadingView : UIControl

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *titleColor;
@property (nonatomic, strong) NSString *style;
@property (nonatomic, strong) NSString *styleColor;
@property (nonatomic, assign) BOOL cancelable;
@property (nonatomic, assign) NSInteger titleSize;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, assign) CGFloat amount;

@property (nonatomic, copy) void (^cancelLoadingBlock)(void);

@end

@implementation WeiuiLoadingView

- (void)loadLoadingView
{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat width = 80, height = 0;
    if (_title.length > 0) {
        UIFont *font = [UIFont boldSystemFontOfSize:_titleSize];
        CGFloat textWidth = [_title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil] context:nil].size.width;
        width = textWidth + 10 > width ? textWidth + 30 : width;
        height = 40;
    }
    
    UIColor *backColor = [[UIColor whiteColor] colorWithAlphaComponent:_amount <= 0 ? 0.01 : _amount];
    UIView *loadBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    loadBgView.center = self.center;
    loadBgView.backgroundColor = backColor;
    loadBgView.layer.cornerRadius = 4;
    loadBgView.layer.masksToBounds = YES;
    [self addSubview:loadBgView];
    
    DGActivityIndicatorView *loadView = [[DGActivityIndicatorView alloc] initWithType:[self getType:_style] tintColor:[WXConvert UIColor:_styleColor]];
    loadView.frame = CGRectMake(0, 0, width, width - height);
    loadView.backgroundColor = backColor;
    loadView.tintColor = [WXConvert UIColor:_styleColor];
    
    [loadBgView addSubview:loadView];
    [loadView startAnimating];
    
    if (_title.length > 0) {
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, loadView.frame.size.height, width, height)];
        titleLab.font = [UIFont systemFontOfSize:_titleSize];
        titleLab.textColor = [WXConvert UIColor:_titleColor];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.text = _title;
        [loadBgView addSubview:titleLab];
    }
    
    if (_duration > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_duration * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            self.cancelLoadingBlock();
        });
    }
}

- (void)closeClick
{
    if (_cancelable) {
        self.cancelLoadingBlock();
    }
}

- (DGActivityIndicatorAnimationType)getType:(NSString*)name
{
    if ([name isEqualToString:@"RotatingPlane"]) {
        return DGActivityIndicatorAnimationTypeTriangleSkewSpin;
    } else if ([name isEqualToString:@"DoubleBounce"]) {
        return DGActivityIndicatorAnimationTypeRotatingSquares;
    }  else if ([name isEqualToString:@"Wave"]) {
        return DGActivityIndicatorAnimationTypeLineScale;
    }  else if ([name isEqualToString:@"WanderingCubes"]) {
        return DGActivityIndicatorAnimationTypeRotatingSquares;
    }  else if ([name isEqualToString:@"Pulse"]) {
        return DGActivityIndicatorAnimationTypeBallScaleMultiple;
    }  else if ([name isEqualToString:@"ChasingDots"]) {
        return DGActivityIndicatorAnimationTypeRotatingSandglass;
    }  else if ([name isEqualToString:@"ThreeBounce"]) {
        return DGActivityIndicatorAnimationTypeBallPulse;
    }  else if ([name isEqualToString:@"Circle"]) {
        return DGActivityIndicatorAnimationTypeBallClipRotate;
    }  else if ([name isEqualToString:@"CubeGrid"]) {
        return DGActivityIndicatorAnimationTypeBallGridPulse;
    }    else if ([name isEqualToString:@"FadingCircle"]) {
        return DGActivityIndicatorAnimationTypeBallClipRotatePulse;
    }  else if ([name isEqualToString:@"FoldingCube"]) {
        return DGActivityIndicatorAnimationTypeBallBeat;
    }  else if ([name isEqualToString:@"RotatingCircle"]) {
        return DGActivityIndicatorAnimationTypeTwoDots;
    }
    
    return DGActivityIndicatorAnimationTypeBallPulse;
}

@end


@implementation WeiuiLoadingManager

+ (WeiuiLoadingManager *)sharedIntstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.loadingDic = [NSMutableDictionary dictionaryWithCapacity:5];
        self.loadingList = [NSMutableArray arrayWithCapacity:5];
    }
    
    return self;
}

- (NSString*)loading:(NSDictionary*)params callback:(WXModuleKeepAliveCallback)callback
{
    NSString *title = params[@"title"] ? [WXConvert NSString:params[@"title"]] : @"";
    NSString *titleColor = params[@"titleColor"] ? [WXConvert NSString:params[@"titleColor"]] : @"#333333";
    NSString *style = params[@"style"] ? [WXConvert NSString:params[@"style"]] : @"";
    NSString *styleColor = params[@"styleColor"] ? [WXConvert NSString:params[@"styleColor"]] : @"#3EB4FF";
    BOOL cancelable = params[@"cancelable"] ? [WXConvert BOOL:params[@"cancelable"]] : YES;
    NSInteger titleSize = params[@"titleSize"] ? [WXConvert NSInteger:params[@"titleSize"]] : 16;
    NSInteger duration = params[@"duration"] ? [WXConvert NSInteger:params[@"duration"]] : 0;
    CGFloat amount = params[@"amount"] ? [WXConvert CGFloat:params[@"amount"]] : 0.7;
    
    //返回随机数名称
    int tag =(arc4random() % 100) + 8000;
    NSString *name = [NSString stringWithFormat:@"loading-%d", tag];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        
        WeiuiLoadingView *loadingView = [[WeiuiLoadingView alloc] initWithFrame:window.bounds];
        loadingView.title = title;
        loadingView.titleColor = titleColor;
        loadingView.style = style;
        loadingView.styleColor = styleColor;
        loadingView.cancelable = cancelable;
        loadingView.titleSize = titleSize;
        loadingView.duration = duration;
        loadingView.amount = amount;
        loadingView.tag = tag;
        [loadingView loadLoadingView];
        
        __weak typeof(loadingView) weakLV = loadingView;
        __weak typeof(self) ws = self;
        loadingView.cancelLoadingBlock = ^{
            [ws.loadingDic removeObjectForKey:name];
            [ws.loadingList removeObject:weakLV];
            [weakLV removeFromSuperview];
            
            if (callback) {
                callback(@{}, NO);
            }
        };
        [window addSubview:loadingView];
        
        [self.loadingDic setObject:loadingView forKey:name];
        [self.loadingList addObject:loadingView];
    });

    return name;
}

- (void)loadingClose:(NSString*)name
{
    if (name && [name hasPrefix:@"loading-"]) {
        NSInteger tag = [[name componentsSeparatedByString:@"-"].lastObject integerValue];
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        UIView *view = [window viewWithTag:tag];
        
        [_loadingList removeObject:view];
        [_loadingDic removeObjectForKey:name];
        [view removeFromSuperview];
    } else {
        WeiuiLoadingView *view = [_loadingList firstObject];
        if (view) {
            [_loadingList removeObject:view];
            [view removeFromSuperview];
        }
    }
}

@end