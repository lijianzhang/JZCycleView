//
//  JZCycleView.m
//  JZCycleViewDemo
//
//  Created by Jz on 16/4/25.
//  Copyright © 2016年 Jz. All rights reserved.
//

#import "JZCycleView.h"


typedef NS_ENUM(NSUInteger,JZDirection){
    JZDirectionLeft = 0,
    JZDirectionRight,
    JZDirectionNone
};

IB_DESIGNABLE
#define VIEWWITH self.frame.size.width
@interface JZCycleView ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *view;/**< 容器 */
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;/**< 滑动视图 */
@property (weak, nonatomic) IBOutlet UIImageView *reveal;/**< 显示的图片 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *revealViewLeftMargin;/**< 显示图片的x边距 */
@property (weak, nonatomic) IBOutlet UIView *contentVIew;
@property (weak, nonatomic) IBOutlet UIImageView *tempImageView;/**< 辅助图片 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tempIamgeViewLeftMargin;/**< 辅助图片的x边距 */
@property (weak, nonatomic) IBOutlet UIPageControl *pageView;/**< 分页 */
@property (nonatomic, assign)JZDirection dirction;/**< 滑动方向 */
@property(nonatomic,strong)NSMutableArray *images;/**<图像数组 */
@property(nonatomic,strong)NSOperationQueue *queue;/**<队列 */
@property(nonatomic,strong)NSMutableDictionary *queueCache;/**<队列操纵数组 */
@property(nonatomic,assign)NSUInteger currentNumber;/**< 当前显示图片索引 */
@property(nonatomic,strong)NSTimer *timer;/**<定时器 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollContentWidth;
@property(nonatomic,copy)IBInspectable NSMutableArray *imagesArray;/**<图片集合 */



@property(nonatomic,strong)IBInspectable UIColor *pageIndicatorColor;/**<pageView颜色 */
@property(nonatomic,strong)IBInspectable UIColor *pageCurrentColor;/**<pageView当前页颜色 */
@end



@implementation JZCycleView

#pragma mark -Get/Set方法
IBInspectable
-(void)setImagesArray:(NSMutableArray *)imagesArray{
    NSLog(@"%f",        self.scrollContentWidth.constant);
    if (!imagesArray.count) {
        return;
    }
    _imagesArray = [NSMutableArray arrayWithArray:imagesArray];
    [_imagesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self loadImageWithNumber:idx];
    }];
    if (imagesArray.count==1) {/**< 当只有一张图片的时候 需要把分页消失,还有更改scrollVIew的contentSize */
        self.pageView.hidden = YES;
        //新建约束替换原有的约束
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.contentVIew attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
        [self.view addConstraint:constraint];
        [self.view removeConstraint:self.scrollContentWidth];
        self.scrollContentWidth = constraint;


    }
    self.pageView.numberOfPages = _imagesArray.count;
    self.pageView.currentPage = 0;
    [self.reveal setImage:[self loadImageWithNumber:0]];
    [self startTimer];
}
- (NSMutableDictionary *)queueCache{
    if (!_queueCache) {
        _queueCache = [NSMutableDictionary dictionary];
    }
    return _queueCache;
}
- (NSOperationQueue *)queue{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc]init];
    }
    return _queue;
}

- (void)setPageIndicatorColor:(UIColor *)pageIndicatorColor{
    self.pageView.pageIndicatorTintColor = pageIndicatorColor;
}

- (void)setPageCurrentColor:(UIColor *)pageCurrentColor{
    self.pageView.currentPageIndicatorTintColor = pageCurrentColor;
}

#pragma mark -初始化方法
- (void)setUpScrollView{
    [self layoutIfNeeded];
    self.revealViewLeftMargin.constant = self.frame.size.width;
    self.scrollView.contentOffset = CGPointMake(VIEWWITH, 0);
    self.scrollView.delegate = self;
    
}

-(void)setUpImagesArray:(NSArray*)array{
    self.imagesArray = (NSMutableArray *)array;
}

#pragma mark -构造函数

-(instancetype)initWithFrame:(CGRect)frame andArray:(NSArray *)array{
    self = [self initWithFrame:frame];
    self.imagesArray = (NSMutableArray *)array;
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self =[super initWithCoder:aDecoder];
    if (self) {
        [self initFromXib];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initFromXib];
        [self setUpScrollView];

    }
    return self;
}
- (void)awakeFromNib{
    [super awakeFromNib];
    [self setUpScrollView];

}

- (void)initFromXib{
    NSString *name = NSStringFromClass([self class]);
    self.view = [[NSBundle bundleForClass:[self class]]loadNibNamed:name owner:self options:nil].lastObject;
    self.view.frame = self.bounds;
    [self addSubview:self.view];
    
}

#pragma mark -自定义方法

/**
 *  加载图片,先从项目文件中查找再从缓存中查找,没有再从网络下载,下载完缓存到cache文件夹
 *
 *  @param name  图片名或者地址
 *  @param index 图片索引
 */
- (UIImage *)loadImageWithNumber:(NSUInteger)index{
    NSString *name;
    UIImage *image;
    if ([self.imagesArray[index] isKindOfClass:[UIImage class]]) {
        return self.imagesArray[index];
    }else if ([self.imagesArray[index] isKindOfClass:[NSString class]]){
        name = self.imagesArray[index];
    }else{
        return nil;
    }
    image = [UIImage imageNamed:name];
    if (image) {
        self.imagesArray[index] = image;
        return image;
    }else{
       image = [UIImage imageNamed:@"10083737,1920,1080"];
    }
    image = [UIImage imageWithContentsOfFile:[self cachePathWithFileName:name]];
    if (image) {
        self.imagesArray[index] = image;
        return image;
    }
    NSBlockOperation * downImage = self.queueCache[name];
    if (downImage != nil) {
        return image;
    }
    __block typeof(self)WKSef = self;
    
    downImage = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"adfsf");

        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:name]];
        NSLog(@"%@",data);
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            WKSef.imagesArray[index] = image;
            if (index == WKSef.currentNumber) {
                dispatch_async(dispatch_get_main_queue(), ^{
                        WKSef.reveal.image = image;
                [WKSef.queueCache removeObjectForKey:name];
                });
            }
            [UIImageJPEGRepresentation(image, 1.0)writeToFile:[self cachePathWithFileName:name] atomically:YES];
            [WKSef.queueCache removeObjectForKey:name];

        }
    }];
    [self.queueCache setObject:downImage forKey:name];
    [self.queue addOperation:downImage];
    return image;
    
}
/**
 *  缓存地址
 *
 *  @param name 文件名
 *
 *  @return 缓存地址
 */


- (NSString *)cachePathWithFileName:(NSString *)name{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:[name lastPathComponent]];
    NSLog(@"%@",cachePath);
    return cachePath;
}

/**
 *  改变临时图片的位置和图像
 *
 *  @param index 即将显示的图片索引
 */
-(void)changeTempImageView:(NSUInteger)index{
    self.tempIamgeViewLeftMargin.constant = (self.dirction==JZDirectionRight)?VIEWWITH*2:0;
    self.tempImageView.image = [self loadImageWithNumber:index];
    
}
/**
 *  改变展示图片的位置和page
 *
 *  @param index 即将显示的图片索引
 */
-(void)changeToReverViewWithIndex:(NSUInteger)index{
    self.reveal.image = [self loadImageWithNumber:index];
    self.currentNumber = index;
//    [self.scrollView setContentOffset:CGPointMake(VIEWWITH, 0)];
    [self.scrollView setContentOffset:CGPointMake(VIEWWITH, 0)];
    self.pageView.currentPage = index;
}
-(void)nextPage{
    [self.scrollView setContentOffset:CGPointMake(VIEWWITH*2, 0) animated:YES];
}

-(void)startTimer{
    if (self.imagesArray.count==1)return;
    
    self.timer = [NSTimer timerWithTimeInterval:1.5 target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
}
-(void)stopTimer{
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark -scrollView代理
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{

}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat scorllViewX = scrollView.contentOffset.x;
    self.dirction = (scorllViewX<(VIEWWITH))?JZDirectionLeft:(scorllViewX>VIEWWITH)?JZDirectionRight:JZDirectionNone;
    NSUInteger tempImageNumber;
    switch (self.dirction) {
        case JZDirectionRight:
            tempImageNumber = (self.currentNumber+1)%self.imagesArray.count;
            [self changeTempImageView:tempImageNumber];
            if (scorllViewX==VIEWWITH*2) {
                [self changeToReverViewWithIndex:tempImageNumber];
            }
            break;
        case JZDirectionLeft:
            tempImageNumber = (self.currentNumber+self.imagesArray.count-1)%self.imagesArray.count;
            [self changeTempImageView:tempImageNumber];
            if (scorllViewX==0) {
                [self changeToReverViewWithIndex:tempImageNumber];
            }
            break;
        default:
            break;
    }
}


@end
