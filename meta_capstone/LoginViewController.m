//
//  LoginViewController.m
//  meta_capstone
//
//  Created by Nikita Singh on 7/5/22.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)didTapConnect:(id)sender {
    NSLog(@"User logged in successfully");
    // display view controller that needs to shown after successful login
    [self performSegueWithIdentifier:@"loginSegue" sender:nil];

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
