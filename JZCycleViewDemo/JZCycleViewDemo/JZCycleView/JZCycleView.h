//
//  JZCycleView.h
//  JZCycleViewDemo
//
//  Created by Jz on 16/4/25.
//  Copyright © 2016年 Jz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JZCycleView : UIView

-(instancetype)initWithFrame:(CGRect)frame andArray:(NSArray *)array;/**< 构造函数,包含图书数组 */
-(void)setUpImagesArray:(NSArray*)array;/**< 设置图像数组,一定要有 */
@end
