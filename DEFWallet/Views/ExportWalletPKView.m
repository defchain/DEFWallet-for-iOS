//
//  ExportWalletPKView.m
//  DEFWallet
//
//

#import "ExportWalletPKView.h"

@implementation ExportWalletPKView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
        
    }
    return self;
}

- (IBAction)close:(id)sender {
    self.hidden = YES;
}

- (IBAction)copy:(id)sender {
    
    if (self.delegate) {
        [self.delegate onCopyButtonClick];
    }
}
@end
