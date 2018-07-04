//
//  AssetService.h
//  DEFWallet
//
//  Created by 成岗 on 2018/6/14.
//

#import <Foundation/Foundation.h>

@interface AssetService : NSObject

/**
 Share Instance
 */
+ (AssetService *)shareInstance;

/**
 Query assets of wallet
 @param address address
 */
- (NSDictionary *)getWalletAssets:(NSString *)address;

@end
