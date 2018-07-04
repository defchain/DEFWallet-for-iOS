//
//  TransactionResultViewController.m
//  DEFWallet
//
//

#import "TransactionResultViewController.h"
#import "MBProgressHUD.h"
#import "UIColor+Category.h"

@interface TransactionResultViewController ()

@end

@implementation TransactionResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [self buildQRImage:[NSString stringWithFormat:@"https://etherscan.io/tx/%@",self.txHash]];
    [self.imageView setImage:image];
    
    self.view.backgroundColor = [UIColor colorWithRGBHex:0x263D55];
    self.backgroundView.layer.cornerRadius = 5;
    self.backgroundView.layer.masksToBounds = YES;
    
    self.sendValueLabel.text = [NSString stringWithFormat:@"-%lf",self.value];
    self.coinNameLabel.text = self.coinName;
    self.fromAddressLabel.text = self.from;
    self.toAddressLabel.text = self.to;
    self.gasUsedLabel.text = [NSString stringWithFormat:@"%lf ether",self.gasUsed];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.timeLabel.text = [formatter stringFromDate:[NSDate date]];
    self.hashLabel.text = self.txHash;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIImage *)buildQRImage:(NSString *)value {
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *addressData = [value dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:addressData forKeyPath:@"inputMessage"];
    
    CIImage *outImage = [filter outputImage];
    return [UIImage imageWithCIImage:outImage];
}

- (IBAction)cancel:(id)sender {
    
    //exit
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onCopyButtonClick:(id)sender {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = NSLocalizedString(@"copy_sucess", @"copy_sucess");
    hud.label.font = [UIFont systemFontOfSize:14.0];
    hud.userInteractionEnabled= NO;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1.25];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [NSString stringWithFormat:@"https://etherscan.io/tx/%@",self.txHash];
}
@end
