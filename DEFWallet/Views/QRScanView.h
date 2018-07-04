//
//  QRScanView.h
//  QRCodeScan
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@protocol QRScanViewDelegate <NSObject>

/**
 the function for Delegate return QRCode's info

 @param result result string
 */
- (void)onScanQRCodeForResult:(NSString *)result;


@end


@interface QRScanView : UIView

@property (nonatomic,weak) id<QRScanViewDelegate>delegate;

@property (nonatomic,strong) AVCaptureSession *session;

/**
 init parameters for camera

 @param mScanRect cgrect
 */
- (void)initCamera:(CGRect)mScanRect;

@end
