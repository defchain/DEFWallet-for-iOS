//
//  WalletListViewController.m
//  DEFWallet
//
//

#import "WalletListViewController.h"
#import "WalletListViewCell.h"
#import "DEFWallet.h"
#import "WalletDetailViewController.h"
#import "CreateWalletViewController.h"
#import "ImportWalletViewController.h"
#import "ETHWebService.h"

#import <vector>
#import <defwallet/def_wallet_manager.h>
#import <defwallet/def_wallet.h>


#define kNotificationNameCreateOrImportWalletSuccess @"kNotificationNameCreateOrImportWalletSuccess"

@interface WalletListViewController ()<WalletListViewCellDelegate>

@property(nonatomic, strong) NSMutableArray *list;

@end

@implementation WalletListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpNotification];
    
    // setup UI
    [self setupUIs];
    
    //load wallet list
    [self loadWalletList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


/**
setup UI
 */
- (void)setupUIs {
    
    self.title = NSLocalizedString(@"manage_wallet_title", @"manage_wallet_title");
    
    [self.tableView registerNib:[UINib nibWithNibName:@"WalletListViewCell" bundle:nil] forCellReuseIdentifier:@"WalletListViewCell"];
}


/**
 load wallet list
 */
- (void)loadWalletList {
    
    libdefwallet::DEFWalletManager *walletManager = libdefwallet::DEFWalletManager::shareInstance();
    std::vector<libdefwallet::DEFWallet> walletList = walletManager->listAllWallet();
    
    self.list = [[NSMutableArray alloc] init];
    for (int i = 0; i < walletList.size(); i ++) {
        
        libdefwallet::DEFWallet wallet = walletList[i];
        NSString *name = [NSString stringWithCString:wallet.getWalletName().c_str() encoding:NSUTF8StringEncoding];
        NSString *address = [NSString stringWithCString:wallet.getAddress().c_str() encoding:NSUTF8StringEncoding];
        
        DEFWallet *newWallet = [[DEFWallet alloc] initWithName:name address:address];
        [self.list addObject:newWallet];
    }
}

#pragma -
#pragma mark tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DEFWallet *wallet = [self.list objectAtIndex:indexPath.row];

    WalletListViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"WalletListViewCell"
                                                                    forIndexPath:indexPath];
    cell.walletNameLabel.text = wallet.name;
    cell.addressLabel.text = wallet.address;
    
    //load balance of eth
    [[ETHWebService shareInstance] getETHBalance:wallet.address success:^(double balance) {
        
        //load eth price
        [[ETHWebService shareInstance] getCurrentETHRMBPrice:^(double rmbPrice) {
            cell.priceLabel.text = [NSString stringWithFormat:@"≈¥%lf",rmbPrice * balance];
        } failed:^{
            NSLog(@"load eth price failed");
        }];
        
    } failed:^{
        NSLog(@"load eth balance failed");
    }];
    
    cell.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 142.0f;
}

- (void)onClickWalletCell:(id) cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    DEFWallet *wallet = [self.list objectAtIndex:indexPath.row];
    WalletDetailViewController *viewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"WalletDetailViewController"];
    viewCtrl.address = wallet.address;
    viewCtrl.walletName = wallet.name;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

- (IBAction)onCreateWalletBtnClick:(id)sender {
    
    UINavigationController *navCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateWalletNavigationControl"];
    [self presentViewController:navCtrl animated:YES completion:nil];
}

- (IBAction)onImportWalletBtnClick:(id)sender {
    
    UINavigationController *navCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"ImportWalletNavigationControl"];
    [self presentViewController:navCtrl animated:YES completion:nil];
}

- (void)setUpNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didCreateOrImportWalletSuccess)
                                                 name:kNotificationNameCreateOrImportWalletSuccess
                                               object:nil];
}

/**
 create or import wallet success
 */
- (void)didCreateOrImportWalletSuccess {
    
    [self loadWalletList];
    [self.tableView reloadData];
}

@end
