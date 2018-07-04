//
//  BackupMnemonicViewController.m
//  DEFWallet
//
//

#import "BackupMnemonicViewController.h"
#import "ValidateMnemonicViewController.h"

@interface BackupMnemonicViewController ()

//mnemonic word textview
@property (weak, nonatomic) IBOutlet UITextView *mnemonicTextView;

@end

@implementation BackupMnemonicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set mnemonic textview
    [self.mnemonicTextView setText:self.mnemonic];
    
    //set title
    self.title = NSLocalizedString(@"backup_mnemonic_title", @"backup_mnemonic_title");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    
    //show notice
    [self showNoticeView];
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

- (void)showNoticeView {
    
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"backup_mnemonic_notice_title", @"backup_mnemonic_notice_title")
                                                                       message:NSLocalizedString(@"backup_mnemonic_notice_message", @"backup_mnemonic_notice_message")
                                                                preferredStyle:UIAlertControllerStyleAlert];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"backup_mnemonic_notice_ok", @"backup_mnemonic_notice_ok") style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UIViewController *destination = segue.destinationViewController;
    if([destination isKindOfClass:[ValidateMnemonicViewController class]]) {
        ValidateMnemonicViewController *validateMViewCtrl = (ValidateMnemonicViewController *)destination;
        validateMViewCtrl.address = self.address;
        validateMViewCtrl.mnemonic = self.mnemonic;
    }
}

@end
