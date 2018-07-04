//
//  BackupWalletSetpOneViewController.h
//  DEFWallet
//
//

#import <UIKit/UIKit.h>

@interface BackupWalletSetpOneViewController : UIViewController

//Wallet Address
@property(nonatomic, strong) NSString *address;


/**
 Backup Wallet Button Click
 */
- (IBAction)onBackupWalletBtnClick:(id)sender;


@end
