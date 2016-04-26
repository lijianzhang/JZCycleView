//
//  JZCycleView.m
//  JZCycleViewDemo
//
//  Created by Jz on 16/4/25.
//  Copyright © 2016年 Jz. All rights reserved.
//

#import "JZCycleView.h"


@interface JZCycleView ()
@property (weak, nonatomic) IBOutlet UIView *view;

@end

@implementation JZCycleView

//- (instancetype)initWithCoder:(NSCoder *)aDecoder{
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        [self initFromXib];
//    }
//    return self;
//}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initFromXib];
    }
    return self;
}
- (void)awakeFromNib{
    [self initFromXib];

}
- (void)initFromXib{
    NSString *name = NSStringFromClass([self class]);
    self.view = [[NSBundle mainBundle]loadNibNamed:name owner:self options:nil].firstObject;
    self.view.frame = self.bounds;
    [self addSubview:self.view];
}
@end
