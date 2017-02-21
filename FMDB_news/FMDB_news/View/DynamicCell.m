//
//  DynamicCell.m
//  水云天
//
//  Created by iMac on 16/5/24.
//  Copyright © 2016年 Sinfotek. All rights reserved.
//

#import "DynamicCell.h"
#import "UIImageView+WebCache.h"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

@implementation DynamicCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {

        [self _creatSubViews];
    }
    
    return  self;
}


- (void)_creatSubViews {

    //图片
    UIImageView *cellImg = [[UIImageView alloc]initWithFrame:CGRectZero];
    cellImg.contentMode = UIViewContentModeScaleAspectFill;//图片保持比例自适应（可能会截掉图片）
    cellImg.layer.masksToBounds = YES;
    cellImg.tag = 11;
    [self addSubview:cellImg];
    
    //主标题
    UILabel *cellTitle = [[UILabel alloc]initWithFrame:CGRectZero];
    cellTitle.textColor = [UIColor blackColor];
    cellTitle.numberOfLines = 0;
    cellTitle.font = [UIFont systemFontOfSize:16];
    cellTitle.tag = 22;
    [self addSubview:cellTitle];
    
    //来源
    UILabel *sourceLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    sourceLabel.textColor = [UIColor grayColor];
    sourceLabel.font = [UIFont systemFontOfSize:13];
    sourceLabel.tag = 33;
    [self addSubview:sourceLabel];
    
    
    
}


-(void)setModel:(DynamicModel *)model {
    _model = model;
    
    UIImageView *cellImg = (UIImageView *)[self viewWithTag:11];
    UILabel *cellTitle = (UILabel *)[self viewWithTag:22];
    UILabel *sourceLabel = (UILabel *)[self viewWithTag:33];
    
    //cellImg的frame
    if ([self isBlankString:_model.imageUrl]) { //如果图片网址是null，则不显示图片
        
        cellImg.frame = CGRectMake(0, 7.5, 0, 70);
    }else{
        cellImg.frame = CGRectMake(10, 7.5, 90, 70);
        [cellImg sd_setImageWithURL:[NSURL URLWithString:_model.imageUrl]];//加载图片
    }
    //来源的frame
    sourceLabel.frame = CGRectMake(CGRectGetMaxX(cellImg.frame)+10,CGRectGetMaxY(cellImg.frame)-20, kScreenWidth - CGRectGetWidth(cellImg.frame) - 10 - 10-5, 20);
    

    cellTitle.text = _model.cellTitle;
    //计算文字的高度
    CGFloat cellTitleHeight = [cellTitle.text boundingRectWithSize:CGSizeMake(kScreenWidth - CGRectGetWidth(cellImg.frame) -10-10-5, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size.height;
    if (cellTitleHeight > 40) {

        cellTitleHeight = 40;
    }
    
    //新闻名称frame
    cellTitle.frame = CGRectMake(CGRectGetMaxX(cellImg.frame)+10, CGRectGetMinY(cellImg.frame), kScreenWidth - CGRectGetWidth(cellImg.frame) -10-10-5, cellTitleHeight);
    
    
    sourceLabel.text = _model.source;
    
    
    
}


- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}







@end
