//
//  SceneDelegate.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/11/6.
//

#import "SceneDelegate.h"
#import "LoginPageController.h"
#import "HomePageController.h"
#import "MinePageController.h"
#import "SearchPageController.h"
@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
//  LoginPageController* loginPageController = [[LoginPageController alloc] init];
//  UINavigationController* LoginPageNavigationController = [[UINavigationController alloc] initWithRootViewController:loginPageController];
//  self.window.rootViewController = LoginPageNavigationController;
//  [self.window makeKeyAndVisible];


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
    tab.view.backgroundColor = [UIColor blackColor];
    self.window.rootViewController = tab;


//  BOOL isLogggedIn = [[NSUserDefaults standardUserDefaults]boolForKey:@"isLoggendIn"];
//  if(isLogggedIn) {
//    UITabBarController* tab = [[UITabBarController alloc] init];
//    HomePageController* vc1 = [[HomePageController alloc] init];
//    UINavigationController* nav1 = [[UINavigationController alloc] initWithRootViewController:vc1];
//    UIImage* image1 = [[UIImage imageNamed:@"mainpage.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    vc1.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:image1 tag:101];
//
//    SearchPageController* vc2 = [[SearchPageController alloc] init];
//    UINavigationController* nav2 = [[UINavigationController alloc] initWithRootViewController:vc2];
//    UIImage* image2 = [[UIImage imageNamed:@"searchpage.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    vc2.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:image2 tag:102];
//
//    MinePageController* vc3 = [[MinePageController alloc] init];
//    UINavigationController* nav3 = [[UINavigationController alloc] initWithRootViewController:vc3];
//    UIImage* image3 = [[UIImage imageNamed:@"personal.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    vc3.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:image3 tag:103];
//    
//    tab.viewControllers = @[nav1, nav2, nav3];
//    tab.view.backgroundColor = [UIColor blackColor];
//    self.window.rootViewController = tab;
//
//  } else {
//    LoginPageController* vc = [[LoginPageController alloc] init];
//    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
//    self.window.rootViewController = nav;
//  }
//  [self.window makeKeyAndVisible];



  // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
  // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
  // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
}


- (void)sceneDidDisconnect:(UIScene *)scene {
  // Called as the scene is being released by the system.
  // This occurs shortly after the scene enters the background, or when its session is discarded.
  // Release any resources associated with this scene that can be re-created the next time the scene connects.
  // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
  // Called when the scene has moved from an inactive state to an active state.
  // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
  // Called when the scene will move from an active state to an inactive state.
  // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
  // Called as the scene transitions from the background to the foreground.
  // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
  // Called as the scene transitions from the foreground to the background.
  // Use this method to save data, release shared resources, and store enough scene-specific state information
  // to restore the scene back to its current state.
}


@end
