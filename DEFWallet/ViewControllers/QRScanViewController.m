//
//  QRScanViewController.m
//  DEFWallet
//
//

#import "QRScanViewController.h"
#import "UIColor+Category.h"

@interface QRScanViewController ()<QRScanViewDelegate>


@property (weak, nonatomic) IBOutlet UIView *titleView;

@property (weak, nonatomic) IBOutlet UIView *foregroundView;

@property (weak, nonatomic) IBOutlet UIImageView *scanAreaImage;

@end

@implementation QRScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleView.backgroundColor = [UIColor colorWithRGBHex:0x263D55];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];

    CGMutablePathRef maskPath = CGPathCreateMutable();
    CGRect f = self.scanAreaImage.frame;
    f.origin.y = 179;
    CGPathAddRect(maskPath, nil, f);
    CGPathAddRect(maskPath, nil, self.foregroundView.bounds);

    maskLayer.fillRule = kCAFillRuleEvenOdd;
    maskLayer.path = maskPath;
    self.foregroundView.layer.mask = maskLayer;
    
    [self.contentView initCamera:f];
    self.contentView.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    
    if ([self.contentView.session isRunning]) {
        [self.contentView.session stopRunning];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 the function for Delegate return QRCode's info
 
 @param result result string
 */
- (void)onScanQRCodeForResult:(NSString *)result {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onScanQRCodeForResult:)]) {
        [self.delegate onScanQRCodeForResult:result];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
