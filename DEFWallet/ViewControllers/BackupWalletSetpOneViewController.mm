//
//  BackupWalletSetpOneViewController.m
//  DEFWallet
//
//

#import "BackupWalletSetpOneViewController.h"
#import "BackupMnemonicViewController.h"


#import <defwallet/def_wallet_manager.h>
#import <defwallet/def_wallet.h>

#import "MBProgressHUD.h"

@interface BackupWalletSetpOneViewController ()

//loading
@property(nonatomic, strong) MBProgressHUD *progressHUD;

@end

@implementation BackupWalletSetpOneViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUIs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


/**
 Setup UI
 */
- (void)setupUIs {
    
    //set title
    self.title = NSLocalizedString(@"backup_wallet_title", @"backup_wallet_title");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //add loading view
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.progressHUD];
}

- (void)showPwdEnterAlertView {
    
    __weak BackupWalletSetpOneViewController *weakSelf = self;
    
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"authentication", @"authentication")
                                                                       message:NSLocalizedString(@"enter_password_tips", @"enter_password_tips")
                                                                preferredStyle:UIAlertControllerStyleAlert];
    [alertCtrl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"enter_password_placeholder", @"enter_password_placeholder");
        textField.secureTextEntry = YES;
    }];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault handler:nil]];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *textField = alertCtrl.textFields.firstObject;
        NSString *password = textField.text;
        
        weakSelf.progressHUD.label.text = NSLocalizedString(@"validating_password", @"validating_password");
        [weakSelf.progressHUD showAnimated:YES];
        
        dispatch_queue_t queue =  dispatch_queue_create("io.defensor.backupwalletstepone", nil);
        dispatch_async(queue, ^{
            
            libdefwallet::DEFWalletManager *walletManager = libdefwallet::DEFWalletManager::shareInstance();
            libdefwallet::DEFWallet *wallet = walletManager->findWalletByAddress([self.address UTF8String]);
            bool isValidate = wallet->validatePassword([password UTF8String]);
            
            
            NSString *walletAddress = [NSString stringWithCString:wallet->getAddress().c_str() encoding:NSUTF8StringEncoding];
            NSString *mnemonic = [NSString stringWithCString:wallet->getMnemonic().c_str() encoding:NSUTF8StringEncoding];
            
            if (isValidate){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                   
                    //password is correct
                    weakSelf.progressHUD.label.text = NSLocalizedString(@"validate_password_success", @"validate_password_success");
                    [weakSelf.progressHUD hideAnimated:YES afterDelay:1.25];
                    
                    //jum to next view
                    BackupMnemonicViewController *viewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"BackupMnemonicViewController"];
                    viewCtrl.address = walletAddress;
                    viewCtrl.mnemonic = mnemonic;
                    [self.navigationController pushViewController:viewCtrl animated:YES];
                });
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //password is in correct
                weakSelf.progressHUD.label.text = NSLocalizedString(@"validate_password_failed", @"validate_password_failed");;
                [weakSelf.progressHUD hideAnimated:YES afterDelay:1.25];
            });
        });
        
    }]];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

- (IBAction)onBackupWalletBtnClick:(id)sender {
    
    //show alert view
    [self showPwdEnterAlertView];
}
@end
