//
//  WalletAssetsViewController.m
//  DEFWallet
//
//

#import "WalletAssetsViewController.h"
#import "UIColor+Category.h"
#import "NSString+Category.h"
#import "ETHWebService.h"
#import "TransactionViewController.h"
#import "TransactionCell.h"
#import "TransactionLog.h"
#import "TokenTransactionLog.h"
#import "ReceiptCoinViewController.h"

@interface WalletAssetsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *coinImageView;
@property (weak, nonatomic) IBOutlet UILabel *coinNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *transactions;

@end

@implementation WalletAssetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpUIs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) setUpUIs {
    
    [self.headerView setBackgroundColor:[UIColor colorWithRGBHex:0x263D55]];
    
    [self loadData];
}

- (void)loadData {
    
    if ([self.coinName isEqualToString:@"eth"]) {
        
        [self.coinImageView setImage:[UIImage imageNamed:@"icon_eth_high"]];
        self.coinNameLabel.text = @"ETH";
        
        [[ETHWebService shareInstance] getETHBalance:self.address success:^(double balance) {
            
            self.amountLabel.text = [NSString stringWithFormat:@"%lf个",balance];
            
            if (balance <= 0) {
                return;
            }
            
            [[ETHWebService shareInstance] getCurrentETHRMBPrice:^(double rmbPrice) {
                
                self.priceLabel.text = [NSString stringWithFormat:@"¥%lf",balance * rmbPrice];
                
            } failed:^{
                NSLog(@"load eth price failed");
            }];
        } failed:^{
            NSLog(@"load balance of eth failed");
        }];
        
        //get transaction list
        __weak WalletAssetsViewController *weakSelf = self;
        [[ETHWebService shareInstance] getTransactionsByAddress:self.address success:^(NSMutableArray *transList) {
            
            //fresh data
            weakSelf.transactions = transList;
            [weakSelf.tableView reloadData];
            
        } failed:^{
            NSLog(@"load transaction list failed");
        }];
        
    } else if([self.coinName isEqualToString:@"def"]) {
        
        [self.coinImageView setImage:[UIImage imageNamed:@"defensor_28"]];
        self.coinNameLabel.text = @"DEF";
        
        //获取erc20 token
        __weak WalletAssetsViewController *weakSelf = self;
        [[ETHWebService shareInstance] getERC20TokenBalance:self.address contactAddress:self.contactAddress success:^(double balance) {
            
            weakSelf.amountLabel.text = [NSString stringWithFormat:@"%lf",balance];
            
        } failed:^{
            NSLog(@"load ERC20 Token transaction balance failed");
        }];
        
        [[ETHWebService shareInstance] getERC20Tansaction:self.address contactAddress:self.contactAddress success:^(NSMutableArray *transList) {
            
            //fresh data
            weakSelf.transactions = transList;
            [weakSelf.tableView reloadData];
            
        } failed:^{
            NSLog(@"load erc20 transaction list failed");
        }];
    }
}

#pragma -
#pragma mark UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.transactions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TransactionCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TransactionCell" forIndexPath:indexPath];
    
    if ([self.coinName isEqualToString:@"eth"]) {
        
        TransactionLog *log = [self.transactions objectAtIndex:indexPath.row];
        NSString *addr = [NSString stringWithFormat:@"0x%@",self.address];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM月dd日 HH:mm"];
        NSString *time = [formatter stringFromDate:log.time];
        if ([log.from isEqualToString:addr]) {
            cell.iconImageView.image = [UIImage imageNamed:@"icon_out"];
            cell.toAddressLabel.text = log.to;
        } else {
            cell.iconImageView.image = [UIImage imageNamed:@"icon_in"];
            cell.toAddressLabel.text = log.from;
        }
        cell.timeLabel.text = time;
        if ([log.contactAddress isNotEmpty]) {
            cell.amountLabel.text = @"contact";
        } else {
            cell.amountLabel.text = [NSString stringWithFormat:@"%lf ETH",log.value];
        }
        
    } else {
        
        TokenTransactionLog *log = [self.transactions objectAtIndex:indexPath.row];
        
        NSString *addr = [NSString stringWithFormat:@"0x%@",self.address];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM月dd日 HH:mm"];
        NSString *time = [formatter stringFromDate:log.time];
        if ([log.from isEqualToString:addr]) {
            cell.iconImageView.image = [UIImage imageNamed:@"icon_out"];
            cell.toAddressLabel.text = log.to;
        } else {
            cell.iconImageView.image = [UIImage imageNamed:@"icon_in"];
            cell.toAddressLabel.text = log.from;
        }
        cell.amountLabel.text = [NSString stringWithFormat:@"%lf %@",log.value,self.coinName];
        cell.timeLabel.text = time;
    }
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

#pragma -
#pragma mark IBActions

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


/**
 send button click
 */
- (IBAction)onTranslationButtonClick:(id)sender {
    
    TransactionViewController *viewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"TransactionViewController"];
    viewCtrl.address = self.address;
    viewCtrl.coinName = self.coinNameLabel.text;
    viewCtrl.contactAddress = self.contactAddress;
    [self presentViewController:viewCtrl animated:YES completion:nil];
}


/**
 receive button click
 */
- (IBAction)onReceiveButtonClick:(id)sender {
    
    ReceiptCoinViewController *coinViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"ReceiptCoinViewController"];
    coinViewCtrl.address = self.address;
    [self presentViewController:coinViewCtrl animated:YES completion:nil];
}


@end
