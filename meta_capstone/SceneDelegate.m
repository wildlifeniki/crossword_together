//
//  SceneDelegate.m
//  meta_capstone
//
//  Created by Nikita Singh on 7/5/22.
//

#import "SceneDelegate.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "Parse/Parse.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {

        configuration.applicationId = @"EeN1Wkryoazn9PU7RiSnGwmvUgSUyicPVZ1ggbsU";
        configuration.clientKey = @"21dYsQdc2ObMbLHcTg007PzPDVw5lqewyPDDjdlS";
        configuration.server = @"https://parseapi.back4app.com";
    }];

    [Parse initializeWithConfiguration:config];
    
    
    if (!FBSDKAccessToken.currentAccessToken.isExpired) {
        NSLog(@"skip login screen");
        
        dispatch_async(dispatch_get_main_queue(), ^{[FBSDKProfile loadCurrentProfileWithCompletion:^(FBSDKProfile *profile, NSError *error) {
            if (profile) {
                NSLog(@"profile exists");
                
                
                //check whether user exists in database
                PFQuery *query = [PFQuery queryWithClassName:@"AppUser"];
                [query whereKey:@"fbID" equalTo:profile.userID];
                NSArray *userObjects = [query findObjects];
                if ([userObjects count] == 0) {
                    //user doesnt exist, create user

                    PFObject *user = [PFObject objectWithClassName:@"AppUser"]; //this contains data for each user

                    NSLog(@"user doesn't exist yet, creating user");
                
                    user[@"fbID"] = [NSString stringWithFormat:@"%@", profile.userID];
                    user[@"name"] = [NSString stringWithFormat:@"%@ %@", profile.firstName, profile.lastName];
                    user[@"pfpURLString"] = [NSString stringWithFormat:@"%@", [profile imageURLForPictureMode:FBSDKProfilePictureModeSquare size:CGSizeMake(128, 128)]];
                    user[@"totalGames"] = @0;
                    user[@"bestTime"] = @0;
                    user[@"avgTime"] = @0;
                    user[@"recentlyPlayedWith"] = [NSMutableArray new];
                
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (succeeded) { NSLog(@"user saved"); }
                        else { NSLog(@"user did not save"); }
                    }];
                
                    NSLog(@"%@", user);
                }
                
                //create one object to track current active user id (use this id to get info about current user)
                PFQuery *idQuery = [PFQuery queryWithClassName:@"ID"];
                NSArray *idObjects = [idQuery findObjects];
                if ([idObjects count] == 0) {
                    //set current active id
                    PFObject *currUserID = [PFObject objectWithClassName:@"ID"]; //this is how we know what information to show on selfProfile
                    currUserID[@"fbID"] = [NSString stringWithFormat:@"%@", profile.userID];
                    [currUserID saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (succeeded) { NSLog(@"ID saved"); }
                        else { NSLog(@"ID did not save"); }
                    }];
                    
                }
                
            }
        }];
        });
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    }
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
