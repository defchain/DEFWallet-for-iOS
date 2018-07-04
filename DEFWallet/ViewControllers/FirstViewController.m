//
//  FirstViewController.m
//  DEFWallet
//
//

#import "FirstViewController.h"
#import "UIColor+Category.h"

#define kNotificationNameCreateOrImportWalletSuccess @"kNotificationNameCreateOrImportWalletSuccess"

@interface FirstViewController ()

@property (weak, nonatomic) IBOutlet UIButton *createWalletButton;

@property (weak, nonatomic) IBOutlet UIButton *importWalletButton;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUIs];
    
    [self setUpNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


/**
 Setup UI
 */
- (void)initUIs {
    
    
    self.createWalletButton.layer.cornerRadius = 5;
    self.createWalletButton.layer.masksToBounds = YES;
    
    self.importWalletButton.layer.borderWidth = 1;
    self.importWalletButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.importWalletButton.layer.cornerRadius = 5;
    self.importWalletButton.layer.masksToBounds = YES;
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    [self setStatusBarBackgroundColor:[UIColor clearColor]];
}

/**
 set status bar color
 */
- (void)setStatusBarBackgroundColor:(UIColor *)color {
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}


/**
 Init Notification
 */
- (void)setUpNotification {
    
    //add notification,if create wallet finished,close this viewcontroller
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didCreateOrImportWalletSuccess)
                                                 name:kNotificationNameCreateOrImportWalletSuccess
                                               object:nil];
}

#pragma -
#pragma mark didCreateOrImportWalletSuccess


- (void)didCreateOrImportWalletSuccess {
    
    //close this view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
