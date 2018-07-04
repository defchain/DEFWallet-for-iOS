//
//  ImportWalletByKeystoreView.h
//  DEFWallet
//
//

#import <UIKit/UIKit.h>


@protocol ImportWalletByKeystoreViewDelegate

//Import wallet success
- (void)didFinishedImportWallet;

@end

@interface ImportWalletByKeystoreView : UIView

//delegate
@property (nonatomic, assign) id<ImportWalletByKeystoreViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextView *keystoreTextView;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *importButton;
@property (weak, nonatomic) IBOutlet UIButton *passwordEyeButton;

- (IBAction)textChanged:(id)sender;

- (IBAction)passwordEyeChangeDisplay:(id)sender;

/**
 submit
 */
- (IBAction)submit:(id)sender;

@end
