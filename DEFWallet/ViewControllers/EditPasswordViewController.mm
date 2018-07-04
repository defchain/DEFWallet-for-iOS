//
//  EditPasswordViewController.m
//  DEFWallet
//
//

#import "EditPasswordViewController.h"
#import "NSString+Category.h"
#import "UIColor+Category.h"
#import "MBProgressHUD.h"

#import <defwallet/def_wallet_manager.h>
#import <defwallet/def_wallet.h>

@interface EditPasswordViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *nPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *rPasswordField;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;

@property (nonatomic, strong) MBProgressHUD *progressHUD;

@end

@implementation EditPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.headerView setBackgroundColor:[UIColor colorWithRGBHex:0x263D55]];
    self.oldPasswordField.returnKeyType = UIReturnKeyNext;
    self.nPasswordField.returnKeyType = UIReturnKeyNext;
    
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.progressHUD];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.oldPasswordField]) {
        [self.nPasswordField becomeFirstResponder];
    }else if([textField isEqual:self.nPasswordField]) {
        [self.rPasswordField becomeFirstResponder];
    }else {
        return YES;
    }
    return NO;
}

#pragma -
#pragma mark IBAction

- (IBAction)DidEndOnExit:(id)sender {
    
    UITextField *field = (UITextField *)sender;
    [field resignFirstResponder];
}

- (IBAction)textfieldEditingChanged:(id)sender {
    
    if ([self.oldPasswordField.text isNotEmpty]
            && [self.nPasswordField.text isNotEmpty]
            && [self.rPasswordField.text isNotEmpty]
            && [self.oldPasswordField.text length] >= 6
            && [self.nPasswordField.text length] >=6
            && [self.rPasswordField.text length] >= 6
            && [self.nPasswordField.text isEqualToString:self.rPasswordField.text]) {
        
        self.finishButton.enabled = YES;
        [self.finishButton setBackgroundColor:[UIColor colorWithRGBHex:0xF7931A]];
        
    } else {
        
        self.finishButton.enabled = NO;
        [self.finishButton setBackgroundColor:[UIColor colorWithRGBHex:0xCCCCCC]];
    }
    
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)finish:(id)sender {
    
    self.progressHUD.label.text = NSLocalizedString(@"validating_password", @"validating_password");
    [self.progressHUD showAnimated:YES];
    
    NSString *oldPassword = self.oldPasswordField.text;
    NSString *nPassword = self.nPasswordField.text;
    
    __weak EditPasswordViewController *weakSelf = self;
    dispatch_queue_t queue =  dispatch_queue_create("io.defensor.editpassword", nil);
    dispatch_async(queue, ^{
        
        libdefwallet::DEFWalletManager *walletManager = libdefwallet::DEFWalletManager::shareInstance();
        libdefwallet::DEFWallet *wallet = walletManager->findWalletByAddress([weakSelf.address UTF8String]);
        BOOL isSuccess = wallet->modifyWalletPassword([oldPassword UTF8String], [nPassword UTF8String]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            if(isSuccess) {
                
                weakSelf.progressHUD.label.text = NSLocalizedString(@"edit_password_success", @"edit_password_success");
                [weakSelf.progressHUD showAnimated:YES];
                [weakSelf.progressHUD hideAnimated:YES afterDelay:1.25f];
                
            } else {
                
                weakSelf.progressHUD.label.text = NSLocalizedString(@"edit_password_failed", @"edit_password_failed");
                [weakSelf.progressHUD showAnimated:YES];
                [weakSelf.progressHUD hideAnimated:YES afterDelay:1.25f];
            }
            
        });
    });

}

@end
