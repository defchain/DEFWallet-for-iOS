//
//  TransactionViewController.h
//  DEFWallet
//
//

#import <UIKit/UIKit.h>

@interface TransactionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *contactAddress;
@property (nonatomic, strong) NSString *coinName;

@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UITextField *remarkTextField;
@property (weak, nonatomic) IBOutlet UISlider *gasSlider;
@property (weak, nonatomic) IBOutlet UILabel *gasLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

- (IBAction)gasSoliderChanged:(id)sender;

- (IBAction)onSubmitButtonClick:(id)sender;

@end
