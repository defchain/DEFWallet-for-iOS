//
//  DEFWallet.m
//  DEFWallet
//
//

#import "DEFWallet.h"

@implementation DEFWallet

- (id)initWithName:(NSString *)name address:(NSString *)address {
    
    self = [super init];
    if (self) {
        self.name = name;
        self.address = address;
    }
    return self;
}

@end
