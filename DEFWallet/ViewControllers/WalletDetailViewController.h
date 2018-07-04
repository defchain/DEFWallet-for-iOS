//
//  WalletDetailViewController.h
//  DEFWallet
//
//

#import <UIKit/UIKit.h>

@interface WalletDetailViewController : UITableViewController

@property (nonatomic, assign) NSString *address;

@property (nonatomic, assign) NSString *walletName;

@property (weak, nonatomic) IBOutlet UILabel *walletNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end
