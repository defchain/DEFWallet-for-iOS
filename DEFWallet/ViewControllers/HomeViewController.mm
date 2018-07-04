//
//  HomeViewController.m
//  DEFWallet
//
//

#import "HomeViewController.h"
#import "FirstViewController.h"
#import "NSString+Category.h"
#import "UIColor+Category.h"
#import "ETHWebService.h"
#import "OSSSyncMutableDictionary.h"
#import "AssetService.h"
#import "WalletAssetCell.h"
#import "WalletAssetsViewController.h"
#import "QRScanViewController.h"
#import "ChangeWalletView.h"

#import <vector>
#import <string>
#import <defwallet/def_wallet_manager.h>
#import <defwallet/def_wallet.h>

//#define
#define kNotificationNameCreateOrImportWalletSuccess @"kNotificationNameCreateOrImportWalletSuccess"

@interface HomeViewController ()<ChangeWalletViewDelegate>

@property (nonatomic, assign) BOOL isFirstLoaded;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *walletNameView;

@property (nonatomic, strong) UITapGestureRecognizer *walletNameTapGesture;

@property (nonatomic, strong) ChangeWalletView *changeWalletView;

@property (weak, nonatomic) IBOutlet UILabel *walletNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalAssetsLabel;
@property (weak, nonatomic) IBOutlet UILabel *walletAddressLabel;

@property (nonatomic, strong) NSString *currentWalletName;
@property (nonatomic, strong) NSString *currentWalletAddress;

@property (nonatomic, strong) NSDictionary *walletAssets;

@property (nonatomic, strong) OSSSyncMutableDictionary *walletAmoutProperty;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self initHeaderView];
    
    [self setUpNotification];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    if(!self.isFirstLoaded) {
        
        [self loadWalletData];
        [self loadWalletAssets];
        
        //init sidebar
        [self initSideBar];
        
        self.isFirstLoaded = YES;
    }
    
    [self setStatusBarBackgroundColor:[UIColor colorWithRGBHex:0x263D55]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void) initHeaderView {
    
    [self setStatusBarBackgroundColor:[UIColor colorWithRGBHex:0x263D55]];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [self.headerView setBackgroundColor:[UIColor colorWithRGBHex:0x263D55]];
}


- (void)setStatusBarBackgroundColor:(UIColor *)color {
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

- (void)setUpNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didCreateOrImportWalletSuccess)
                                                 name:kNotificationNameCreateOrImportWalletSuccess
                                               object:nil];
}


- (void)didCreateOrImportWalletSuccess {
    
    [self loadWalletData];
    [self loadWalletAssets];
}


/**
 Init left side bar
 */
- (void)initSideBar {
    
    NSArray *siteBarContents = [[NSBundle mainBundle] loadNibNamed:@"change_wallet_view" owner:nil options:nil];
    self.changeWalletView = [siteBarContents lastObject];
    CGRect f = self.tabBarController.view.frame;
    [self.changeWalletView setFrame:f];
    [self.tabBarController.view addSubview:self.changeWalletView];
    self.changeWalletView.hidden = YES;
    self.changeWalletView.delegate = self;
    
    self.walletNameTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onWalletNameTap:)];
    [self.walletNameView addGestureRecognizer:self.walletNameTapGesture];
}

- (void)onWalletNameTap:(UITapGestureRecognizer *)gesture {
    self.changeWalletView.hidden = NO;
}


- (void)loadWalletData {
    
    libdefwallet::DEFWalletManager *walletManager = libdefwallet::DEFWalletManager::shareInstance();
    std::vector<libdefwallet::DEFWallet> walletList = walletManager->listAllWallet();
    if(walletList.size() == 0) {
        
        //if not exist wallet,jump to create
        FirstViewController *viewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstViewController"];
        [self presentViewController:viewCtrl animated:YES completion:nil];
        return;
    }
    
    //load default wallet data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *defaultWalletAddress = [defaults valueForKey:@"defaultWalletAddress"];
    NSString *defaultWalletName = [defaults valueForKey:@"defaultWalletName"];
    
    if (defaultWalletName == nil) {
        
        libdefwallet::DEFWallet defaultWallet = walletList[walletList.size() - 1];
        defaultWalletAddress = [NSString stringWithCString:defaultWallet.getAddress().c_str() encoding:NSUTF8StringEncoding];
        defaultWalletName = [NSString stringWithCString:defaultWallet.getWalletName().c_str() encoding:NSUTF8StringEncoding];
        [defaults setValue:defaultWalletAddress forKey:@"defaultWalletAddress"];
        [defaults setValue:defaultWalletName forKey:@"defaultWalletName"];
    }
    
    self.currentWalletName = defaultWalletName;
    self.currentWalletAddress = defaultWalletAddress;
    
    self.walletNameLabel.text = self.currentWalletName;
    self.walletAddressLabel.text = [NSString stringWithFormat:@"%@%@",@"0x",self.currentWalletAddress];
}


- (void)loadWalletAssets {
    
    if(self.currentWalletAddress == nil)
        return;
    
    self.walletAssets = [[AssetService shareInstance] getWalletAssets:self.currentWalletAddress];
    [self.tableView reloadData];
    
    if(self.walletAmoutProperty == nil) {
        self.walletAmoutProperty = [[OSSSyncMutableDictionary alloc] init];
    }
    
    for (NSString *coinName in [self.walletAssets allKeys]) {
        
        if ([coinName isEqualToString:@"eth"]) {
            
            [[ETHWebService shareInstance] getETHBalance:self.currentWalletAddress
                                                 success:^(double balance) {
                
                [self.walletAmoutProperty setObject:[NSNumber numberWithDouble:balance] forKey:coinName];
                [self.tableView reloadData];
                                                     
            } failed:^{
                
                NSLog(@"load eth balance failed");
            }];
        } else {
            
            NSString *contactAddress = self.walletAssets[coinName];
            [[ETHWebService shareInstance] getERC20TokenBalance:self.currentWalletAddress
                                                 contactAddress:contactAddress
                                                        success:^(double balance) {
                
                [self.walletAmoutProperty setObject:[NSNumber numberWithDouble:balance] forKey:coinName];
                [self.tableView reloadData];
                                                            
            } failed:^{
                
                NSLog(@"load erc20 balance failed");
            }];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.walletAssets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WalletAssetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"WalletAssetCell" forIndexPath:indexPath];
    
    NSString *key = [[self.walletAssets allKeys] objectAtIndex:indexPath.row];
    if ([key isEqualToString:@"eth"]) {
        [cell.logoImageView setImage:[UIImage imageNamed:@"icon_eth"]];
        [cell.nameLabel setText:@"ETH"];
        
        NSNumber *amoutNum = [self.walletAmoutProperty objectForKey:@"eth"];
        double balance = [amoutNum doubleValue];
        cell.amountLabel.text = [NSString stringWithFormat:@"%lf",balance];
        
        [[ETHWebService shareInstance] getCurrentETHRMBPrice:^(double rmbPrice) {
            cell.priceLabel.text = [NSString stringWithFormat:@"≈¥%lf",rmbPrice * balance];
            
            self.totalAssetsLabel.text = [NSString stringWithFormat:@"≈¥%lf",rmbPrice * balance];
        } failed:^{
            NSLog(@"load eth price failed");
        }];
        
    } else if([key isEqualToString:@"def"]) {
        [cell.logoImageView setImage:[UIImage imageNamed:@"defensor_28"]];
        [cell.nameLabel setText:@"DEF"];
        
        NSNumber *amoutNum = [self.walletAmoutProperty objectForKey:@"def"];
        double balance = [amoutNum doubleValue];
        cell.amountLabel.text = [NSString stringWithFormat:@"%lf",balance];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *coinName = [[self.walletAssets allKeys] objectAtIndex:indexPath.row];
    NSString *contactAddress = [self.walletAssets valueForKey:coinName];
    
    WalletAssetsViewController *viewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"WalletAssetsViewController"];
    viewCtrl.coinName = coinName;
    viewCtrl.contactAddress = contactAddress;
    viewCtrl.address = self.currentWalletAddress;
    [self presentViewController:viewCtrl animated:YES completion:nil];
    
}


- (IBAction)onAddButtonClick:(id)sender {
    
    QRScanViewController *viewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"QRScanViewController"];
    [self presentViewController:viewCtrl animated:YES completion:nil];
}

#pragma -
#pragma mark ChangeWalletViewDelegate

/**
 when user click tableview cell,return the address to home viewcontroller
 
 @param address The Wallet Address
 */
- (void)onSelectedWallet:(NSString *)address {
    
    libdefwallet::DEFWalletManager *walletManager = libdefwallet::DEFWalletManager::shareInstance();
    libdefwallet::DEFWallet *wallet = walletManager->findWalletByAddress([address UTF8String]);
    
    NSString *walletName = [NSString stringWithCString:wallet->getWalletName().c_str() encoding:NSUTF8StringEncoding];
    NSString *addr = [NSString stringWithCString:wallet->getAddress().c_str() encoding:NSUTF8StringEncoding];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:addr forKey:@"defaultWalletAddress"];
    [defaults setValue:walletName forKey:@"defaultWalletName"];
    
    self.currentWalletName = walletName;
    self.currentWalletAddress = addr;
    
    self.walletNameLabel.text = self.currentWalletName;
    self.walletAddressLabel.text = [NSString stringWithFormat:@"%@%@",@"0x",self.currentWalletAddress];
    
    //Reload wallet assets
    [self  loadWalletAssets];
}

@end
