//
//  QRScanViewController.h
//  DEFWallet
//
//

#import <UIKit/UIKit.h>
#import "QRScanView.h"

@protocol QRScanViewControllerDelegate

- (void)onScanQRResult:(NSString *)result;

@end

@interface QRScanViewController : UIViewController

@property(nonatomic, assign) id<QRScanViewDelegate> delegate;

//contentView
@property (weak, nonatomic) IBOutlet QRScanView *contentView;

//cancel
- (IBAction)cancel:(id)sender;

@end
