//
//  ExportWalletPKView.h
//  DEFWallet
//
//

#import <UIKit/UIKit.h>

@protocol ExportWalletPKViewDelegate


- (void)onCopyButtonClick;

@end

@interface ExportWalletPKView : UIView

@property (nonatomic, assign) id<ExportWalletPKViewDelegate> delegate;

//private Key Label
@property (weak, nonatomic) IBOutlet UILabel *pkLabel;

//copy PK
- (IBAction)copy:(id)sender;

@end
