//
//  ReceiptCoinViewController.h
//  DEFWallet
//
//

#import <UIKit/UIKit.h>

@interface ReceiptCoinViewController : UIViewController

@property (nonatomic, strong) NSString *address;

@property (weak, nonatomic) IBOutlet UIView *whiteView;
@property (weak, nonatomic) IBOutlet UILabel *walletNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

//copy button click
- (IBAction)onCopyButtonClick:(id)sender;

@end
