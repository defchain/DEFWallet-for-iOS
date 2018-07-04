//
//  ImportWalletByKeystoreView.m
//  DEFWallet
//
//

#import "ImportWalletByKeystoreView.h"
#import "UIColor+Category.h"
#import "NSString+Category.h"
#import "UITextView+Placeholder.h"
#import "MBProgressHUD.h"

#import <defwallet/def_wallet_manager.h>


@interface ImportWalletByKeystoreView()<UITextViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) MBProgressHUD *progressHUD;

@end


@implementation ImportWalletByKeystoreView

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self.keystoreTextView setPlaceholder:NSLocalizedString(@"enter_keystore_tips", @"enter_keystore_tips")
                           placeholdColor:[UIColor colorWithRGBHex:0xBDBDBF]];
    self.keystoreTextView.delegate = self;
    self.keystoreTextView.returnKeyType = UIReturnKeyNext;
    self.passwordTextField.returnKeyType = UIReturnKeyDone;
    
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self];
    [self addSubview:self.progressHUD];
    
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

- (void)textChanged:(id)sender {
    
    if ([self.keystoreTextView.text isNotEmpty]
        && [self.passwordTextField.text isNotEmpty]) {
        
        self.importButton.enabled = YES;
        [self.importButton setBackgroundColor:[UIColor colorWithRGBHex:0xF7931A]];
        
    } else {
        
        self.importButton.enabled = NO;
        [self.importButton setBackgroundColor:[UIColor colorWithRGBHex:0xCCCCCC]];
    }
}


- (void)textViewDidChange:(UITextView *)textView {
    
    if ([self.keystoreTextView.text isNotEmpty]
            && [self.passwordTextField.text isNotEmpty]
            && self.passwordTextField.text.length >= 6) {
        
        self.importButton.enabled = YES;
        [self.importButton setBackgroundColor:[UIColor colorWithRGBHex:0xF7931A]];
        
    } else {
        
        self.importButton.enabled = NO;
        [self.importButton setBackgroundColor:[UIColor colorWithRGBHex:0xCCCCCC]];
    }
}

- (IBAction)passwordEyeChangeDisplay:(id)sender {
    
    if (self.passwordEyeButton.tag == 0) {
        self.passwordEyeButton.tag = 1;
        [self.passwordEyeButton setImage:[UIImage imageNamed:@"icon_eye_gray"] forState:UIControlStateNormal];
        self.passwordTextField.secureTextEntry = NO;
        
    }else {
        self.passwordEyeButton.tag = 0;
        [self.passwordEyeButton setImage:[UIImage imageNamed:@"icon_eye_gray_close"] forState:UIControlStateNormal];
        self.passwordTextField.secureTextEntry = YES;
    }
}

- (IBAction)submit:(id)sender {
    
    self.progressHUD.label.text = NSLocalizedString(@"importing_wallet", @"importing_wallet");
    [self.progressHUD showAnimated:YES];
    
    __weak ImportWalletByKeystoreView *weakSelf = self;
    NSString *keystore = [self.keystoreTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = self.passwordTextField.text;
    NSString *walletName = [NSString stringWithFormat:@"ks-%@",NSLocalizedString(@"new_wallet", @"new_wallet")];
    
    dispatch_queue_t queue = dispatch_queue_create("io.defensor.importwalletbykeystore", nil);
    dispatch_async(queue, ^{
        
        libdefwallet::DEFWalletManager *walletManager = libdefwallet::DEFWalletManager::shareInstance();
        std::string address = walletManager->importWalletWithKeystore([keystore UTF8String], [walletName UTF8String], [password UTF8String], "");
        if (address != "") {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                weakSelf.progressHUD.label.text = NSLocalizedString(@"import_wallet_success", @"import_wallet_success");
                [weakSelf.progressHUD hideAnimated:YES afterDelay:1.25f];
                
                if (self.delegate) {
                    [self.delegate didFinishedImportWallet];
                }
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            self.progressHUD.label.text = NSLocalizedString(@"import_wallet_failed", @"import_wallet_failed");
            [self.progressHUD hideAnimated:YES afterDelay:1.25];
            
        });
    });
    
    
}

//exit
- (IBAction)didEndOnExit:(id)sender {
    
    [self.passwordTextField resignFirstResponder];
}

@end
