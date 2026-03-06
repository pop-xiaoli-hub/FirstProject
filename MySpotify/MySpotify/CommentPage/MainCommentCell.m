//
//  MainCommentCell.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/28.
//

#import "MainCommentCell.h"
#import <Masonry.h>
#import "ZLCommentModel.h"
#import "ZLUserModel.h"
#import <SDWebImage/SDWebImage.h>
#import "ZLRepliedModel.h"

static UIFont * _contentFont(void) { return [UIFont systemFontOfSize:16]; }
// 「展开」「收起」按钮蓝色
static UIColor * _expandCollapseTintColor(void) {
  return [UIColor colorWithRed:0.35 green:0.78 blue:0.98 alpha:1.0]; // 柔和蓝
}

@interface MainCommentCell ()
@property (nonatomic, weak) id expandTarget;
@property (nonatomic, assign) SEL expandAction;
@property (nonatomic, assign) NSInteger expandRow;
@property (nonatomic, strong) MASConstraint *replyBgViewTopConstraint;
@end

@implementation MainCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    [self setupViews];
    [self setupConstraints];
  }
  return self;
}


- (void)configWithModel:(ZLCommentModel *)model indexPath:(NSIndexPath *)indexPath target:(id)target action:(SEL)action {
  ZLUserModel* user = model.user;
  SDImageResizingTransformer *transformer =
  [SDImageResizingTransformer transformerWithSize:CGSizeMake(200, 200)  scaleMode:SDImageScaleModeAspectFill];
  [self.headerView sd_setImageWithURL:[NSURL URLWithString:user.avatarUrl] placeholderImage:nil options:SDWebImageScaleDownLargeImages context:@{
    SDWebImageContextImageTransformer: transformer
  }];
  self.userNameLabel.text = [user.nickname copy];
  self.timeLabel.text = [model.timeStr copy];

  self.expandTarget = target;
  self.expandAction = action;
  self.expandRow = indexPath.row;

  CGFloat textWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - 10 - 40 - 6 - 12;
  NSDictionary *bodyAttrs = @{
    NSFontAttributeName: _contentFont(),
    NSForegroundColorAttributeName: [[UIColor whiteColor] colorWithAlphaComponent:0.95],
    NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)
  };

  // 正文只显示文字，展开/收起改为下方按钮
  if (model.needFold && !model.expandedContent) {
    NSString *prefix = [self truncatedContentForText:model.content font:_contentFont() width:textWidth maxLines:3 reserveWidthForSuffix:@""];
    BOOL didTruncate = prefix.length < model.content.length;
    NSString *display = didTruncate ? [prefix stringByAppendingString:@"..."] : model.content;
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:display attributes:bodyAttrs];
    self.contentTextView.attributedText = attr;
    self.contentTextView.textContainer.maximumNumberOfLines = 0;
    self.contentTextView.textContainer.lineBreakMode = NSLineBreakByClipping;
    self.foldButton.hidden = NO;
    [self.foldButton setTitle:@"展开" forState:UIControlStateNormal];
    [self.foldButton setTitleColor:_expandCollapseTintColor() forState:UIControlStateNormal];
  } else {
    if (model.needFold && model.expandedContent) {
      NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:model.content attributes:bodyAttrs];
      self.contentTextView.attributedText = attr;
      self.foldButton.hidden = NO;
      [self.foldButton setTitle:@"收起" forState:UIControlStateNormal];
      [self.foldButton setTitleColor:_expandCollapseTintColor() forState:UIControlStateNormal];
    } else {
      NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[model.content copy] attributes:bodyAttrs];
      self.contentTextView.attributedText = attr;
      self.foldButton.hidden = YES;
    }
    self.contentTextView.textContainer.maximumNumberOfLines = 0;
  }

  [self.foldButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
  if (!self.foldButton.hidden) {
    [self.foldButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    self.foldButton.tag = (NSInteger)indexPath.row;
  }
  // 先清空之前的回复视图
  // 清空之前的回复
  [self.replyStackView.arrangedSubviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

  // 判断是否有楼中楼
  if (model.beReplied.count > 0) {
      self.buttonOfExpand.hidden = NO;
    //NSLog(@"回复数量：%ld", model.beReplied.count);
      // 根据 model.showReplies 来决定是否展示
      if (model.showReplies) {
          for (ZLRepliedModel *reply in model.beReplied) {
              UIView *replyView = [self createReplyViewWithModel:reply];
              [self.replyStackView addArrangedSubview:replyView];
          }
      }
      NSString *title = model.showReplies ? @"收起回复" : @"展开回复";
      [self.buttonOfExpand setTitle:title forState:UIControlStateNormal];
  } else {
      self.buttonOfExpand.hidden = YES;
  }
  self.buttonOfExpand.tag = (NSInteger)indexPath.row;

  // replyBgView 顶部：有楼中楼时在 buttonOfExpand 下，否则在 foldButton 下（或正文下）
  [self.replyBgViewTopConstraint uninstall];
  if (model.beReplied.count > 0) {
    [self.replyBgView mas_makeConstraints:^(MASConstraintMaker *make) {
      self.replyBgViewTopConstraint = make.top.equalTo(self.buttonOfExpand.mas_bottom).offset(6);
    }];
  } else if (model.needFold) {
    [self.replyBgView mas_makeConstraints:^(MASConstraintMaker *make) {
      self.replyBgViewTopConstraint = make.top.equalTo(self.foldButton.mas_bottom).offset(6);
    }];
  } else {
    [self.replyBgView mas_makeConstraints:^(MASConstraintMaker *make) {
      self.replyBgViewTopConstraint = make.top.equalTo(self.contentTextView.mas_bottom).offset(6);
    }];
  }
}

- (NSString *)truncatedContentForText:(NSString *)text font:(UIFont *)font width:(CGFloat)width maxLines:(NSInteger)maxLines reserveWidthForSuffix:(NSString *)suffix {
  if (!text.length) { return @""; }
  CGFloat suffixW = [suffix sizeWithAttributes:@{ NSFontAttributeName: font }].width + 4;
  CGFloat w = width - suffixW;
  if (w <= 0) { w = width * 0.7; }
  NSTextStorage *storage = [[NSTextStorage alloc] initWithString:text attributes:@{ NSFontAttributeName: font }];
  NSLayoutManager *lm = [[NSLayoutManager alloc] init];
  NSTextContainer *tc = [[NSTextContainer alloc] initWithSize:CGSizeMake(w, CGFLOAT_MAX)];
  tc.lineFragmentPadding = 0;
  [lm addTextContainer:tc];
  [storage addLayoutManager:lm];
  NSUInteger glyphIndex = [lm glyphIndexForCharacterAtIndex:storage.length];
  NSRange lineRange;
  CGRect lineRect = [lm lineFragmentRectForGlyphAtIndex:0 effectiveRange:&lineRange];
  NSInteger line = 0;
  NSUInteger lastGlyph = 0;
  for (NSUInteger g = 0; g < glyphIndex && line < maxLines; ) {
    lineRect = [lm lineFragmentRectForGlyphAtIndex:g effectiveRange:&lineRange];
    lastGlyph = NSMaxRange(lineRange);
    line++;
    g = lastGlyph;
  }
  NSUInteger charIndex = [lm characterIndexForGlyphAtIndex:MIN(lastGlyph, glyphIndex)];
  if (charIndex >= text.length) { return text; }
  return [text substringToIndex:charIndex];
}

- (UIView *)createReplyViewWithModel:(ZLRepliedModel *)reply {
  UIView *container = [[UIView alloc] init];

  UIImageView *avatar = [[UIImageView alloc] init];
  avatar.layer.cornerRadius = 12;
  avatar.layer.masksToBounds = YES;
  [avatar sd_setImageWithURL:[NSURL URLWithString:reply.user.avatarUrl]];
  [container addSubview:avatar];

  UILabel *nameLabel = [[UILabel alloc] init];
  nameLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
  nameLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
  nameLabel.text = reply.user.nickname;
  [container addSubview:nameLabel];

  UILabel *timeLabel = [[UILabel alloc] init];
  timeLabel.font = [UIFont systemFontOfSize:11];
  timeLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
  timeLabel.text = reply.timeStr;
  [container addSubview:timeLabel];

  UILabel *contentLabel = [[UILabel alloc] init];
  contentLabel.font = [UIFont systemFontOfSize:14];
  contentLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.88];
  contentLabel.numberOfLines = 0;
  contentLabel.text = reply.content;
  [container addSubview:contentLabel];

  // 布局
  [avatar mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.top.equalTo(container).offset(6);
    make.size.mas_equalTo(CGSizeMake(24, 24));
  }];

  [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(avatar.mas_right).offset(6);
    make.top.equalTo(avatar);
  }];

  [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(nameLabel.mas_right).offset(6);
    make.centerY.equalTo(nameLabel);
  }];

  [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(nameLabel);
    make.top.equalTo(nameLabel.mas_bottom).offset(2);
    make.right.equalTo(container).offset(-6);
    make.bottom.equalTo(container).offset(-6);
  }];

  return container;
}



//- (void)configRepliesWithModel:(ZLCommentModel *)model {
//
//    // 1. 先清空（防复用）
//    [self.replyStackView.arrangedSubviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//
//    // 2. 没回复 or 未展开
//    if (model.beReplied.count == 0 || !model.showReplies) {
//        self.replyBgView.hidden = YES;
//        return;
//    }
//
//    self.replyBgView.hidden = NO;
//
//    // 3. 创建回复 View
//    for (ZLRepliedModel *reply in model.beReplied) {
//
//        UILabel *label = [[UILabel alloc] init];
//        label.numberOfLines = 0;
//        label.font = [UIFont systemFontOfSize:14];
//        label.textColor = UIColor.darkGrayColor;
//
//        NSString *text = [NSString stringWithFormat:@"%@：%@",
//                          reply.user.nickname,
//                          reply.content];
//
//        label.text = text;
//
//        [self.replyStackView addArrangedSubview:label];
//    }
//}




- (void)setupConstraints {

  [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.top.equalTo(self.contentView).offset(10);
    make.size.mas_equalTo(CGSizeMake(40, 40));
  }];

  [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.headerView.mas_right).offset(6);
    make.top.equalTo(self.headerView);
  }];

  [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.userNameLabel);
    make.top.equalTo(self.userNameLabel.mas_bottom).offset(1);
  }];

  [self.contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.userNameLabel);
    make.right.equalTo(self.contentView).offset(-12);
    make.top.equalTo(self.headerView.mas_bottom).offset(4);
  }];

  [self.foldButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.contentTextView);
    make.top.equalTo(self.contentTextView.mas_bottom).offset(2);
  }];
  //
  //  [self.buttonOfLiked mas_makeConstraints:^(MASConstraintMaker *make) {
  //    make.left.equalTo([self.contentView);
  //    make.top.equalTo(self.contentTextView.mas_bottom).offset(6);
  //  }];

  //  [self.buttonOfExpand mas_makeConstraints:^(MASConstraintMaker *make) {
  //    make.left.equalTo(self.contentTextView);
  //    make.right.equalTo(self.contentView).offset(-12);
  //    make.top.equalTo(self.foldButton.mas_bottom).offset(6);
  //    make.bottom.equalTo(self.contentView).offset(-10);
  //  }];
  [self.buttonOfExpand mas_makeConstraints:^(MASConstraintMaker *make) {
    make.right.equalTo(self.contentView).offset(-12);
    make.top.equalTo(self.contentTextView.mas_bottom).offset(2);
    make.width.mas_equalTo(70);
    make.height.mas_equalTo(20);
  }];

  __weak typeof(self) weakSelf = self;
  [self.replyBgView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(weakSelf.contentTextView);
    make.right.equalTo(weakSelf.contentView).offset(-12);
    weakSelf.replyBgViewTopConstraint = make.top.equalTo(weakSelf.buttonOfExpand.mas_bottom).offset(6);
    make.bottom.equalTo(weakSelf.contentView).offset(-12);
  }];

  [self.replyStackView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.replyBgView).insets(UIEdgeInsetsMake(8, 10, 8, 10));
  }];

}


- (void)setupViews {
  self.contentView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.06];
  self.contentView.layer.cornerRadius = 12;
  self.contentView.layer.masksToBounds = YES;

  self.headerView = [[UIImageView alloc] init];
  self.headerView.layer.masksToBounds = YES;
  self.headerView.layer.cornerRadius = 20;
  self.headerView.clipsToBounds = YES;
  self.headerView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
  [self.contentView addSubview:self.headerView];

  self.userNameLabel = [[UILabel alloc] init];
  self.userNameLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
  self.userNameLabel.textColor = UIColor.whiteColor;
  [self.contentView addSubview:self.userNameLabel];

  self.timeLabel = [[UILabel alloc] init];
  self.timeLabel.font = [UIFont systemFontOfSize:11];
  self.timeLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.55];
  [self.contentView addSubview:self.timeLabel];

  self.contentTextView = [[UITextView alloc] init];
  self.contentTextView.font = _contentFont();
  self.contentTextView.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.95];
  self.contentTextView.backgroundColor = UIColor.clearColor;
  self.contentTextView.scrollEnabled = NO;
  self.contentTextView.editable = NO;
  self.contentTextView.selectable = YES;
  self.contentTextView.textContainerInset = UIEdgeInsetsZero;
  self.contentTextView.textContainer.lineFragmentPadding = 0;
  // 与正文同色，避免系统对链接应用 tint 导致全文染色；仅通过 attributed 中对「展开」「收起」单独设色
  self.contentTextView.linkTextAttributes = @{
    NSForegroundColorAttributeName: [[UIColor whiteColor] colorWithAlphaComponent:0.95],
    NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)
  };
  [self.contentView addSubview:self.contentTextView];

  self.buttonOfLiked = [UIButton buttonWithType:UIButtonTypeCustom];
  self.buttonOfLiked.titleLabel.font = [UIFont systemFontOfSize:13];
  [self.buttonOfLiked setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
  [self.contentView addSubview:self.buttonOfLiked];

  self.foldButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.foldButton setTitle:@"全文" forState:UIControlStateNormal];
  [self.foldButton setTitleColor:_expandCollapseTintColor() forState:UIControlStateNormal];
  self.foldButton.titleLabel.font = [UIFont systemFontOfSize:14];
  [self.contentView addSubview:self.foldButton];

  self.buttonOfExpand = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.buttonOfExpand setTitle:@"展开回复" forState:UIControlStateNormal];
  [self.buttonOfExpand setTitleColor:_expandCollapseTintColor() forState:UIControlStateNormal];
  self.buttonOfExpand.titleLabel.font = [UIFont systemFontOfSize:13];
  self.buttonOfExpand.hidden = YES;
  [self.contentView addSubview:self.buttonOfExpand];

  self.replyBgView = [[UIView alloc] init];
  self.replyBgView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.08];
  self.replyBgView.layer.cornerRadius = 8;
  [self.contentView addSubview:self.replyBgView];

  self.replyStackView = [[UIStackView alloc] init];
  self.replyStackView.axis = UILayoutConstraintAxisVertical;
  self.replyStackView.spacing = 8;
  self.replyStackView.alignment = UIStackViewAlignmentFill;
  self.replyStackView.distribution = UIStackViewDistributionFill;
  [self.replyBgView addSubview:self.replyStackView];
}


- (void)awakeFromNib {
  [super awakeFromNib];
  // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

- (BOOL)isTextExceedThreeLines:(NSString *)text font:(UIFont *)font width:(CGFloat)width {

  UILabel *tempLabel = [[UILabel alloc] init];
  tempLabel.numberOfLines = 0;
  tempLabel.font = font;
  tempLabel.text = text;
  tempLabel.frame = CGRectMake(0, 0, width, CGFLOAT_MAX);
  [tempLabel sizeToFit];

  CGFloat lineHeight = font.lineHeight;
  NSInteger lines = ceil(tempLabel.frame.size.height / lineHeight);

  return lines > 3;
}


@end
