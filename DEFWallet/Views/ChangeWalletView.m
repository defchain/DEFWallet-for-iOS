//
//  ChangeWalletView.m
//  DEFWallet
//
//  Created by 成岗 on 2018/7/2.
//

#import "ChangeWalletView.h"

#import <vector>
#import "../../external/defwallet/def_wallet_manager.h"
#import "../../external/defwallet/def_wallet.h"

@interface ChangeWalletView()<UITableViewDelegate,UITableViewDataSource>
    
@end

@implementation ChangeWalletView


- (void)awakeFromNib {
    [super awakeFromNib];
    
}
    
#pragma -
#pragma mark UITableViewDataSource && UITableViewDelegate
    

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
    
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
    
@end
