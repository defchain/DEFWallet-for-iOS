//
//  ExportKeystoreViewController.m
//  DEFWallet
//
//

#import "ExportKeystoreViewController.h"
#import "MBProgressHUD.h"

@interface ExportKeystoreViewController ()


@end

@implementation ExportKeystoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"export_keystore_title", @"export_keystore_title");
    
    self.textView.text = self.keystore;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)copyKeyStore:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.label.text = NSLocalizedString(@"copy_sucess", @"copy_sucess");
    hud.label.font = [UIFont systemFontOfSize:14.0];
    hud.userInteractionEnabled= NO;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1.25];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.textView.text;
}
@end
