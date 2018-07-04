//
//  ChangeWalletView.h
//  DEFWallet
//
//

#import <UIKit/UIKit.h>

@protocol ChangeWalletViewDelegate


/**
 when user click tableview cell,return the address to home viewcontroller

 @param address The Wallet Address
 */
- (void)onSelectedWallet:(NSString *)address;

@end

@interface ChangeWalletView : UIView

@property(nonatomic, assign) id<ChangeWalletViewDelegate> delegate;

@end
