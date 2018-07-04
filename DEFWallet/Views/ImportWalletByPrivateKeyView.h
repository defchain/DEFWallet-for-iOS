//
//  ImportWalletByPrivateKeyView.h
//  DEFWallet
//
//

#import <UIKit/UIKit.h>


@protocol ImportWalletByPrivateKeyViewDelegate

//Import wallet success
- (void)didFinishedImportWallet;

@end

@interface ImportWalletByPrivateKeyView : UIView

@property (nonatomic, assign) id<ImportWalletByPrivateKeyViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextView *privateKeyTextView;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *rePasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *passwordEyeButton;
@property (weak, nonatomic) IBOutlet UIButton *repasswordEyeButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

/**
 Eye button click event
 */
- (IBAction)passwordEyeClick:(id)sender;


/**
 text value changed
 */
- (IBAction)textValueChanged:(id)sender;


/**
 submit
 */
- (IBAction)submit:(id)sender;

@end
