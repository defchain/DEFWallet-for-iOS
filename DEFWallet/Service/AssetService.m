//
//  AssetService.m
//  DEFWallet
//
//  Created by 成岗 on 2018/6/14.
//

#import "AssetService.h"

@implementation AssetService


static AssetService *share_instance = nil;

/**
 Share instance
 */
+ (AssetService *)shareInstance {
    
    if(share_instance == nil){
        share_instance = [[AssetService alloc] init];
    }
    return share_instance;
}

/**
 Query assets of wallet
 @param address address
 */
- (NSDictionary *)getWalletAssets:(NSString *)address {
    
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *storePath = [documentPath stringByAppendingString:@"/assets"];
    
    BOOL isDir;
    if(![[NSFileManager defaultManager] fileExistsAtPath:storePath isDirectory:&isDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:storePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *filePath = [storePath stringByAppendingFormat:@"/%@.plist",address];
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir]) {
        
        //write config to local file
        NSDictionary *walletAssets = @{@"eth":@"",@"def":@"0x70e29c7124585a20ede4e78b615d3a3b2b4dad5c"};
        [walletAssets writeToFile:filePath atomically:YES];
        return walletAssets;
    }
    
    return [NSDictionary dictionaryWithContentsOfFile:filePath];
}

@end
