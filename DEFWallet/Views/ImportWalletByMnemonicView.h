//
//  ImportWalletByMnemonicView.h
//  DEFWallet
//
//

#import <UIKit/UIKit.h>

@protocol ImportWalletByMnemonicViewDelegate

//import wallet finish
- (void)didFinishedImportWallet;

@end

@interface ImportWalletByMnemonicView : UIView

//delegate
@property (nonatomic, assign) id<ImportWalletByMnemonicViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextView *mnemonicTextView;
@property (weak, nonatomic) IBOutlet UITextField *pathTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *rePasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *passwordEyeButton;
@property (weak, nonatomic) IBOutlet UIButton *repasswordEyeButton;

/**
 submit
 */
- (IBAction)submit:(id)sender;


/**
 text value changed
 */
- (IBAction)textValueChanged:(id)sender;


/**
 show/hide password
 */
- (IBAction)changePasswordDisplay:(id)sender;


/**
 on keyboard end on exit
 @param sender event Sender
 */
- (IBAction)didEndOnExit:(id)sender;

@end
