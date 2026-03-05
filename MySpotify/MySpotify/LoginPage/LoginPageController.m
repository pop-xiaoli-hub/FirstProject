//
//  LoginPageController.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/11/6.
//

#import "LoginPageController.h"
#import "LoginPageView.h"
#import "LoginController.h"
#import "SceneDelegate.h"
#import "HomePageController.h"
#import "SearchPageController.h"
#import "MinePageController.h"
#import "SpotifyService.h"
#import "SongModel.h"
@interface LoginPageController ()
@property (nonatomic, strong)LoginPageView* loginPageView;
@end

@implementation LoginPageController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor blackColor];
  [self findMyFont];
  _loginPageView  = [[LoginPageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
  [self.view addSubview:_loginPageView];
  [self.loginPageView.buttonOfLogin addTarget:self action:@selector(pressLogIn:) forControlEvents:UIControlEventTouchUpInside];
  [self.loginPageView.buttonOfSignUpFree addTarget:self action:@selector(pressSignUpFree:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)pressLogIn:(UIButton* )button {
//  LoginController* vc = [[LoginController alloc] init];
//  [self presentViewController:vc animated:YES completion:nil];
  SpotifyService* service = [SpotifyService sharedInstance];
  [service fetchRecommendedSongs:^(NSArray* array, NSError* error) {
    for (SongModel* model in array) {
      NSLog(@"歌曲名称：%@", model.name);
    }
  }];
}



- (void)pressSignUpFree:(UIButton* )button {

  UITabBarController* tab = [[UITabBarController alloc] init];
  HomePageController* vc1 = [[HomePageController alloc] init];
  UINavigationController* nav1 = [[UINavigationController alloc] initWithRootViewController:vc1];
  UIImage* image1 = [[UIImage imageNamed:@"mainpage.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
  vc1.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:image1 tag:101];

  SearchPageController* vc2 = [[SearchPageController alloc] init];
  UINavigationController* nav2 = [[UINavigationController alloc] initWithRootViewController:vc2];
  UIImage* image2 = [[UIImage imageNamed:@"searchpage.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
  vc2.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:image2 tag:102];

  MinePageController* vc3 = [[MinePageController alloc] init];
  UINavigationController* nav3 = [[UINavigationController alloc] initWithRootViewController:vc3];
  UIImage* image3 = [[UIImage imageNamed:@"personal.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
  vc3.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:image3 tag:103];
  tab.viewControllers = @[nav1, nav2, nav3];

  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoggedIn"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  UIWindowScene* scene = (UIWindowScene* )UIApplication.sharedApplication.connectedScenes.allObjects.firstObject;
  SceneDelegate* sceneDelegate = (SceneDelegate* )scene.delegate;
  /*
   iOS13后，Apple引入的多场景，每个场景都有自己的UIWindowScene、SceneDelegate、window，如果想要修改根视
   */
  //[self.navigationController pushViewController:vc animated:YES];
  [UIView transitionWithView:sceneDelegate.window duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
      sceneDelegate.window.rootViewController = tab;
  } completion:nil];
}



- (void)findMyFont {
  for(NSString *familyname in [UIFont familyNames]){
    NSLog(@"family: %@",familyname);
    for(NSString *fontName in [UIFont fontNamesForFamilyName:familyname]){
      NSLog(@"----font: %@",fontName);
    }
    NSLog(@"--------------");
  }
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
