//
//  WalletDetailViewController.m
//  DEFWallet
//
//

#import "WalletDetailViewController.h"
#import "ETHWebService.h"
#import "MBProgressHUD.h"
#import <string>
#import "ExportKeystoreViewController.h"
#import "ExportWalletPKView.h"
#import "EditPasswordViewController.h"

#import <defwallet/def_wallet_manager.h>
#import <defwallet/def_wallet.h>



#define kNotificationNameCreateOrImportWalletSuccess @"kNotificationNameCreateOrImportWalletSuccess"

@interface WalletDetailViewController ()<ExportWalletPKViewDelegate>

@property(nonatomic, strong) MBProgressHUD *progressHUD;

@property(nonatomic, strong) ExportWalletPKView *exportWalletPKView;

@end

@implementation WalletDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.walletName;
    self.addressLabel.text = self.address;
    self.walletNameLabel.text = self.walletName;
    
    [self loadExportPKView];
    
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.progressHUD];
    
    [[ETHWebService shareInstance] getETHBalance:self.address success:^(double balance) {
        
        [[ETHWebService shareInstance] getCurrentETHRMBPrice:^(double rmbPrice) {
            self.priceLabel.text = [NSString stringWithFormat:@"¥%lf",rmbPrice * balance];
        } failed:^{
            NSLog(@"load eth price failed");
        }];
        
    } failed:^{
        NSLog(@"load balance of eth failed");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadExportPKView {
    
    //export private key view
    NSArray *keystoreNibContents = [[NSBundle mainBundle] loadNibNamed:@"export_wallet_pk" owner:nil options:nil];
    self.exportWalletPKView = [keystoreNibContents lastObject];
    
    CGRect f = self.exportWalletPKView.frame;
    f.origin.x = 0;
    f.origin.y = 0;
    f.size.width = self.view.frame.size.width;
    f.size.height = self.view.frame.size.height;
    [self.exportWalletPKView setFrame:f];
    self.exportWalletPKView.hidden = YES;
    [self.view addSubview:self.exportWalletPKView];
    
}


- (void)onCopyButtonClick {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.label.text = NSLocalizedString(@"copy_sucess", @"copy_sucess");
    hud.label.font = [UIFont systemFontOfSize:14.0];
    hud.userInteractionEnabled= NO;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1.25];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.exportWalletPKView.pkLabel.text;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        
        if(indexPath.row == 0) {
            
            EditPasswordViewController *viewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"EditPasswordViewController"];
            viewCtrl.address = self.address;
            [self presentViewController:viewCtrl animated:YES completion:nil];
            
        } else if (indexPath.row == 1) {
            
            __weak WalletDetailViewController *weakSelf = self;
            
            //export private key
            UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"authentication", @"authentication")
                                                                               message:NSLocalizedString(@"enter_password_tips", @"enter_password_tips")
                                                                        preferredStyle:UIAlertControllerStyleAlert];
            [alertCtrl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = NSLocalizedString(@"enter_password_placeholder", @"enter_password_placeholder");
                textField.secureTextEntry = YES;
            }];
            [alertCtrl addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault handler:nil]];
            [alertCtrl addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                weakSelf.progressHUD.label.text = NSLocalizedString(@"validating_password", @"validating_password");
                [weakSelf.progressHUD showAnimated:YES];
                
                UITextField *field = alertCtrl.textFields.firstObject;
                NSString *password = field.text;
                
                dispatch_queue_t queue =  dispatch_queue_create("io.defensor.exportPK", nil);
                dispatch_async(queue, ^{
                    
                    libdefwallet::DEFWalletManager *walletManager = libdefwallet::DEFWalletManager::shareInstance();
                    libdefwallet::DEFWallet *wallet = walletManager->findWalletByAddress([weakSelf.address UTF8String]);
                    bool isValidate = wallet->validatePassword([password UTF8String]);
                    
                    if (isValidate){

                        std::string pk = wallet->exportPrivateKey([password UTF8String]);

                        dispatch_async(dispatch_get_main_queue(), ^{

                            [weakSelf.progressHUD hideAnimated:YES];

                            weakSelf.exportWalletPKView.hidden = NO;
                            weakSelf.exportWalletPKView.delegate = self;
                            weakSelf.exportWalletPKView.pkLabel.text = [NSString stringWithCString:pk.c_str() encoding:NSUTF8StringEncoding];

                        });
                        return;
                    }

                    dispatch_async(dispatch_get_main_queue(), ^{

                        //password incorrect
                        weakSelf.progressHUD.label.text = NSLocalizedString(@"validate_password_failed", @"validate_password_failed");
                        [weakSelf.progressHUD showAnimated:YES];
                        [weakSelf.progressHUD hideAnimated:YES afterDelay:1.25];
                    });
                });
                
            }]];
            [self presentViewController:alertCtrl animated:YES completion:nil];
            
        } else if (indexPath.row == 2) {
            
            __weak WalletDetailViewController *weakSelf = self;
            
            //export keystore
            UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"authentication", @"authentication")
                                                                               message:NSLocalizedString(@"enter_password_tips", @"enter_password_tips")
                                                                        preferredStyle:UIAlertControllerStyleAlert];
            [alertCtrl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = NSLocalizedString(@"enter_password_placeholder", @"enter_password_placeholder");
                textField.secureTextEntry = YES;
            }];
            [alertCtrl addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault handler:nil]];
            [alertCtrl addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                weakSelf.progressHUD.label.text = NSLocalizedString(@"validating_password", @"validating_password");
                [weakSelf.progressHUD showAnimated:YES];
                
                UITextField *field = alertCtrl.textFields.firstObject;
                NSString *password = field.text;
                
                dispatch_queue_t queue =  dispatch_queue_create("io.defensor.exportKS", nil);
                dispatch_async(queue, ^{
                    
                    libdefwallet::DEFWalletManager *walletManager = libdefwallet::DEFWalletManager::shareInstance();
                    libdefwallet::DEFWallet *wallet = walletManager->findWalletByAddress([weakSelf.address UTF8String]);
                    bool isValidate = wallet->validatePassword([password UTF8String]);
                    
                    if (isValidate){
                        
                        //export keystore
                        std::string ks = wallet->exportKeystore();
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [weakSelf.progressHUD hideAnimated:YES];
                            
                            //jump to export keystore page
                            ExportKeystoreViewController *viewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"ExportKeystoreViewController"];
                            viewCtrl.keystore = [NSString stringWithCString:ks.c_str() encoding:NSUTF8StringEncoding];
                            [self.navigationController pushViewController:viewCtrl animated:YES];
                            
                        });
                        return;
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        //password is incorrect
                        weakSelf.progressHUD.label.text = NSLocalizedString(@"validate_password_failed", @"validate_password_failed");
                        [weakSelf.progressHUD showAnimated:YES];
                        [weakSelf.progressHUD hideAnimated:YES afterDelay:1.25];
                    });
                });
                
            }]];
            [self presentViewController:alertCtrl animated:YES completion:nil];
        }
        
    } else if (indexPath.section == 2){
        
        __weak WalletDetailViewController *weakSelf = self;
        
        //delete wallet
        UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"authentication", @"authentication")
                                                                           message:NSLocalizedString(@"enter_password_tips", @"enter_password_tips")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
        [alertCtrl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = NSLocalizedString(@"enter_password_placeholder", @"enter_password_placeholder");
            textField.secureTextEntry = YES;
        }];
        [alertCtrl addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault handler:nil]];
        [alertCtrl addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            weakSelf.progressHUD.label.text = NSLocalizedString(@"validating_password", @"validating_password");
            [weakSelf.progressHUD showAnimated:YES];
            
            UITextField *field = alertCtrl.textFields.firstObject;
            NSString *password = field.text;
            
            dispatch_queue_t queue =  dispatch_queue_create("io.defensor.deletewallet", nil);
            dispatch_async(queue, ^{
                
                libdefwallet::DEFWalletManager *walletManager = libdefwallet::DEFWalletManager::shareInstance();
                libdefwallet::DEFWallet *wallet = walletManager->findWalletByAddress([weakSelf.address UTF8String]);
                bool isValidate = wallet->validatePassword([password UTF8String]);
                
                if (isValidate){
                    
                    //delete wallet
                    walletManager->deleteWallet([self.address UTF8String]);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        weakSelf.progressHUD.label.text = NSLocalizedString(@"removed_mnemonic_finished", @"removed_mnemonic_finished");
                        [weakSelf.progressHUD showAnimated:YES];
                        [weakSelf.progressHUD hideAnimated:YES afterDelay:1.25];
                        
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameCreateOrImportWalletSuccess object:nil];
                        
                    });
                    return;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //password is incorrect
                    weakSelf.progressHUD.label.text = NSLocalizedString(@"validate_password_failed", @"validate_password_failed");
                    [weakSelf.progressHUD showAnimated:YES];
                    [weakSelf.progressHUD hideAnimated:YES afterDelay:1.25];
                });
            });
            
        }]];
        [self presentViewController:alertCtrl animated:YES completion:nil];
    }
}

@end
