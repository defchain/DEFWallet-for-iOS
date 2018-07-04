//
//  WalletAssetsViewController.h
//  DEFWallet
//
//

#import <UIKit/UIKit.h>

@interface WalletAssetsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSString *coinName;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *contactAddress;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@end
