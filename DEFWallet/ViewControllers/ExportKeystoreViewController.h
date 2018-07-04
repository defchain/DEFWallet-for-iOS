//
//  ExportKeystoreViewController.h
//  DEFWallet
//
//

#import <UIKit/UIKit.h>

@interface ExportKeystoreViewController : UIViewController

@property(nonatomic, strong) NSString *keystore;

@property (weak, nonatomic) IBOutlet UITextView *textView;

- (IBAction)copyKeyStore:(id)sender;

@end
