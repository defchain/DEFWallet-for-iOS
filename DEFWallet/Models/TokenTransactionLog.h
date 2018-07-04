//
//  TokenTransactionLog.h
//  DEFWallet
//
//

#import <Foundation/Foundation.h>

@interface TokenTransactionLog : NSObject

@property (nonatomic, strong) NSString *from;
@property (nonatomic, strong) NSString *to;
@property (nonatomic, strong) NSString *contactAddress;
@property (nonatomic, strong) NSString *tokenName;
@property (nonatomic, strong) NSString *tokenSymbol;
@property (nonatomic, assign) NSInteger tokenDecimal;
@property (nonatomic, assign) double value;
@property (nonatomic, strong) NSDate *time;

@end
