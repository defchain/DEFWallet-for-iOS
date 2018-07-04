//
//  ImportWalletByMnemonicView.m
//  DEFWallet
//
//

#import "ImportWalletByMnemonicView.h"
#import "UITextView+Placeholder.h"
#import "UIColor+Category.h"
#import "NSString+Category.h"
#import "MBProgressHUD.h"

#import <vector>
#import <string>
#import <defwallet/def_wallet_manager.h>

@interface ImportWalletByMnemonicView()<UITextViewDelegate,UITextFieldDelegate>

@property(nonatomic, strong) MBProgressHUD *progressHUD;

@end

@implementation ImportWalletByMnemonicView

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self.mnemonicTextView setPlaceholder:NSLocalizedString(@"enter_mnemonic_tips", @"enter_mnemonic_tips")
                           placeholdColor:[UIColor colorWithRGBHex:0xBDBDBF]];
    
    self.mnemonicTextView.delegate = self;
    
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self];
    [self addSubview:self.progressHUD];
    
    self.mnemonicTextView.delegate = self;
    self.mnemonicTextView.returnKeyType = UIReturnKeyNext;
    self.pathTextField.returnKeyType = UIReturnKeyNext;
    self.passwordTextField.returnKeyType = UIReturnKeyNext;
    self.rePasswordTextField.returnKeyType = UIReturnKeyDone;
}
    
#pragma -
#pragma mark UITextViewDelegate
    
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){
        [self.pathTextField becomeFirstResponder];
        return NO;
    }
    
    return YES;
}
    
#pragma -
#pragma mark UITextFieldDelegate
    
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.pathTextField]) {
        [self.passwordTextField becomeFirstResponder];
    } else if ([textField isEqual:self.passwordTextField]) {
        [self.rePasswordTextField becomeFirstResponder];
    } else {
        return YES;
    }
    
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if([self.passwordTextField.text isNotEmpty]
       && [self.rePasswordTextField.text isNotEmpty]
       && [self.mnemonicTextView.text isNotEmpty]
       && [self.pathTextField.text isNotEmpty]
       && [self.passwordTextField.text isEqualToString:self.rePasswordTextField.text]) {
        
        self.submitButton.enabled = YES;
        [self.submitButton setBackgroundColor:[UIColor colorWithRGBHex:0xF7931A]];
        
    } else {
        
        self.submitButton.enabled = NO;
        [self.submitButton setBackgroundColor:[UIColor colorWithRGBHex:0xCCCCCC]];
    }
}

- (IBAction)submit:(id)sender {
    
    self.progressHUD.label.text = NSLocalizedString(@"importing_wallet", @"importing_wallet");
    [self.progressHUD showAnimated:YES];
    
    NSArray *array = [self.mnemonicTextView.text componentsSeparatedByString:@" "];
    NSString *walletName = [NSString stringWithFormat:@"hd-%@",NSLocalizedString(@"new_wallet", @"new_wallet")];
    NSString *path = self.pathTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *hint = @"";
    
    __weak ImportWalletByMnemonicView *weakSelf = self;
    
    dispatch_queue_t queue = dispatch_queue_create("io.defensor.importwalletbymnemonic", nil);
    dispatch_async(queue, ^{
        
        std::vector<std::string> mnemonics;
        for (int i = 0 ;i < array.count; i ++) {
            NSString *mnemonic = [array objectAtIndex:i];
            mnemonics.push_back([mnemonic UTF8String]);
        }
        
        libdefwallet::DEFWalletManager *walletManager = libdefwallet::DEFWalletManager::shareInstance();
        std::string addr = walletManager->importWalletWithMnemonic(mnemonics,[path UTF8String], [walletName UTF8String], [password UTF8String], [hint UTF8String]);
        
        if (addr != "") {
            
            //导入成功
            dispatch_async(dispatch_get_main_queue(), ^{
               
                
                if (weakSelf.delegate) {
                    [weakSelf.delegate didFinishedImportWallet];
                }
                
                weakSelf.progressHUD.label.text = NSLocalizedString(@"import_wallet_success", @"import_wallet_success");
                [weakSelf.progressHUD hideAnimated:YES afterDelay:1.25f];
            });
            return;
        }
        
        weakSelf.progressHUD.label.text = NSLocalizedString(@"import_wallet_failed", @"import_wallet_failed");
        [weakSelf.progressHUD hideAnimated:YES afterDelay:1.25f];
        
    });
    
}

- (IBAction)textValueChanged:(id)sender {
    
    if([self.passwordTextField.text isNotEmpty]
            && [self.rePasswordTextField.text isNotEmpty]
            && [self.mnemonicTextView.text isNotEmpty]
            && [self.pathTextField.text isNotEmpty]
            && [self.passwordTextField.text isEqualToString:self.rePasswordTextField.text]) {
        
        self.submitButton.enabled = YES;
        [self.submitButton setBackgroundColor:[UIColor colorWithRGBHex:0xF7931A]];
        
    } else {
        
        self.submitButton.enabled = NO;
        [self.submitButton setBackgroundColor:[UIColor colorWithRGBHex:0xCCCCCC]];
        
    }
}

- (IBAction)changePasswordDisplay:(id)sender {
    if (self.passwordEyeButton.tag == 0) {
        self.passwordEyeButton.tag = 1;
        self.repasswordEyeButton.tag = 1;
        [self.passwordEyeButton setImage:[UIImage imageNamed:@"icon_eye_gray"] forState:UIControlStateNormal];
        [self.repasswordEyeButton setImage:[UIImage imageNamed:@"icon_eye_gray"] forState:UIControlStateNormal];
        self.passwordTextField.secureTextEntry = NO;
        self.rePasswordTextField.secureTextEntry = NO;
        
    }else {
        self.passwordEyeButton.tag = 0;
        self.repasswordEyeButton.tag = 0;
        [self.passwordEyeButton setImage:[UIImage imageNamed:@"icon_eye_gray_close"] forState:UIControlStateNormal];
        [self.repasswordEyeButton setImage:[UIImage imageNamed:@"icon_eye_gray_close"] forState:UIControlStateNormal];
        self.passwordTextField.secureTextEntry = YES;
        self.rePasswordTextField.secureTextEntry = YES;
    }
}

- (IBAction)didEndOnExit:(id)sender {
    [self.pathTextField resignFirstResponder];
    [self.pathTextField resignFirstResponder];
    [self.rePasswordTextField resignFirstResponder];
}

@end
