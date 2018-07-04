//
//  QRScanView.m
//  QRCodeScan
//
//

#import "QRScanView.h"


@interface QRScanView ()<AVCaptureMetadataOutputObjectsDelegate>{
    CGRect _scanRect;
    
    //parameters for camera
    
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_ouput;
    AVCaptureDevice *_device;
    AVCaptureVideoPreviewLayer *_previewLayer;
    
    CALayer *_boxLayer;
    CAShapeLayer* _maskLayer;
    
}

@end


@implementation QRScanView

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}
/**
 init parameters for camera
 
 @param mScanRect cgrect
 */
- (void)initCamera:(CGRect)mScanRect{
    _scanRect = mScanRect;
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
    if (!_input) {
        return;
    }
    
    //init metadata output
    _ouput = [[AVCaptureMetadataOutput alloc] init];
    [_ouput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //初始化链接对象
    _session = [[AVCaptureSession alloc] init];
    if ([UIScreen mainScreen].bounds.size.height < 500) {
        [_session setSessionPreset:AVCaptureSessionPreset640x480];
    }
    else{
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
    }
    [_session addInput:_input];
    [_session addOutput:_ouput];
    
    [_ouput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    //x,y对换，提高识别速率
    //rectOfInterest都是按照横屏来计算的 所以当竖屏的情况下 x轴和y轴要交换一下。
    _ouput.rectOfInterest = CGRectMake(_scanRect.origin.y/self.bounds.size.height, _scanRect.origin.x/self.bounds.size.width, _scanRect.size.height/self.bounds.size.height, _scanRect.size.width/self.bounds.size.width);
    
    //init preview layer
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = self.bounds;
    [self.layer addSublayer:_previewLayer];
    
    //start session
    [_session startRunning];
    
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_session stopRunning];
        });
        if (self.delegate && [self.delegate respondsToSelector:@selector(onScanQRCodeForResult:)]) {
            [self.delegate onScanQRCodeForResult:metadataObject.stringValue];
        }
    }
}






@end
