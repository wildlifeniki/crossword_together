//
//  meta_capstoneTests.m
//  meta_capstoneTests
//
//  Created by Nikita Singh on 7/5/22.
//

#import <XCTest/XCTest.h>
#import "LoginViewController.h"
#import "LeaderboardViewController.h"
#import "Parse/Parse.h"

@interface meta_capstoneTests : XCTestCase

@end

@implementation meta_capstoneTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testLeaderboard {
    LeaderboardViewController *leaderboardViewController = [[LeaderboardViewController alloc] init];
    [leaderboardViewController getLeaderboard];
    NSNumber *first = leaderboardViewController.usersArray.firstObject[@"avgTime"];
    NSNumber *last = leaderboardViewController.usersArray.lastObject[@"avgTime"];
    
    XCTAssertTrue(first.intValue <= last.intValue);
}

@end
