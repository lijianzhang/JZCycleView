//
//  JZCycleView.h
//  JZCycleViewDemo
//
//  Created by Jz on 16/4/25.
//  Copyright © 2016年 Jz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JZCycleView : UIView

-(instancetype)initWithFrame:(CGRect)frame andArray:(NSArray *)array;
-(void)setUpImagesArray:(NSArray*)array;
@end
