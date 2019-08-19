//
//  TPTextView.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/5/11.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHTextView.h"
#import "globalDefine.h"

@interface HHTextView() <UITextViewDelegate>

@end
@implementation HHTextView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

/** 完善从Xib创建出来的情况 */
- (void)awakeFromNib
{
    [super awakeFromNib];
  
    [self setupUI];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI
{
    self.backgroundColor = [UIColor clearColor];
    
    // 添加一个显示提醒文字的label（显示占位文字的label）
    UILabel *placehoderLabel = [[UILabel alloc] init];
    placehoderLabel.numberOfLines = 0;
    placehoderLabel.backgroundColor = [UIColor clearColor];
    placehoderLabel.font = Font(12.f);
    [self addSubview:placehoderLabel];
    self.placehoderLabel = placehoderLabel;
    
    // 设置默认的占位文字颜色
    self.placehoderColor = [UIColor lightGrayColor];
    
    // 设置默认的字体
    self.font = Font(15);
    
    // 监听内部文字改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self];
}

- (void)textDidChange
{
    // text属性：只包括普通的文本字符串
    // attributedText：包括了显示在textView里面的所有内容（表情、text）
    self.placehoderLabel.hidden = self.hasText;
    

    //字数限制操作
    if (self.text.length >= 100) {
        
        self.text = [self.text substringToIndex:100];
    }
    
    //实时显示字数
    self.wordLengthLabel.text = [NSString stringWithFormat:@"%zi/%zi", self.text.length,self.maxWordLength];
}


- (void)setText:(NSString *)text
{
    [super setText:text];
    
    [self textDidChange];
}

//- (void)setAttributedText:(NSAttributedString *)attributedText
//{
//    [super setAttributedText:attributedText];
//
//    [self textDidChange];
//}

- (void)setPlacehoder:(NSString *)placehoder
{
    
    _placehoder = [placehoder copy];
    
    // 设置文字
    self.placehoderLabel.text = placehoder;
    
    // 重新计算子控件的fame
    [self setNeedsLayout];
}

-(void)setShowWordCounter:(BOOL)showWordCounter
{
    _showWordCounter=showWordCounter;
    if(_showWordCounter)
    {
        //添加一个字数统计label
        self.wordLengthLabel=[[UILabel alloc] init];
        self.wordLengthLabel.numberOfLines = 1;
        self.wordLengthLabel.textAlignment=NSTextAlignmentRight;
        self.wordLengthLabel.backgroundColor = [UIColor clearColor];
        self.wordLengthLabel.font=Font(13);
        self.wordLengthLabel.textColor=ColorHexString(@"999999");
        [self addSubview:self.wordLengthLabel];
    }
}

-(void)setMaxWordLength:(NSInteger)maxWordLength
{
    if(maxWordLength>0)
    {
        self.showWordCounter=YES;
    }
    _maxWordLength=maxWordLength;
    // 设置文字
    self.wordLengthLabel.text = [NSString stringWithFormat:@"%zi/%zi", self.text.length,self.maxWordLength];
    // 重新计算子控件的fame
    [self setNeedsLayout];
}

- (void)setPlacehoderColor:(UIColor *)placehoderColor
{
    _placehoderColor = placehoderColor;
    
    // 设置颜色
    self.placehoderLabel.textColor = placehoderColor;
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    
    self.placehoderLabel.font = font;
    
    // 重新计算子控件的fame
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.placehoderLabel.top = 8;
    self.placehoderLabel.left = 10;
    self.placehoderLabel.width = self.width - 2 * self.placehoderLabel.left;
    // 根据文字计算label的高度
    CGSize maxSize = CGSizeMake(self.placehoderLabel.width, MAXFLOAT);

   CGSize placehoderSize =  [self.placehoder boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size;
    
    self.placehoderLabel.height = placehoderSize.height;
    
    //计算字数统计
    self.wordLengthLabel.height=20;
    self.wordLengthLabel.top=self.height-20;
    NSString *lengthStr=[NSString stringWithFormat:@"%zi/%zi", self.maxWordLength,self.maxWordLength];
    maxSize = CGSizeMake(MAXFLOAT,self.wordLengthLabel.height);
    CGSize lengthSize=[lengthStr boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:Font(13)} context:nil].size;
    self.wordLengthLabel.width = lengthSize.width;
    self.wordLengthLabel.left=self.width-self.wordLengthLabel.width-10;
}


@end

