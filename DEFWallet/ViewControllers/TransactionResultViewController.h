//
//  TransactionResultViewController.h
//  DEFWallet
//
//

#import <UIKit/UIKit.h>

@interface TransactionResultViewController : UIViewController


@property (nonatomic, strong) NSString *txHash;
@property (nonatomic, strong) NSString *from;
@property (nonatomic, strong) NSString *to;
@property (nonatomic, assign) double value;
@property (nonatomic, strong) NSString *coinName;
@property (nonatomic, assign) double gasUsed;


@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UILabel *sendValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *coinNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *toAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *gasUsedLabel;
@property (weak, nonatomic) IBOutlet UILabel *remarkLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *hashLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

/**
 cancel button click
 */
- (IBAction)cancel:(id)sender;


/**
 copy button click
 */
- (IBAction)onCopyButtonClick:(id)sender;


@end
