//
//  DEFWallet.h
//  DEFWallet
//
//

#import <Foundation/Foundation.h>

@interface DEFWallet : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *address;

- (id)initWithName:(NSString *)name address:(NSString *)address;

@end
