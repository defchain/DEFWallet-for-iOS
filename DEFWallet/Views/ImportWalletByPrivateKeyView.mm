//
//  ImportWalletByPrivateKeyView.m
//  DEFWallet
//
//

#import "ImportWalletByPrivateKeyView.h"
#import "UITextView+Placeholder.h"
#import "UIColor+Category.h"
#import "NSString+Category.h"
#import "MBProgressHUD.h"

#import <defwallet/def_wallet_manager.h>

@interface ImportWalletByPrivateKeyView()<UITextFieldDelegate,UITextViewDelegate>

@property(nonatomic, strong) MBProgressHUD *progressHUD;

@end

@implementation ImportWalletByPrivateKeyView


- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self.privateKeyTextView setPlaceholder:NSLocalizedString(@"enter_privatekey_tips", @"enter_privatekey_tips")
                             placeholdColor:[UIColor colorWithRGBHex:0xBDBDBF]];
    
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self];
    [self addSubview:self.progressHUD];
    
    self.privateKeyTextView.returnKeyType = UIReturnKeyNext;
    self.passwordTextField.returnKeyType = UIReturnKeyNext;
    self.rePasswordTextField.returnKeyType = UIReturnKeyDone;
    
}
    
#pragma -
#pragma mark UITextViewDelegate
    
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){
        [self.passwordTextField becomeFirstResponder];
        return NO;
    }
    
    return YES;
}
    
#pragma -
#pragma mark UITextFieldDelegate
    
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.passwordTextField]) {
        [self.rePasswordTextField becomeFirstResponder];
    } else {
        return YES;
    }
    
    return NO;
}

- (IBAction)textValueChanged:(id)sender {
    
    if ([self.privateKeyTextView.text isNotEmpty]
            && [self.passwordTextField.text isNotEmpty]
            && [self.rePasswordTextField.text isNotEmpty]
            && [self.passwordTextField.text isEqualToString:self.rePasswordTextField.text]) {
        
        self.submitButton.enabled = YES;
        [self.submitButton setBackgroundColor:[UIColor colorWithRGBHex:0xF7931A]];
        
    } else {
        
        self.submitButton.enabled = NO;
        [self.submitButton setBackgroundColor:[UIColor colorWithRGBHex:0xCCCCCC]];
    }
}

- (IBAction)passwordEyeClick:(id)sender {
    
    if (self.passwordEyeButton.tag == 0) {
        self.passwordEyeButton.tag = 1;
        [self.passwordEyeButton setImage:[UIImage imageNamed:@"icon_eye_gray"] forState:UIControlStateNormal];
        self.passwordTextField.secureTextEntry = NO;
        self.repasswordEyeButton.tag = 1;
        [self.repasswordEyeButton setImage:[UIImage imageNamed:@"icon_eye_gray"] forState:UIControlStateNormal];
        self.rePasswordTextField.secureTextEntry = NO;
        
    }else {
        self.passwordEyeButton.tag = 0;
        [self.passwordEyeButton setImage:[UIImage imageNamed:@"icon_eye_gray_close"] forState:UIControlStateNormal];
        self.passwordTextField.secureTextEntry = YES;
        self.repasswordEyeButton.tag = 0;
        [self.repasswordEyeButton setImage:[UIImage imageNamed:@"icon_eye_gray_close"] forState:UIControlStateNormal];
        self.rePasswordTextField.secureTextEntry = YES;
    }
    
}

- (IBAction)submit:(id)sender {
    
    self.progressHUD.label.text = NSLocalizedString(@"importing_wallet", @"importing_wallet");
    [self.progressHUD showAnimated:YES];
    
    __weak ImportWalletByPrivateKeyView *weakSelf = self;
    NSString *walletName = [NSString stringWithFormat:@"pk-%@",NSLocalizedString(@"new_wallet", @"new_wallet")];
    NSString *privateKey = [self.privateKeyTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = self.passwordTextField.text;
    
    dispatch_queue_t queue = dispatch_queue_create("io.defensor.importwalletbypk", nil);
    dispatch_async(queue, ^{
        
        libdefwallet::DEFWalletManager *walletManager = libdefwallet::DEFWalletManager::shareInstance();
        std::string address = walletManager->importWalletWithPrivateKey([privateKey UTF8String], [walletName UTF8String], [password UTF8String], "");
        if (address != "") {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                weakSelf.progressHUD.label.text = NSLocalizedString(@"import_wallet_success", @"import_wallet_success");
                [weakSelf.progressHUD hideAnimated:YES afterDelay:1.25f];
                
                if (weakSelf.delegate) {
                    [weakSelf.delegate didFinishedImportWallet];
                }
        
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            weakSelf.progressHUD.label.text = NSLocalizedString(@"import_wallet_failed", @"import_wallet_failed");
            [weakSelf.progressHUD hideAnimated:YES afterDelay:1.25f];
        });
        
    });
}

- (IBAction)didEndOnExit:(id)sender {
    [self.passwordTextField resignFirstResponder];
    [self.rePasswordTextField resignFirstResponder];
}

@end
