//
//  ETHWebService.h
//  DEFWallet
//
//

#import <Foundation/Foundation.h>

@interface ETHWebService : NSObject

/**
 Share Instance
 */
+ (ETHWebService *)shareInstance;

/**
 Query ETH balance of the address
 */
- (void)getETHBalance:(NSString *)address
              success:(void(^)(double balance))successCompileBlock
               failed:(void(^)(void))failedCompileBlock;


/**
 Query ERC20 Token Balance
 */
- (void)getERC20TokenBalance:(NSString *)address
              contactAddress:(NSString *)contactAddress
                     success:(void(^)(double balance))successCompileBlock
                      failed:(void(^)(void))failedCompileBlock;

/**
 get current gas price
 @param successCompileBlock return gas price(gwei)
 @param failedCompileBlock failed
 */
- (void)getGasPrice:(void(^)(NSInteger gasPrice))successCompileBlock
             failed:(void(^)(void))failedCompileBlock;

/**
 get transaction list
 
 @param address: wallet address
 @param successCompileBlock
 @param failedCompileBlock
 */
- (void)getTransactionsByAddress:(NSString *)address
                         success:(void(^)(NSMutableArray *transList))successCompileBlock
                          failed:(void(^)(void))failedCompileBlock;

/**
get ERC20 token transaction list
 
 @param address: the wallet address
 @param contactAddress contact address
 @param successCompileBlock success
 @param failedCompileBlock failed
 */
- (void)getERC20Tansaction:(NSString *)address
            contactAddress:(NSString *)contactAddress
                   success:(void(^)(NSMutableArray *transList))successCompileBlock
                    failed:(void(^)(void))failedCompileBlock;


/**
get current eth price

 @param successCompileBlock
 @param failedCompileBlock
 */
- (void) getCurrentETHUSDPrice:(void(^)(double usdPrice))successCompileBlock
                        failed:(void(^)(void))failedCompileBlock;

/**
get current eth price of RMB
 
 @param successCompileBlock 成功
 @param failedCompileBlock 失败
 */
- (void)getCurrentETHRMBPrice:(void(^)(double rmbPrice))successCompileBlock
                       failed:(void(^)(void))failedCompileBlock;

/**
get nonce of wallet
 */
- (void)getTransactionCount:(NSString *)address
                    success:(void(^)(NSInteger none))successCompileBlock
                     failed:(void(^)(void))failedCompileBlock;

/**
 get gas limit of transaction
 
 @param to: Address send to
 @param value: amount of eth
 @param successCompileBlock
 @param failedCompileBlock
 */
- (void)estimateGas:(NSString *)to
                eth:(double)value
            success:(void(^)(NSInteger gas))successCompileBlock
             failed:(void(^)(void))failedCompileBlock;

/**
 send raw transaction info
 
 @param hex
 @param successCompileBlock
 @param failedCompileBlock 
 */
- (void)sendRawTransaction:(NSString *)hex
                   success:(void(^)(NSString *))successCompileBlock
                    failed:(void(^)(void))failedCompileBlock;

@end
