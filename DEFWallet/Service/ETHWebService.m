//
//  ETHWebService.m
//  DEFWallet
//
//

#import "ETHWebService.h"
#import "AFNetworking.h"
#import "NSString+Category.h"
#import "TransactionLog.h"
#import "TokenTransactionLog.h"

#define kEtherscanIOApiKey  @"MNCCGIN85AS1ENIH6E49H6A7UZ6EZDGTMQ"

@interface ETHWebService()

@property(nonatomic, strong) AFHTTPSessionManager *session;

@end

@implementation ETHWebService

static ETHWebService *share_instance = nil;


/**
 Share Instance
 */
+ (ETHWebService *)shareInstance {
    
    if(share_instance == nil){
        share_instance = [[ETHWebService alloc] init];
    }
    return share_instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.session = [AFHTTPSessionManager manager];
        self.session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"application/x-json",@"text/html", nil];
    }
    return self;
}

/**
 Query ETH balance of the address
 */
- (void)getETHBalance:(NSString *)address
              success:(void(^)(double balance))successCompileBlock
               failed:(void(^)(void))failedCompileBlock{
    
    address = [address replaceFirstOfStr:@"0x"];
    
    NSDictionary *params = @{@"module":@"account",
                             @"action":@"balance",
                             @"address":[NSString stringWithFormat:@"0x%@",address],
                             @"tag":@"latest",
                             @"apikey":kEtherscanIOApiKey
                             };
    [self.session GET:@"https://api.etherscan.io/api"
           parameters:params
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  
                  //
                  NSDictionary *result = responseObject;
                  NSInteger status = [[result valueForKey:@"status"] integerValue];
                  if (status == 1) {

                      NSString *balance = result[@"result"];
                      successCompileBlock([balance longLongValue] / (pow(10, 18)));
                      return;
                  }

                  failedCompileBlock();
                  
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failedCompileBlock();
    }];
}

/**
 Query ERC20 Token Balance
 */
- (void)getERC20TokenBalance:(NSString *)address
              contactAddress:(NSString *)contactAddress
                     success:(void(^)(double balance))successCompileBlock
                      failed:(void(^)(void))failedCompileBlock {
    
    address = [NSString stringWithFormat:@"0x%@",address];
    
    NSDictionary *params = @{@"module":@"account",
                             @"action":@"tokenbalance",
                             @"address":address,
                             @"contractaddress":contactAddress,
                             @"tag":@"latest",
                             @"apikey":kEtherscanIOApiKey
                             };
    
    [self.session GET:@"https://api.etherscan.io/api"
           parameters:params
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  
                  //
                  NSDictionary *result = responseObject;
                  NSInteger status = [[result valueForKey:@"status"] integerValue];
                  if (status == 1) {
                      
                      NSString *balance = result[@"result"];
                      successCompileBlock([balance doubleValue] / pow(10, 18));
                      return;
                  }
                  
                  failedCompileBlock();
                  
              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  failedCompileBlock();
              }];
}


/**
 get nonce of wallet
 */
- (void)getTransactionCount:(NSString *)address
                    success:(void(^)(NSInteger none))successCompileBlock
                     failed:(void(^)(void))failedCompileBlock {
    
    NSDictionary *params = @{
                             @"module":@"proxy",
                             @"action":@"eth_getTransactionCount",
                             @"address":address,
                             @"tag":@"latest",
                             @"apikey":kEtherscanIOApiKey
                            };
    
    [self.session GET:@"https://api.etherscan.io/api"
           parameters:params
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                  //
                  NSDictionary *result = responseObject;
                  NSString *r = result[@"result"];
                  successCompileBlock([[r hexToNumber] integerValue]);
                  
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failedCompileBlock();
    }];
}

/**
 get current gas price
 @param successCompileBlock return gas price(gwei)
 @param failedCompileBlock failed
 */
- (void)getGasPrice:(void(^)(NSInteger gasPrice))successCompileBlock
             failed:(void(^)(void))failedCompileBlock {
    
    NSDictionary *params = @{
                             @"module":@"proxy",
                             @"action":@"eth_gasPrice",
                             @"apikey":kEtherscanIOApiKey
                             };
    
    [self.session GET:@"https://api.etherscan.io/api"
           parameters:params
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  
                  //
                  NSDictionary *result = responseObject;
                  NSNumber *number = [result[@"result"] hexToNumber];
                  NSInteger wei = [number integerValue];
                  NSInteger gWei = wei / pow(10, 9);
                  successCompileBlock(gWei);
                  
              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  failedCompileBlock();
              }];
}


/**
 get transaction list
 
 @param address wallet address
 @param successCompileBlock
 @param failedCompileBlock
 */
- (void)getTransactionsByAddress:(NSString *)address
                         success:(void(^)(NSMutableArray *transList))successCompileBlock
                          failed:(void(^)(void))failedCompileBlock {
    
    NSDictionary *params = @{
                             @"module":@"account",
                             @"action":@"txlist",
                             @"address":[NSString stringWithFormat:@"0x%@",address],
                             @"startblock":@0,
                             @"endblock":@99999999,
                             @"sort":@"desc",
                             @"apikey":kEtherscanIOApiKey
                             };
    
    [self.session GET:@"https://api.etherscan.io/api"
           parameters:params
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  
                  //
                  NSDictionary *result = responseObject;
                  if ([result[@"status"] integerValue] == 1) {
                      
                      //query success
                      NSMutableArray *transList = [NSMutableArray array];
                      NSArray *translations =  result[@"result"];
                      for (NSDictionary *transactionDict in translations) {
                          TransactionLog *transaction = [[TransactionLog alloc] init];
                          transaction.from = transactionDict[@"from"];
                          transaction.to = transactionDict[@"to"];
                          transaction.value = [transactionDict[@"value"] longLongValue] / pow(10, 18);
                          transaction.contactAddress = transactionDict[@"contractAddress"];
                          transaction.gasUsed = [transactionDict[@"gasUsed"] longLongValue];
                          transaction.gasPrice = [transactionDict[@"gasPrice"] longLongValue];
                          NSDate *time = [NSDate dateWithTimeIntervalSince1970:[transactionDict[@"timeStamp"] longLongValue]];
                          transaction.time = time;
                          [transList addObject:transaction];
                      }
                      successCompileBlock(transList);
                  } else {
                      failedCompileBlock();
                  }
                  
              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  failedCompileBlock();
              }];
}


/**
 get ERC20 token transaction list
 
 @param address the wallet address
 @param contactAddress contact address
 @param successCompileBlock success
 @param failedCompileBlock failed
 */
- (void)getERC20Tansaction:(NSString *)address
            contactAddress:(NSString *)contactAddress
                   success:(void(^)(NSMutableArray *transList))successCompileBlock
                    failed:(void(^)(void))failedCompileBlock {
    
    NSDictionary *params = @{
                             @"module":@"account",
                             @"action":@"tokentx",
                             @"address":[NSString stringWithFormat:@"0x%@",address],
                             @"contractaddress":contactAddress,
                             @"page":@1,
                             @"offset":@1000,
                             @"sort":@"desc",
                             @"apikey":kEtherscanIOApiKey
                             };
    
    
    [self.session GET:@"https://api.etherscan.io/api"
           parameters:params
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  
                  //
                  NSDictionary *result = responseObject;
                  if ([result[@"status"] integerValue] == 1) {
                      
                      //query success
                      NSMutableArray *transList = [NSMutableArray array];
                      NSArray *translations =  result[@"result"];
                      for (NSDictionary *transactionDict in translations) {
                          TokenTransactionLog *transaction = [[TokenTransactionLog alloc] init];
                          transaction.from = transactionDict[@"from"];
                          transaction.to = transactionDict[@"to"];
                          transaction.tokenName = transactionDict[@"tokenName"];
                          transaction.tokenSymbol = transactionDict[@"tokenSymbol"];
                          transaction.tokenDecimal = [transactionDict[@"tokenDecimal"] integerValue];
                          transaction.value = [transactionDict[@"value"] longLongValue] / pow(10, 18);
                          NSDate *time = [NSDate dateWithTimeIntervalSince1970:[transactionDict[@"timeStamp"] longLongValue]];
                          transaction.time = time;
                          [transList addObject:transaction];
                      }
                      successCompileBlock(transList);
                  } else {
                      failedCompileBlock();
                  }
                  
              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  failedCompileBlock();
              }];
}

- (void) getCurrentETHUSDPrice:(void(^)(double usdPrice))successCompileBlock
                        failed:(void(^)(void))failedCompileBlock {
    
    NSDictionary *params = @{
                             @"module":@"stats",
                             @"action":@"ethprice",
                             @"apikey":kEtherscanIOApiKey
                             };
    
    [self.session GET:@"https://api.etherscan.io/api"
           parameters:params
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  
                  //
                  NSDictionary *result = responseObject;
                  if ([result[@"status"] integerValue] == 1) {
                      
                      //query success
                      NSDictionary *resultDict = result[@"result"];
                      double usdPrice = [resultDict[@"ethusd"] doubleValue];
                      successCompileBlock(usdPrice);
                      
                  } else {
                      
                  }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failedCompileBlock();
    }];
    
}


/**
 get current eth price of RMB
 
 @param successCompileBlock 成功
 @param failedCompileBlock 失败
 */
- (void)getCurrentETHRMBPrice:(void(^)(double rmbPrice))successCompileBlock
                       failed:(void(^)(void))failedCompileBlock {
    
    [self getCurrentETHUSDPrice:^(double usdPrice) {
        
        successCompileBlock(usdPrice * 6.5);
        
    } failed:^{
        failedCompileBlock();
    }];
}


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
             failed:(void(^)(void))failedCompileBlock {
    
    long long int v = value * pow(10, 18);
    NSString *hexValue = [self toHex:v];
    
    NSDictionary *params = @{
                             @"module":@"proxy",
                             @"action":@"eth_estimateGas",
                             @"to":to,
                             @"value":hexValue,
                             @"apikey":kEtherscanIOApiKey
                             };
    
    [self.session GET:@"https://api.etherscan.io/api"
           parameters:params
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  
                  //
                  NSDictionary *result = responseObject;
                  NSString *hex = result[@"result"];
                  if (hex == nil) {
                      failedCompileBlock();
                      return;
                  }
                  successCompileBlock([[hex hexToNumber] integerValue]);
                  
              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  failedCompileBlock();
              }];
}


/**
 send raw transaction info
 
 @param hex
 @param successCompileBlock
 @param failedCompileBlock
 */
- (void)sendRawTransaction:(NSString *)hex
                   success:(void(^)(NSString *))successCompileBlock
                    failed:(void(^)(void))failedCompileBlock {
    
    NSDictionary *params = @{
                             @"module":@"proxy",
                             @"action":@"eth_sendRawTransaction",
                             @"hex":hex,
                             @"apikey":kEtherscanIOApiKey
                             };
    
    [self.session POST:@"https://api.etherscan.io/api"
            parameters:params
              progress:nil
               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                   
                   NSString *hashHex = responseObject[@"result"];
                   successCompileBlock(hashHex);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failedCompileBlock();
    }];
    
}

- (void)getTransactionByHash:(NSString *)txHash {
    
    NSDictionary *params = @{
                             @"module":@"proxy",
                             @"action":@"eth_getTransactionByHash",
                             @"txhash":txHash,
                             @"apikey":kEtherscanIOApiKey
                             };
}


- (NSString *)toHex:(long long int)tmpid
{
    
    NSString *nLetterValue;
    NSString *str = @"";
    long long int ttmpig;
    
    for (int i =0; i<9; i++) {
        ttmpig = tmpid % 16;
        tmpid = tmpid/16;
        
        switch (ttmpig)
        {
            case 10:
                nLetterValue = @"A";
                break;
            case 11:
                nLetterValue = @"B";
                break;
            case 12:
                nLetterValue = @"C";
                break;
            case 13:
                nLetterValue = @"D";
                break;
            case 14:
                nLetterValue = @"E";
                break;
            case 15:
                nLetterValue = @"F";
                break;
            default:nLetterValue = [[NSString alloc] initWithFormat:@"%lli",ttmpig];
        }
        
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
    }
    return str;
    
}

@end
