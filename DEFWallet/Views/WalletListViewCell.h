//
//  WalletListViewCell.h
//  DEFWallet
//
//

#import <UIKit/UIKit.h>

@protocol WalletListViewCellDelegate


/**
 cell click event
 */
- (void)onClickWalletCell:(id) cell;

@end

@interface WalletListViewCell : UITableViewCell

//Delegate
@property (nonatomic, assign) id<WalletListViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *walletNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end
