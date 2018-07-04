//
//  WalletListViewController.h
//  DEFWallet
//
//

#import <UIKit/UIKit.h>

@interface WalletListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

//tableview
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
