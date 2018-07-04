//
//  Transaction.h
//  DEFWallet
//
//

#import <Foundation/Foundation.h>

@interface TransactionLog : NSObject

@property(nonatomic, strong) NSString *from;
@property(nonatomic, strong) NSString *to;
@property(nonatomic, assign) double value;
@property(nonatomic, strong) NSString *contactAddress;
@property(nonatomic, assign) long long gasPrice;
@property(nonatomic, assign) long long gasUsed;
@property(nonatomic, strong) NSDate *time;

@end
