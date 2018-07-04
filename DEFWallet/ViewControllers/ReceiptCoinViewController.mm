//
//  ReceiptCoinViewController.m
//  DEFWallet
//
//  Created by 成岗 on 2018/6/19.
//

#import "ReceiptCoinViewController.h"
#import <CoreImage/CoreImage.h>
#import "MBProgressHUD.h"
#import "UIColor+Category.h"

#import <defwallet/def_wallet_manager.h>
#import <defwallet/def_wallet.h>

@interface ReceiptCoinViewController ()

@end

@implementation ReceiptCoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpUIs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setUpUIs {
    
    self.addressLabel.text = [NSString stringWithFormat:@"0x%@",self.address];
    [self.qrImageView setImage:[self buildQRImageWithAddress:self.addressLabel.text]];
    
    self.view.backgroundColor = [UIColor colorWithRGBHex:0x263D55];
    
    self.whiteView.layer.cornerRadius = 5;
    self.whiteView.layer.masksToBounds = YES;
    
    __weak ReceiptCoinViewController *viewCtrl = self;
    dispatch_queue_t queue = dispatch_queue_create("io.defensor.receiptcoin", nil);
    dispatch_async(queue, ^{
        
        libdefwallet::DEFWalletManager *manager = libdefwallet::DEFWalletManager::shareInstance();
        libdefwallet::DEFWallet *wallet = manager->findWalletByAddress([self.address UTF8String]);
        std::string walletName  = wallet->getWalletName();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            viewCtrl.walletNameLabel.text = [NSString stringWithCString:walletName.c_str() encoding:NSUTF8StringEncoding];
        });
    });
}

/**
 *  create qrcode image
 *
 *  @param image CIImage
 *  @param size  image width
 */
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    //create bitmap
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.save bitmap
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}


- (UIImage *)buildQRImageWithAddress:(NSString *)address {
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *addressData = [address dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:addressData forKeyPath:@"inputMessage"];
    
    CIImage *outImage = [filter outputImage];
    return [self createNonInterpolatedUIImageFormCIImage:outImage withSize:200];
}

- (IBAction)cancel:(id)sender {
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
    pasteboard.string = self.addressLabel.text;
}
@end
