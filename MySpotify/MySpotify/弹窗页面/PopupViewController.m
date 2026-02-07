//
//  PopupViewController.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/23.
//

#import "PopupViewController.h"
#import "PopupView.h"
#import <Masonry.h>
#import "ArtistModel.h"
#import <SDWebImage/SDWebImage.h>
#import "SpotifyService.h"
#import "ArtistDetailResponseModel.h"
#import <SafariServices/SafariServices.h>
@interface PopupViewController ()
@property (nonatomic, strong)PopupView* popupView;
@property (nonatomic, strong)UIScrollView* scrollView;
@end

@implementation PopupViewController



- (void)viewDidLoad {
  [super viewDidLoad];
  self.popupView = [[PopupView alloc] init];
  //self.view.userInteractionEnabled = YES;
 // UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTapped)];
  //[self.view addGestureRecognizer:tap];
  [self.view addSubview:self.popupView];
  [self.popupView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self.view);
    make.width.mas_equalTo(320);
    make.height.mas_equalTo(400);
  }];
  self.popupView.title.text = [self.artistModel.name copy];
  [self setBackView];
  [self.popupView.linkButton addTarget:self action:@selector(openArtistWebPage) forControlEvents:UIControlEventTouchUpInside];
  [self.popupView.closeButton addTarget:self action:@selector(closeTapped) forControlEvents:UIControlEventTouchUpInside];
}





- (void)setBackView {
  self.popupView.backView.hidden = NO;
  SDImageResizingTransformer *transformer = [SDImageResizingTransformer transformerWithSize:CGSizeMake(200, 200) scaleMode:SDImageScaleModeAspectFill];
  [self.popupView.backView sd_setImageWithURL:[NSURL URLWithString:self.artistModel.picUrl] placeholderImage:nil options:SDWebImageScaleDownLargeImages context:@{ SDWebImageContextImageTransformer: transformer, SDWebImageContextImageThumbnailPixelSize: @(CGSizeMake(200, 200)), SDWebImageContextImageForceDecodePolicy: @(SDImageForceDecodePolicyNever)
  }];
  [self fetchArtistDetailData];
}


- (void)fetchArtistDetailData {
  SpotifyService* service = [SpotifyService sharedInstance];
  __weak typeof(self) weakSelf = self;
  [service fetchArtistDetailWithId:weakSelf.artistModel.id ompletion:^(id  _Nonnull responseObject, NSError * _Nonnull error) {
    ArtistDetailResponseModel* responseModel = [ArtistDetailResponseModel yy_modelWithJSON:responseObject];
    weakSelf.artistModel = responseModel.artist;
    NSLog(@"%@", [weakSelf.artistModel.briefDesc copy]);
    [weakSelf.popupView configureWithDetailData:weakSelf.artistModel];
  }];
}


- (void)closeTapped {
  [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)openArtistWebPage {
  NSURL *url = [NSURL URLWithString:[self.artistModel webUrl]];
  if (!url) {
    return;
  }
  SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:url];
  [self presentViewController:safariVC animated:YES completion:nil];
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
