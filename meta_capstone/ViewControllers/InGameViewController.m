//
//  InGameViewController.m
//  meta_capstone
//
//  Created by Nikita Singh on 7/19/22.
//

#import "InGameViewController.h"

@interface InGameViewController ()

@end

@implementation InGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (IBAction)didTapClose:(id)sender {

    [self dismissViewControllerAnimated:true completion:nil];
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
