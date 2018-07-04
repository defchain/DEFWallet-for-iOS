//
//  ValidateMnemonicViewController.m
//  DEFWallet
//
//

#import "ValidateMnemonicViewController.h"
#import "UIColor+Category.h"
#import "MBProgressHUD.h"

#import <defwallet/def_wallet_manager.h>
#import <defwallet/def_wallet.h>

#define kNotificationNameCreateOrImportWalletSuccess @"kNotificationNameCreateOrImportWalletSuccess"

@interface ValidateMnemonicViewController ()

@property(nonatomic, strong) NSMutableArray *mnemonicArray;
@property(nonatomic, strong) NSMutableArray *selectedMnemonicArray;

//mnemonic button view
@property (weak, nonatomic) IBOutlet UIView *mnemonicBtnView;

//select mnemonic view
@property (weak, nonatomic) IBOutlet UIView *selectedMnemonicView;

//submit button
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

//select x y
@property (nonatomic, assign) CGFloat selectMnemonicX;
@property (nonatomic, assign) CGFloat selectMnemonicY;

//loading
@property (nonatomic, strong) MBProgressHUD *progressHUD;

//is this viewCtrl first appear
@property (nonatomic, assign) BOOL isFirstAppear;

@end

@implementation ValidateMnemonicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"validate_mnemonic_title", @"validate_mnemonic_title");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.progressHUD];
    
    self.selectedMnemonicArray = [NSMutableArray array];
    
    //random sort of mnemonic
    [self randomSortMnemonic];
}
    
- (void)viewDidAppear:(BOOL)animated {
    
    if(!self.isFirstAppear){
        
        //init mnemonic buttons
        [self setupMnemonicButtons];
        
        self.isFirstAppear = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


/**
 random sort of mnemonic
 */
- (void)randomSortMnemonic {
    
    self.mnemonicArray = [NSMutableArray arrayWithArray:[self.mnemonic componentsSeparatedByString:@" "]];
    for (int i = 0 ;i < self.mnemonicArray.count; i ++) {
        
        int randomIndex = arc4random() % self.mnemonicArray.count;
        [self.mnemonicArray exchangeObjectAtIndex:i withObjectAtIndex:randomIndex];
    }
}


/**
 init mnemonic buttons
 */
- (void)setupMnemonicButtons {
    
    UIFont *font = [UIFont systemFontOfSize:15];
    CGFloat currentX = 0.0;
    CGFloat currentY = 0.0;
    
    for (int i = 0; i < self.mnemonicArray.count; i++) {
        
        NSString *mnemonicStr  = [self.mnemonicArray objectAtIndex:i];
        CGSize buttonSize = [mnemonicStr sizeWithAttributes:@{NSFontAttributeName:font}];
        
        if (currentX + buttonSize.width > self.mnemonicBtnView.frame.size.width) {
            currentX = 0.0;
            currentY += 40.0 + 10.0;
        }
        
        CGRect frame = CGRectMake(currentX, currentY, buttonSize.width + 20, buttonSize.height + 10);
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        [button setTitle:mnemonicStr forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor colorWithRGBHex:0xE5E5E5]];
        [button setTitleColor:[UIColor colorWithRGBHex:0x808492] forState:UIControlStateNormal];
        button.titleLabel.font = font;
        button.tag = i;
        [self.mnemonicBtnView addSubview:button];
        [button addTarget:self action:@selector(onMnemonicButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        currentX += (buttonSize.width + 20 + 10);
    }
}


/**
 add mnemonic
 @param mnemonic mnemonic str
 @param tag tag
 */
- (void)addSelectMnemonic:(NSString *)mnemonic withTag:(NSInteger)tag {
    
    [self.selectedMnemonicArray addObject:mnemonic];
    
    UIFont *font = [UIFont systemFontOfSize:15];
    CGSize buttonSize = [mnemonic sizeWithAttributes:@{NSFontAttributeName:font}];
    
    if (self.selectMnemonicX + buttonSize.width > self.selectedMnemonicView.frame.size.width) {
        self.selectMnemonicX = 0.0;
        self.selectMnemonicY += buttonSize.height + 4;
    }
    
    CGRect frame = CGRectMake(self.selectMnemonicX, self.selectMnemonicY, buttonSize.width + 20, buttonSize.height + 4);
    
    UIButton *selectBtn = [[UIButton alloc] initWithFrame:frame];
    [selectBtn setTitle:mnemonic forState:UIControlStateNormal];
    [selectBtn setBackgroundColor:[UIColor clearColor]];
    [selectBtn setTitleColor:[UIColor colorWithRGBHex:0x808492] forState:UIControlStateNormal];
    selectBtn.titleLabel.font = font;
    selectBtn.tag = tag;
    [self.selectedMnemonicView addSubview:selectBtn];
    [selectBtn addTarget:self action:@selector(onSelectMnemonicBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.selectMnemonicX += buttonSize.width + 20 + 10;
}

/**
 Mnemonic button click event
 @param sender Event Sender
 */
- (IBAction)onMnemonicButtonClick:(id)sender {
    
    //change old button style
    UIButton *button = (UIButton *)sender;
    [button setEnabled:NO];
    [button setBackgroundColor:[UIColor colorWithRGBHex:0x4A90E2]];
    [button setTitleColor:[UIColor colorWithRGBHex:0xFFFFFF] forState:UIControlStateNormal];
    
    //add choose mnemonic
    NSString *mnemonicStr = [self.mnemonicArray objectAtIndex:button.tag];
    [self addSelectMnemonic:mnemonicStr withTag:button.tag];
    
    //check selected mnemonic is correct
    NSString *selectedMnemonicStr = @"";
    for (int i = 0 ; i < self.selectedMnemonicArray.count; i ++) {
        NSString *tmpStr = [self.selectedMnemonicArray objectAtIndex:i];
        if (i == 0) {
            selectedMnemonicStr = [selectedMnemonicStr stringByAppendingString:tmpStr];
            continue;
        }
        selectedMnemonicStr = [selectedMnemonicStr stringByAppendingFormat:@" %@",tmpStr];
    }
    
    if ([selectedMnemonicStr isEqualToString:self.mnemonic]) {
        [self.submitButton setBackgroundColor:[UIColor colorWithRGBHex:0xF7931A]];
        [self.submitButton setEnabled:YES];
    }
}



- (void) refreshSelectedMnemonicView {
    
    self.selectMnemonicX = 0;
    self.selectMnemonicY = 0;
    
    NSArray *subViews = [self.selectedMnemonicView subviews];
    for (UIView *view in subViews) {

        CGRect f = view.frame;
        
        if (self.selectMnemonicX + f.size.width > self.selectedMnemonicView.frame.size.width) {
            self.selectMnemonicX = 0.0;
            self.selectMnemonicY += f.size.height + 4;
        }
        
        f.origin.x = self.selectMnemonicX;
        f.origin.y = self.selectMnemonicY;
        [view setFrame:f];
        
        self.selectMnemonicX += f.size.width + 20;
    }
    
    if(self.selectedMnemonicArray.count != self.mnemonicArray.count){
        [self.submitButton setBackgroundColor:[UIColor colorWithRGBHex:0xCCCCCC]];
        [self.submitButton setEnabled:NO];
        return;
    }
    
    //check selected mnemonic is correct
    NSString *selectedMnemonicStr = @"";
    for (int i = 0 ; i < self.selectedMnemonicArray.count; i ++) {
        NSString *tmpStr = [self.selectedMnemonicArray objectAtIndex:i];
        if (i == 0) {
            selectedMnemonicStr = [selectedMnemonicStr stringByAppendingString:tmpStr];
            continue;
        }
        selectedMnemonicStr = [selectedMnemonicStr stringByAppendingFormat:@" %@",tmpStr];
    }
    
    if ([selectedMnemonicStr isEqualToString:self.mnemonic]) {
        [self.submitButton setBackgroundColor:[UIColor colorWithRGBHex:0xF7931A]];
        [self.submitButton setEnabled:YES];
    } else {
        [self.submitButton setBackgroundColor:[UIColor colorWithRGBHex:0xCCCCCC]];
        [self.submitButton setEnabled:NO];
    }
}



- (IBAction)onSelectMnemonicBtnClick:(id)sender {
    
    //delete select mnemonic
    UIButton *selectedButton = (UIButton *)sender;
    NSUInteger index = [self.selectedMnemonicView.subviews indexOfObject:selectedButton];
    [self.selectedMnemonicArray removeObjectAtIndex:index];
    
    [selectedButton removeFromSuperview];
    
    UIButton *mnemonicButton = (UIButton *)[self.mnemonicBtnView viewWithTag:selectedButton.tag];
    mnemonicButton.enabled = YES;
    [mnemonicButton setTitleColor:[UIColor colorWithRGBHex:0x808492] forState:UIControlStateNormal];
    [mnemonicButton setBackgroundColor:[UIColor colorWithRGBHex:0xE5E5E5]];
    
    [self refreshSelectedMnemonicView];
}

/**
 submit
 */
- (IBAction)submit:(id)sender {
    
    __weak ValidateMnemonicViewController *weakSelf = self;
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"remove_mnemonic_message", @"remove_mnemonic_message")
                                                                         message:@""
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault handler:nil]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        self.progressHUD.label.text = NSLocalizedString(@"removing_mnemonic", @"removing_mnemonic");
        [self.progressHUD showAnimated:YES];
        
        dispatch_queue_t queue = dispatch_queue_create("io.defensor.validatemnenoic", nil);
        dispatch_async(queue, ^{
            
            
            //Delete mnemonic
            libdefwallet::DEFWalletManager *walletManager = libdefwallet::DEFWalletManager::shareInstance();
            libdefwallet::DEFWallet *wallet = walletManager->findWalletByAddress([self.address UTF8String]);
            wallet->removeMnemonic();
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.progressHUD hideAnimated:YES];
                
                //提示
                UIAlertController *alertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"removed_mnemonic_title", @"removed_mnemonic_title") message:NSLocalizedString(@"removed_mnemonic_message", @"removed_mnemonic_message") preferredStyle:UIAlertControllerStyleActionSheet];
                [alertView addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    [weakSelf dismissViewControllerAnimated:YES completion:^{
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameCreateOrImportWalletSuccess object:nil];
                    }];
                }]];
                [weakSelf presentViewController:alertView animated:YES completion:nil];
            });
            
        });
    }]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

@end
