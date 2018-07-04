//
//  TransactionViewController.m
//  DEFWallet
//
//

#import "TransactionViewController.h"
#import "UIColor+Category.h"
#import "NSString+Category.h"
#import "ETHWebService.h"
#import "MBProgressHUD.h"
#import "TransactionResultViewController.h"
#import "QRScanViewController.h"

#import <defwallet/def_wallet_manager.h>
#import <defwallet/def_wallet.h>


@interface TransactionViewController ()<QRScanViewDelegate>

@property(nonatomic, assign) NSInteger gas;

@property(nonatomic, assign) NSInteger nonce;

@property(nonatomic, strong) MBProgressHUD *progressHUD;

@end

@implementation TransactionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.titleView setBackgroundColor:[UIColor colorWithRGBHex:0x273D54]];
    self.gasLabel.text = [NSString stringWithFormat:@"%f",self.gasSlider.value];
    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@",self.coinName,NSLocalizedString(@"transfer", @"transfer")];
    
    if ([self.coinName isEqualToString:@"ETH"]) {
    
        //default gas limit
        self.gas = 21000;
    } else {
        
        
        self.gas = 53000;
    }
    self.gasLabel.text = [NSString stringWithFormat:@"%lf",(self.gasSlider.value * pow(10, 9) * self.gas) / pow(10, 18)];

    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.progressHUD];
    
    [[ETHWebService shareInstance] getTransactionCount:self.address success:^(NSInteger n) {
        self.nonce = n;
    } failed:^{
        NSLog(@" get nonce failed");
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 the function for Delegate return QRCode's info
 
 @param result result string
 */
- (void)onScanQRCodeForResult:(NSString *)result {
    self.addressTextField.text = result;
}

- (IBAction)gasSoliderChanged:(id)sender {
    
    self.gasLabel.text = [NSString stringWithFormat:@"%lf",(self.gasSlider.value * pow(10, 9) * self.gas) / pow(10, 18)];
}

- (IBAction)textValueChanged:(id)sender {
    
    if ([self.addressTextField.text isNotEmpty]
            && [self.amountTextField.text isNotEmpty]) {
        
        self.submitButton.enabled = YES;
        [self.submitButton setBackgroundColor:[UIColor colorWithRGBHex:0xF7931A]];
        
    } else {
        
        self.submitButton.enabled = NO;
        [self.submitButton setBackgroundColor:[UIColor colorWithRGBHex:0xCCCCCC]];
    }
}

- (IBAction)onSubmitButtonClick:(id)sender {
    
    __weak TransactionViewController *weakSelf = self;
    
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"authentication", @"authentication") message:NSLocalizedString(@"enter_password_tips", @"enter_password_tips") preferredStyle:UIAlertControllerStyleAlert];
    [alertCtrl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"enter_password_placeholder", @"enter_password_placeholder");
        textField.secureTextEntry = YES;
    }];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault handler:nil]];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        self.progressHUD.label.text = NSLocalizedString(@"validating_password", @"validating_password");
        [self.progressHUD showAnimated:YES];
        
        UITextField *textField = alertCtrl.textFields.firstObject;
        NSString *password = textField.text;
        
        NSString *from = [NSString stringWithFormat:@"0x%@",self.address];
        NSString *to = self.addressTextField.text;
        double value = [self.amountTextField.text doubleValue];
        double gasPrice = self.gasSlider.value;
        
        dispatch_queue_t queue = dispatch_queue_create("io.defensor.transaction", nil);
        dispatch_async(queue, ^{
            
            libdefwallet::DEFWalletManager *walletManager = libdefwallet::DEFWalletManager::shareInstance();
            libdefwallet::DEFWallet *wallet = walletManager->findWalletByAddress([self.address UTF8String]);
            bool isValidate = wallet->validatePassword([password UTF8String]);
            if (isValidate) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.progressHUD.label.text = NSLocalizedString(@"sending_transaction", @"sending_transaction");
                    [self.progressHUD showAnimated:YES];
                });
                
                //unlock account
                wallet->unlock([password UTF8String]);
                
                //sign transaction
                std::string hex;
                if ([self.contactAddress isEmpty]) {
                    wallet->signTransaction([from UTF8String], [to UTF8String], value, weakSelf.gas, gasPrice, weakSelf.nonce, hex);
                } else {
                    wallet->signERC20TokenTransaction([from UTF8String], [to UTF8String], [weakSelf.contactAddress UTF8String], value, 18, weakSelf.gas, gasPrice, weakSelf.nonce, hex);
                }
                
                NSString *hexValue = [NSString stringWithCString:hex.c_str() encoding:NSUTF8StringEncoding];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                   
                    [[ETHWebService shareInstance] sendRawTransaction:hexValue success:^(NSString *hashHex){
                        
                        self.progressHUD.label.text = NSLocalizedString(@"send_transaction_success", @"send_transaction_success");
                        [self.progressHUD showAnimated:YES];
                        [self.progressHUD hideAnimated:YES afterDelay:1.25f];
                        
//                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
                        
                        //jump to result page
                        TransactionResultViewController *viewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"TransactionResultViewController"];
                        viewCtrl.from = [NSString stringWithFormat:@"0x%@",self.address];
                        viewCtrl.to = self.addressTextField.text;
                        viewCtrl.txHash = hashHex;
                        viewCtrl.value = [self.amountTextField.text doubleValue];
                        viewCtrl.coinName = self.coinName;
                        viewCtrl.gasUsed = (self.gas * gasPrice) / pow(10, 9);
                        [self presentViewController:viewCtrl animated:YES completion:nil];
                        
                    } failed:^{
                        
                        self.progressHUD.label.text = NSLocalizedString(@"send_transaction_failed", @"send_transaction_failed");
                        [self.progressHUD showAnimated:YES];
                        [self.progressHUD hideAnimated:YES afterDelay:1.25f];
                    }];
                });
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
               
                self.progressHUD.label.text = NSLocalizedString(@"validate_password_failed", @"validate_password_failed");
                [self.progressHUD showAnimated:YES];
                [self.progressHUD hideAnimated:YES afterDelay:1.25f];
                
            });
            
        });
        
    }]];
    [self presentViewController:alertCtrl animated:YES completion:nil];
    
}

- (IBAction)didEndOnExit:(id)sender {
    
    [self.addressTextField resignFirstResponder];
    [self.amountTextField resignFirstResponder];
    [self.remarkTextField resignFirstResponder];
}

- (IBAction)onScanQR:(id)sender {
    
    QRScanViewController *viewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"QRScanViewController"];
    viewCtrl.delegate = self;
    [self presentViewController:viewCtrl animated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
