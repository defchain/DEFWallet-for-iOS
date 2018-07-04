//
//  ChangeWalletView.m
//  DEFWallet
//
//

#import "ChangeWalletView.h"
#import "DEFWallet.h"

#import <vector>
#import <defwallet/def_wallet_manager.h>
#import <defwallet/def_wallet.h>


//#define
#define kNotificationNameCreateOrImportWalletSuccess @"kNotificationNameCreateOrImportWalletSuccess"

@interface ChangeWalletView()<UITableViewDelegate,UITableViewDataSource>

//List
@property(nonatomic, strong) NSMutableArray *list;

//TableView
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) NSString *defaultWalletAddress;

@end

@implementation ChangeWalletView


- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //load default wallet info
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.defaultWalletAddress = [defaults valueForKey:@"defaultWalletAddress"];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackgroundViewTap:)];
    [self.backgroundView addGestureRecognizer:self.tapGestureRecognizer];
    
    [self setUpNotification];
    
    //Load Wallet List
    [self loadWalletList];
    
}


/**
 Hide backgroundview
 */
- (void)onBackgroundViewTap:(UITapGestureRecognizer *)recognizer {
    
    self.hidden = YES;
}
    
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
    
    [self.tableView reloadData];
}


- (void)setUpNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didCreateOrImportWalletSuccess)
                                                 name:kNotificationNameCreateOrImportWalletSuccess
                                               object:nil];
}


- (void)didCreateOrImportWalletSuccess {
    
    [self loadWalletList];
}

    
#pragma -
#pragma mark UITableViewDataSource && UITableViewDelegate
    

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.list count];
}
    
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DEFWallet *wallet = [self.list objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WalletListCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WalletListCell"];
    }
    
    if ([wallet.address isEqualToString:self.defaultWalletAddress]) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
    cell.textLabel.text = wallet.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DEFWallet *wallet = [self.list objectAtIndex:indexPath.row];
    if (self.delegate) {
        [self.delegate onSelectedWallet:wallet.address];
    }
    
    self.hidden = YES;
}
    
@end
