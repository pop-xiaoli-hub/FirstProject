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
@implementation MainCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    [self setupViews];
    [self setupConstraints];
  }
  return self;
}


- (void)configWithModel:(ZLCommentModel *)model indexPath:(NSIndexPath *)indexPath target:(id)target action:(SEL)action {
  self.contentTextView.text = [model.content copy];
  ZLUserModel* user = model.user;
  SDImageResizingTransformer *transformer =
  [SDImageResizingTransformer transformerWithSize:CGSizeMake(200, 200)  scaleMode:SDImageScaleModeAspectFill];
  [self.headerView sd_setImageWithURL:[NSURL URLWithString:user.avatarUrl] placeholderImage:nil options:SDWebImageScaleDownLargeImages context:@{
    SDWebImageContextImageTransformer: transformer
  }];
  self.userNameLabel.text = [user.nickname copy];
  self.timeLabel.text = [model.timeStr copy];
  //  CGFloat lineHeight = self.contentTextView.font.lineHeight;
  if (model.needFold && !model.expandedContent) {
    self.contentTextView.textContainer.maximumNumberOfLines = 3;
    self.contentTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    self.foldButton.hidden = NO;
    [self.foldButton setTitle:@"全文" forState:UIControlStateNormal];
  } else {
    self.contentTextView.textContainer.maximumNumberOfLines = 0; // 展开
    self.foldButton.hidden = !model.needFold;
    [self.foldButton setTitle:@"收起" forState:UIControlStateNormal];
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
  self.foldButton.tag = indexPath.row;
  [self.foldButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (UIView *)createReplyViewWithModel:(ZLRepliedModel *)reply {
  UIView *container = [[UIView alloc] init];

  UIImageView *avatar = [[UIImageView alloc] init];
  avatar.layer.cornerRadius = 12;
  avatar.layer.masksToBounds = YES;
  [avatar sd_setImageWithURL:[NSURL URLWithString:reply.user.avatarUrl]];
  [container addSubview:avatar];

  UILabel *nameLabel = [[UILabel alloc] init];
  nameLabel.font = [UIFont boldSystemFontOfSize:13];
  nameLabel.textColor = UIColor.whiteColor;
  nameLabel.text = reply.user.nickname;
  [container addSubview:nameLabel];

  UILabel *timeLabel = [[UILabel alloc] init];
  timeLabel.font = [UIFont systemFontOfSize:11];
  timeLabel.textColor = UIColor.grayColor;
  timeLabel.text = reply.timeStr;
  [container addSubview:timeLabel];

  UILabel *contentLabel = [[UILabel alloc] init];
  contentLabel.font = [UIFont systemFontOfSize:15];
  contentLabel.textColor = UIColor.whiteColor;
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
    make.left.top.equalTo(self.contentView).offset(12);
    make.size.mas_equalTo(CGSizeMake(40, 40));
  }];

  [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.headerView.mas_right).offset(8);
    make.top.equalTo(self.headerView);
  }];

  [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.userNameLabel);
    make.top.equalTo(self.userNameLabel.mas_bottom).offset(2);
  }];

  [self.contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.userNameLabel);
    make.right.equalTo(self.contentView).offset(-12);
    make.top.equalTo(self.headerView.mas_bottom).offset(8);
  }];

  [self.foldButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.contentTextView);
    make.top.equalTo(self.contentTextView.mas_bottom).offset(4);
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
    make.top.equalTo(self.foldButton.mas_bottom).offset(6);
    make.width.mas_equalTo(70);
    make.height.mas_equalTo(20);
  }];

  [self.replyBgView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.contentTextView);
    make.right.equalTo(self.contentView).offset(-12);
    make.top.equalTo(self.buttonOfExpand.mas_bottom).offset(6);
    make.bottom.equalTo(self.contentView).offset(-10);
  }];

  [self.replyStackView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.replyBgView).insets(UIEdgeInsetsMake(6, 6, 6, 6));
  }];

}


- (void)setupViews {
  self.headerView = [[UIImageView alloc] init];
  self.headerView.layer.masksToBounds = YES;
  self.headerView.layer.cornerRadius = 20;
  self.headerView.clipsToBounds = YES;
  self.headerView.backgroundColor = UIColor.lightGrayColor;
  [self.contentView addSubview:self.headerView];

  self.userNameLabel = [[UILabel alloc] init];
  self.userNameLabel.font = [UIFont boldSystemFontOfSize:17];
  [self.contentView addSubview:self.userNameLabel];

  self.timeLabel = [[UILabel alloc] init];
  self.timeLabel.font = [UIFont systemFontOfSize:12];
  self.timeLabel.textColor = UIColor.grayColor;
  [self.contentView addSubview:self.timeLabel];

  self.contentTextView = [[UITextView alloc] init];
  self.contentTextView.font = [UIFont systemFontOfSize:17];
  self.contentTextView.textColor = UIColor.whiteColor;
  self.contentTextView.backgroundColor = UIColor.clearColor;
  self.contentTextView.scrollEnabled = NO;
  self.contentTextView.editable = NO;
  self.contentTextView.selectable = YES;
  self.contentTextView.textContainerInset = UIEdgeInsetsZero;
  self.contentTextView.textContainer.lineFragmentPadding = 0;
  [self.contentView addSubview:self.contentTextView];

  self.buttonOfLiked = [UIButton buttonWithType:UIButtonTypeCustom];
  self.buttonOfLiked.titleLabel.font = [UIFont systemFontOfSize:13];
  [self.buttonOfLiked setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
  [self.contentView addSubview:self.buttonOfLiked];

  self.foldButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.foldButton setTitle:@"全文" forState:UIControlStateNormal];
  [self.foldButton setTitleColor:UIColor.systemBlueColor forState:UIControlStateNormal];
  self.foldButton.titleLabel.font = [UIFont systemFontOfSize:14];
  [self.contentView addSubview:self.foldButton];

  self.buttonOfExpand = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.buttonOfExpand setTitle:@"展开" forState:UIControlStateNormal];
  [self.buttonOfExpand setTitleColor:UIColor.darkGrayColor forState:UIControlStateNormal];
  self.buttonOfExpand.titleLabel.font = [UIFont systemFontOfSize:14];
  self.buttonOfExpand.hidden = YES;
  [self.contentView addSubview:self.buttonOfExpand];

  self.replyBgView = [[UIView alloc] init];
  self.replyBgView.backgroundColor = [UIColor clearColor];
  self.replyBgView.layer.cornerRadius = 4;
  [self.contentView addSubview:self.replyBgView];

  self.replyStackView = [[UIStackView alloc] init];
  self.replyStackView.axis = UILayoutConstraintAxisVertical;
  self.replyStackView.spacing = 6;
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
