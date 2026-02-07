//
//  CommentViewController.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/24.
//

#import "CommentViewController.h"
#import <Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import "AlbumModel.h"
#import "SongModel.h"
#import "MainCommentCell.h"
#import "CommentHeaderView.h"
#import "SpotifyService.h"
#import "ZLCommentResponseModel.h"
#import "ZLCommentModel.h"
#import "CommentPager.h"
#import "SongListFooterView.h"
@interface CommentViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)UIImageView* backView;
@property (nonatomic, strong)UIVisualEffectView* blurView;
@property (nonatomic, strong)UIView* darkMaskView;
@property (nonatomic, strong)UILabel* titleLabel;
@property (nonatomic, strong)UIView* actionBackView;
@property (nonatomic, strong)UITableView* tableView;
@property (nonatomic, strong)UIButton* backButton;
@property (nonatomic, strong)UIVisualEffectView* backButtonBlurView;
@property (nonatomic, strong)UIButton* shareCommentButton;
@property (nonatomic, strong)UIVisualEffectView* shareCommentButtonBlurView;
@property (nonatomic, strong)CommentHeaderView* headerView;
@property (nonatomic, strong)NSMutableArray* commentsArray;
@property (nonatomic, strong) SongListFooterView *footerView;
//@property (nonatomic, assign)NSInteger page;
@property (nonatomic, strong)CommentPager* pager;
@end

@implementation CommentViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor clearColor];
  [self createBackView];
  [self setUpTopUI];
  [self createTitleLabel];
  [self createBackButton];
  [self createCommentButton];

  [self createPager];
  [self createTableView];
  [self setUpTableHeaderView];
  [self setupTableFooterView];
  [self loadComments];
  // Do any additional setup after loading the view.
}

- (void)createPager {
  self.commentsArray = [NSMutableArray array];
  self.pager = [CommentPager new];
  self.pager.limit = 20;
  self.pager.offset = 0;
  self.pager.hasMore = YES;
  self.pager.isLoading = NO;
}

- (void)createTableView {
  self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.estimatedRowHeight = 100;
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  self.tableView.backgroundColor = UIColor.clearColor;
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

  [self.tableView registerClass:[MainCommentCell class] forCellReuseIdentifier:@"cellOfComment"];

  [self.view addSubview:self.tableView];
  [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.equalTo(self.view);
    make.bottom.equalTo(self.view);
    make.top.equalTo(self.actionBackView.mas_bottom);
  }];
}

- (void)loadComments {
  if (self.pager.isLoading || !self.pager.hasMore) {
    [self.footerView setState:LoadMoreStateLoading];
    return;
  }
  self.pager.isLoading = YES;
  __weak typeof(self) weakSelf = self;
  SpotifyService* service = [SpotifyService sharedInstance];
  [service fetchAllCommentsOfSongs:self.songModel offset:self.pager.offset limit:self.pager.limit withCompletion:^(id  _Nonnull responseObject, NSError * _Nonnull error) {
    weakSelf.pager.isLoading = NO;
    ZLCommentResponseModel* responseModel = [ZLCommentResponseModel yy_modelWithJSON:responseObject];
    if (self.pager.offset == 0) {
      [weakSelf handleFirstResponse:responseModel];
    } else {
      [weakSelf handleMoreResponse:responseModel];
    }
  }];
  [self.headerView configureWithModel:self.songModel];
}

- (void)handleMoreResponse:(ZLCommentResponseModel *)response {
  [self.commentsArray addObjectsFromArray:response.comments];
  self.pager.offset += response.comments.count;
  self.pager.hasMore = response.more;
  CGFloat contentWidth = [UIScreen mainScreen].bounds.size.width - 12 - 40 - 8 - 12; // left padding + avatar + spacing + right padding
  for (ZLCommentModel *model in self.commentsArray) {
    model.needFold = [self isTextViewExceedThreeLines:model.content width:contentWidth];
    model.expandedContent = NO;
  }
  [self.tableView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  CGFloat offsetY = scrollView.contentOffset.y;
  CGFloat contentHeight = scrollView.contentSize.height;
  CGFloat height = scrollView.bounds.size.height;

  if (offsetY > contentHeight - height - 100) {
    [self loadComments];
  }
}


- (void)handleFirstResponse:(ZLCommentResponseModel *)responseModel {
  NSArray* array = responseModel.hotComments;
  for (ZLCommentModel* model in array) {
    NSLog(@"评论：%@", model.content);
    NSLog(@"楼中评论数：%ld", model.beReplied.count);
  }

  [self.commentsArray removeAllObjects];
  [self.commentsArray addObjectsFromArray:responseModel.hotComments];
  [self.commentsArray addObjectsFromArray:responseModel.comments];
  CGFloat contentWidth = [UIScreen mainScreen].bounds.size.width - 12 - 40 - 8 - 12; // left padding + avatar + spacing + right padding
  for (ZLCommentModel *model in self.commentsArray) {
    model.needFold = [self isTextViewExceedThreeLines:model.content width:contentWidth];
    model.expandedContent = NO;
  }
  self.pager.offset += responseModel.comments.count;
  self.pager.hasMore = responseModel.more;
  [self.tableView reloadData];
}

- (void)setupTableFooterView {
  self.footerView = [[SongListFooterView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 50)];
  self.tableView.tableFooterView = self.footerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.commentsArray.count;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//  return 120;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  MainCommentCell *cell =
  [tableView dequeueReusableCellWithIdentifier:@"cellOfComment" forIndexPath:indexPath];
  cell.backgroundColor = [UIColor clearColor];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  [cell configWithModel:[self.commentsArray objectAtIndex:indexPath.row] indexPath:indexPath target:self action:@selector(pressFoldButton:)];
  [cell.buttonOfExpand addTarget:self action:@selector(pressExpandReplies:) forControlEvents:UIControlEventTouchUpInside];
  cell.buttonOfExpand.tag = indexPath.row;
  return cell;
}

- (void)pressExpandReplies:(UIButton *)button {
    ZLCommentModel *model = self.commentsArray[button.tag];
    model.showReplies = !model.showReplies;
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:button.tag inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}



- (void)pressFoldButton:(UIButton *)button {
    ZLCommentModel *model = self.commentsArray[button.tag];
    model.expandedContent = !model.expandedContent;

    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:button.tag inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}



- (void)setUpTableHeaderView {
  if (!self.headerView) {
    self.headerView = [[CommentHeaderView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 80)];
  }
  self.tableView.tableHeaderView = self.headerView;
}

- (BOOL)isTextViewExceedThreeLines:(NSString *)text width:(CGFloat)width {
  NSTextStorage *storage = [[NSTextStorage alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]}];
  NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
  NSTextContainer *container = [[NSTextContainer alloc] initWithSize:CGSizeMake(width, CGFLOAT_MAX)];
  container.lineFragmentPadding = 0;
  [layoutManager addTextContainer:container];
  [storage addLayoutManager:layoutManager];
  NSUInteger glyphCount = [layoutManager numberOfGlyphs];
  __block NSInteger lines = 0;
  [layoutManager enumerateLineFragmentsForGlyphRange:NSMakeRange(0, glyphCount)
                                          usingBlock:^(CGRect rect,
                                                       CGRect usedRect,
                                                       NSTextContainer * _Nonnull textContainer,
                                                       NSRange glyphRange,
                                                       BOOL * _Nonnull stop) {
    lines++;
    if (lines > 3) *stop = YES;
  }];
  return lines > 3;
}




- (void)createCommentButton {
  UIView *shadowView = [[UIView alloc] init];
  shadowView.backgroundColor = UIColor.clearColor;
  shadowView.layer.shadowColor = UIColor.blackColor.CGColor;
  shadowView.layer.shadowOpacity = 0.28;
  shadowView.layer.shadowRadius = 16;
  shadowView.layer.shadowOffset = CGSizeMake(0, 8);
  [self.actionBackView addSubview:shadowView];

  [shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.right.equalTo(self.actionBackView.mas_right).offset(-20);
    make.top.equalTo(self.actionBackView).offset(24);
    make.width.mas_equalTo(36);
    make.height.mas_equalTo(36);
  }];
  //玻璃
  UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialLight];
  self.shareCommentButtonBlurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
  self.shareCommentButtonBlurView.clipsToBounds = YES;
  self.shareCommentButtonBlurView.layer.cornerRadius = 18;
  [shadowView addSubview:self.shareCommentButtonBlurView];

  [self.shareCommentButtonBlurView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(shadowView);
  }];

  // 玻璃高光层
  UIView *highlightView = [[UIView alloc] init];
  highlightView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.22];
  highlightView.userInteractionEnabled = NO;
  [self.shareCommentButtonBlurView.contentView addSubview:highlightView];
  [highlightView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.shareCommentButtonBlurView.contentView);
  }];

  // 玻璃描边
  self.shareCommentButtonBlurView.layer.borderWidth = 0.5;
  self.shareCommentButtonBlurView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3].CGColor;

  self.shareCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.shareCommentButton setImage:[[UIImage imageNamed:@"add.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
  [self.shareCommentButtonBlurView.contentView addSubview:self.shareCommentButton];
  [self.shareCommentButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.shareCommentButtonBlurView.contentView);
  }];
  [self.shareCommentButton addTarget:self action:@selector(shareMyComment) forControlEvents:UIControlEventTouchUpInside];
}

- (void)shareMyComment {
  [UIView animateWithDuration:0.15 animations:^{
    self.shareCommentButtonBlurView.transform = CGAffineTransformMakeScale(1.10, 1.10);
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:0.1 animations:^{
      self.shareCommentButtonBlurView.transform = CGAffineTransformIdentity;
      [self dismissViewControllerAnimated:YES completion:nil];
    }];
  }];
}

- (void)createBackButton {
  UIView *shadowView = [[UIView alloc] init];
  shadowView.backgroundColor = UIColor.clearColor;
  shadowView.layer.shadowColor = UIColor.blackColor.CGColor;
  shadowView.layer.shadowOpacity = 0.28;
  shadowView.layer.shadowRadius = 16;
  shadowView.layer.shadowOffset = CGSizeMake(0, 8);
  [self.actionBackView addSubview:shadowView];

  [shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.actionBackView.mas_left).offset(20);
    make.top.equalTo(self.actionBackView).offset(24);
    make.width.mas_equalTo(50);
    make.height.mas_equalTo(36);
  }];
  //玻璃
  UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialLight];
  self.backButtonBlurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
  self.backButtonBlurView.clipsToBounds = YES;
  self.backButtonBlurView.layer.cornerRadius = 18;
  [shadowView addSubview:self.backButtonBlurView];

  [self.backButtonBlurView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(shadowView);
  }];

  // 玻璃高光层
  UIView *highlightView = [[UIView alloc] init];
  highlightView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.22];
  highlightView.userInteractionEnabled = NO;
  [self.backButtonBlurView.contentView addSubview:highlightView];
  [highlightView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.backButtonBlurView.contentView);
  }];

  // 玻璃描边
  self.backButtonBlurView.layer.borderWidth = 0.5;
  self.backButtonBlurView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3].CGColor;

  self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.backButton setImage:[[UIImage imageNamed:@"back.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
  [self.backButtonBlurView.contentView addSubview:self.backButton];
  [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.backButtonBlurView.contentView);
  }];
  [self.backButton addTarget:self action:@selector(backToSearchPage) forControlEvents:UIControlEventTouchUpInside];
}

- (void)backToSearchPage {
  [UIView animateWithDuration:0.15 animations:^{
    self.backButtonBlurView.transform = CGAffineTransformMakeScale(1.10, 1.10);
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:0.1 animations:^{
      self.backButtonBlurView.transform = CGAffineTransformIdentity;
      [self dismissViewControllerAnimated:YES completion:nil];
    }];
  }];
}

- (void)createTitleLabel {
  // 阴影容器
  UIView *shadowView = [[UIView alloc] init];
  shadowView.backgroundColor = UIColor.clearColor;
  shadowView.layer.shadowColor = UIColor.blackColor.CGColor;
  shadowView.layer.shadowOpacity = 0.28;
  shadowView.layer.shadowRadius = 16;
  shadowView.layer.shadowOffset = CGSizeMake(0, 8);
  [self.actionBackView addSubview:shadowView];

  [shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(self.actionBackView);
    make.top.equalTo(self.actionBackView).offset(24);
    make.width.mas_equalTo(200);
    make.height.mas_equalTo(36);
  }];
  //玻璃
  UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialLight];
  UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
  blurView.clipsToBounds = YES;
  blurView.layer.cornerRadius = 18;
  [shadowView addSubview:blurView];

  [blurView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(shadowView);
  }];

  // 玻璃高光层
  UIView *highlightView = [[UIView alloc] init];
  highlightView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.22];
  highlightView.userInteractionEnabled = NO;
  [blurView.contentView addSubview:highlightView];
  [highlightView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(blurView.contentView);
  }];

  // 玻璃描边
  blurView.layer.borderWidth = 0.5;
  blurView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3].CGColor;

  // ===== 文字 Label =====
  UILabel *label = [[UILabel alloc] init];
  label.text = @"Comments";
  label.font = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
  label.textAlignment = NSTextAlignmentCenter;

  // 白色高亮文字 + 投影增强立体感
  label.textColor = [UIColor whiteColor];
  label.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
  label.shadowOffset = CGSizeMake(0, 1);

  [blurView.contentView addSubview:label];
  [label mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(blurView.contentView);
  }];
  self.titleLabel = label;
}




- (void)setUpTopUI {
  // 顶部容器
  self.actionBackView = [[UIView alloc] init];
  self.actionBackView.backgroundColor = UIColor.clearColor;
  [self.view addSubview:self.actionBackView];

  [self.actionBackView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.top.equalTo(self.view);
    make.height.mas_equalTo(80);
  }];
}


- (void)createBackView {
  self.backView = [[UIImageView alloc] initWithFrame:self.view.bounds];
  self.backView.contentMode = UIViewContentModeScaleAspectFill;
  self.backView.clipsToBounds = YES;
  [self.view addSubview:self.backView];

  self.blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
  self.blurView.frame = self.view.bounds;
  [self.view addSubview:self.blurView];

  self.darkMaskView = [[UIView alloc] initWithFrame:self.view.bounds];
  self.darkMaskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
  [self.view addSubview:self.darkMaskView];
  AlbumModel* album = self.songModel.album;
  SDImageResizingTransformer *transformer =
  [SDImageResizingTransformer transformerWithSize:CGSizeMake(200, 200)  scaleMode:SDImageScaleModeAspectFill];
  [self.backView sd_setImageWithURL:[NSURL URLWithString:album.picUrl] placeholderImage:nil options:SDWebImageScaleDownLargeImages context:@{
    SDWebImageContextImageTransformer: transformer
  }];
}



/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
