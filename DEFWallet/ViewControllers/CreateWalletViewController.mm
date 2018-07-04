//
//  CreateWalletViewController.m
//  DEFWallet
//
//

#import "CreateWalletViewController.h"
#import "BackupWalletSetpOneViewController.h"
#import "MBProgressHUD.h"
#import "NSString+Category.h"
#import "UIColor+Category.h"

#import <defwallet/def_wallet_manager.h>

@interface CreateWalletViewController ()<UITextFieldDelegate>

//buttons
@property (weak, nonatomic) IBOutlet UIButton *createWalletButton;
@property (weak, nonatomic) IBOutlet UIButton *passwordEyeButton;
@property (weak, nonatomic) IBOutlet UIButton *repasswordEyeButton;

//textfields
@property (weak, nonatomic) IBOutlet UITextField *walletNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *rePasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *hintTextField;

//loading view
@property (nonatomic, strong) MBProgressHUD *progressHUD;

@end

@implementation CreateWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //SetupUI
    [self setupUIs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 setup UI
 */
- (void)setupUIs {
    
    //set title
    self.title = NSLocalizedString(@"create_wallet", @"create_wallet");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //wallet textfield first responder
    [self.walletNameTextField becomeFirstResponder];
    
    //set NavigationBar color
    UINavigationBar *navBar = [UINavigationBar appearance];
    navBar.barTintColor = [UIColor colorWithRGBHex:0x263D55];
    navBar.translucent = NO;
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    //add loading view
    self.progressHUD = [[MBProgressHUD alloc] init];
    [self.navigationController.view addSubview:self.progressHUD];
    
    //set keyboard return key type
    self.walletNameTextField.returnKeyType = UIReturnKeyNext;
    self.passwordTextField.returnKeyType = UIReturnKeyNext;
    self.rePasswordTextField.returnKeyType = UIReturnKeyNext;
    self.hintTextField.returnKeyType = UIReturnKeyDone;
}


/**
 create wallet button click

 @param sender  Event sender
 */
- (IBAction)onCreateWalletBtnClick:(id)sender {
    
    self.progressHUD.label.text = NSLocalizedString(@"creating_wallet", @"creating_wallet");
    [self.progressHUD showAnimated:YES];
    
    __weak CreateWalletViewController *weakSelf = self;
    NSString *walletName = [self.walletNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *hint = [self.hintTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    dispatch_queue_t queue = dispatch_queue_create("io.defensor.createwallet", nil);
    dispatch_async(queue, ^{
        
        //create wallet
        libdefwallet::DEFWalletManager *walletManager = libdefwallet::DEFWalletManager::shareInstance();
        std::string address = walletManager->createNewWallet([walletName UTF8String], [password UTF8String],[hint UTF8String]);
        NSString *addressStr = [NSString stringWithCString:address.c_str() encoding:NSUTF8StringEncoding];
        if ([addressStr isEmpty]) {
            
            //notice create wallet failed
            dispatch_async(dispatch_get_main_queue(), ^{
                
                weakSelf.progressHUD.label.text = NSLocalizedString(@"create_wallet_failed", @"create_wallet_failed");
                [weakSelf.progressHUD showAnimated:YES];
                [weakSelf.progressHUD hideAnimated:YES afterDelay:1.25];
                
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //notice create wallet success
            weakSelf.progressHUD.label.text = NSLocalizedString(@"create_wallet_success", @"create_wallet_success");
            [weakSelf.progressHUD showAnimated:YES];
            [weakSelf.progressHUD hideAnimated:YES afterDelay:1.25];
            
            //Jump to next step
            BackupWalletSetpOneViewController *viewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"BackupWalletSetpOneViewController"];
            viewCtrl.address = addressStr;
            [self.navigationController pushViewController:viewCtrl animated:YES];
        });
        
    });
    
}

- (IBAction)textFieldValueChanged:(id)sender {
    
    if ([self.walletNameTextField.text isNotEmpty]
            && [self.passwordTextField.text isNotEmpty]
            && [self.rePasswordTextField.text isNotEmpty]
            && [self.passwordTextField.text length] >= 6
            && [self.rePasswordTextField.text length] >= 6
            && [self.passwordTextField.text isEqualToString:self.rePasswordTextField.text]
        ) {
        self.createWalletButton.enabled = YES;
        [self.createWalletButton setBackgroundColor:[UIColor colorWithRGBHex:0xF7931A]];
    } else {
        self.createWalletButton.enabled = NO;
        [self.createWalletButton setBackgroundColor:[UIColor colorWithRGBHex:0xCCCCCC]];
    }
}


/**
 Eye Buton click Event
 */
- (IBAction)passwordEyeButtonClick:(id)sender {
    
    if(self.passwordEyeButton.tag == 0) {
        
        self.passwordEyeButton.tag = 1;
        self.repasswordEyeButton.tag = 1;
        [self.passwordEyeButton setImage:[UIImage imageNamed:@"icon_eye_gray"] forState:UIControlStateNormal];
        [self.repasswordEyeButton setImage:[UIImage imageNamed:@"icon_eye_gray"] forState:UIControlStateNormal];
        self.passwordTextField.secureTextEntry = NO;
        self.rePasswordTextField.secureTextEntry = NO;
        
    } else {
        
        self.passwordEyeButton.tag = 0;
        self.repasswordEyeButton.tag = 0;
        [self.passwordEyeButton setImage:[UIImage imageNamed:@"icon_eye_gray_close"] forState:UIControlStateNormal];
        [self.repasswordEyeButton setImage:[UIImage imageNamed:@"icon_eye_gray_close"] forState:UIControlStateNormal];
        self.passwordTextField.secureTextEntry = YES;
        self.rePasswordTextField.secureTextEntry = YES;
        
    }
}

/**
 when textfiled input "return",resign first responder
 */
- (IBAction)onEndOnExit:(id)sender {
    
    [self.walletNameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.rePasswordTextField resignFirstResponder];
    [self.hintTextField resignFirstResponder];
}


/**
 Close this view controller
 */
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.walletNameTextField]) {
        [self.passwordTextField becomeFirstResponder];
    } else if ([textField isEqual:self.passwordTextField]) {
        [self.rePasswordTextField becomeFirstResponder];
    } else if([textField isEqual:self.rePasswordTextField]) {
        [self.hintTextField becomeFirstResponder];
    } else {
        return YES;
    }
    
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [super textFieldDidBeginEditing:textField];
    
    NSLog(@"textFieldDidBeginEditing");
}


@end
