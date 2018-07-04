//
//  ImportWalletViewController.m
//  DEFWallet
//
//

#import "ImportWalletViewController.h"
#import "ImportWalletByMnemonicView.h"
#import "ImportWalletByKeystoreView.h"
#import "ImportWalletByPrivateKeyView.h"
#import "UIColor+Category.h"

#define kSwitchMnemonicViewTag 10
#define kSwitchKeystoreViewTag 11
#define kSwitchPrivateKeyViewTag 12

#define kSwitchLabelTag 101
#define kSwitchMarkTag 102

#define kSwitchSelectColor 0xF7931A
#define kSwitchUnSelectColor 0x5C7795

#define kNotificationNameCreateOrImportWalletSuccess @"kNotificationNameCreateOrImportWalletSuccess"

@interface ImportWalletViewController ()<UIGestureRecognizerDelegate,
                                        ImportWalletByMnemonicViewDelegate,
                                        ImportWalletByKeystoreViewDelegate,
                                        ImportWalletByPrivateKeyViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *switchView;
@property (weak, nonatomic) IBOutlet UIView *switchMnenomicView;
@property (weak, nonatomic) IBOutlet UIView *switchKeystoreView;
@property (weak, nonatomic) IBOutlet UIView *switchPrivateKeyView;

@property (strong, nonatomic) UITapGestureRecognizer *importMnemonicViewTapRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *importKeyStoreViewTapRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *importPrivateKeyViewTapRecognizer;

@property(nonatomic, strong) ImportWalletByMnemonicView *importMnemonicView;
@property(nonatomic, strong) ImportWalletByKeystoreView *importKeyStoreView;
@property(nonatomic, strong) ImportWalletByPrivateKeyView *importPrivateKeyView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, assign) BOOL isFirstAppear;

@end

@implementation ImportWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init UI
    [self setupUIs];
}
    
- (void)viewDidAppear:(BOOL)animated {
    
    if(!self.isFirstAppear) {
        
        [self loadImportMnemonicView];
        [self loadImportKeystoreView];
        [self loadPrivateKeyView];
        
        self.isFirstAppear = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)setupUIs {
    
    self.title = NSLocalizedString(@"import_wallet_title", @"import_wallet_title");
    
    
    UINavigationBar *navBar = [UINavigationBar appearance];
    navBar.barTintColor = [UIColor colorWithRGBHex:0x263D55];
    navBar.translucent = NO;
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    //初始化switchview
    [self setupSwitchView];
    
    
}

#pragma mark setup views


- (void)setupSwitchView {
    
    self.importMnemonicViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSwitchViewClick:)];
    self.importMnemonicViewTapRecognizer.delegate = self;
    [self.switchMnenomicView addGestureRecognizer:self.importMnemonicViewTapRecognizer];
    
    self.importKeyStoreViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSwitchViewClick:)];
    self.importKeyStoreViewTapRecognizer.delegate = self;
    [self.switchKeystoreView addGestureRecognizer:self.importKeyStoreViewTapRecognizer];
    
    self.importPrivateKeyViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSwitchViewClick:)];
    self.importPrivateKeyViewTapRecognizer.delegate = self;
    [self.switchPrivateKeyView addGestureRecognizer:self.importPrivateKeyViewTapRecognizer];
}

/**
 导入助记词视图
 */
- (void)loadImportMnemonicView {
    
    NSArray *mnemonicNibContents = [[NSBundle mainBundle] loadNibNamed:@"import_wallet_mnemonic" owner:nil options:nil];
    self.importMnemonicView = [mnemonicNibContents lastObject];
    self.importMnemonicView.delegate = self;
    
    CGRect f = self.importMnemonicView.frame;
    f.origin.x = 0;
    f.origin.y = 0;
    f.size.width = self.scrollView.frame.size.width;
    f.size.height = self.scrollView.frame.size.height;
    [self.importMnemonicView setFrame:f];
    [self.scrollView addSubview:self.importMnemonicView];
    
    CGSize size = f.size;
    [self.scrollView setContentSize:size];
}


/**
 Import keystore view
 */
- (void)loadImportKeystoreView {
    
    NSArray *keystoreNibContents = [[NSBundle mainBundle] loadNibNamed:@"import_wallet_keystore" owner:nil options:nil];
    self.importKeyStoreView = [keystoreNibContents lastObject];
    self.importKeyStoreView.delegate = self;
    
    CGRect f = self.importKeyStoreView.frame;
    f.origin.x = 0;
    f.origin.y = 0;
    f.size.width = self.scrollView.frame.size.width;
    f.size.height = self.scrollView.frame.size.height;
    [self.importKeyStoreView setFrame:f];
    self.importKeyStoreView.hidden = YES;
    [self.scrollView addSubview:self.importKeyStoreView];
}


/**
 import privatekey view
 */
- (void)loadPrivateKeyView {
    
    NSArray *privateKeyNibContents = [[NSBundle mainBundle] loadNibNamed:@"import_wallet_privatekey" owner:nil options:nil];
    self.importPrivateKeyView = [privateKeyNibContents lastObject];
    self.importPrivateKeyView.delegate = self;
    
    CGRect f = self.importPrivateKeyView.frame;
    f.origin.x = 0;
    f.origin.y = 0;
    f.size.width = self.scrollView.frame.size.width;
    f.size.height = self.scrollView.frame.size.height;
    [self.importPrivateKeyView setFrame:f];
    self.importPrivateKeyView.hidden = YES;
    [self.scrollView addSubview:self.importPrivateKeyView];
}


/**
 import wallet success
 */
- (void)didFinishedImportWallet {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameCreateOrImportWalletSuccess object:nil];
    }];
}

#pragma mark events


- (IBAction)onSwitchViewClick:(UITapGestureRecognizer *)gesture {
    
    NSArray *switchSubViews = [self.switchView subviews];
    for (UIView *view in switchSubViews) {
        
        UILabel *label = [view viewWithTag:kSwitchLabelTag];
        [label setTextColor:[UIColor colorWithRGBHex:kSwitchUnSelectColor]];
        
        UIView *mark = [view viewWithTag:kSwitchMarkTag];
        mark.hidden = YES;
    }
    
    UIView *view = gesture.view;
    UILabel *label = [view viewWithTag:kSwitchLabelTag];
    [label setTextColor:[UIColor colorWithRGBHex:kSwitchSelectColor]];
    UIView *mark = [view viewWithTag:kSwitchMarkTag];
    mark.hidden = NO;
    
    switch (gesture.view.tag) {
        case kSwitchMnemonicViewTag:{
            
            self.importMnemonicView.hidden = NO;
            self.importKeyStoreView.hidden = YES;
            self.importPrivateKeyView.hidden = YES;
            
            break;
        }
        case kSwitchKeystoreViewTag:{

            self.importMnemonicView.hidden = YES;
            self.importKeyStoreView.hidden = NO;
            self.importPrivateKeyView.hidden = YES;
            
            break;
        }
        case kSwitchPrivateKeyViewTag:{

            self.importMnemonicView.hidden = YES;
            self.importKeyStoreView.hidden = YES;
            self.importPrivateKeyView.hidden = NO;
            break;
        }
        default:
            break;
    }
}

/**
 Cancel Event
 */
- (IBAction)cancel:(id)sender {
    
    //close this view Controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
