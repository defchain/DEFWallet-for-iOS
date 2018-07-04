//
//  WalletListViewCell.m
//  DEFWallet
//
//

#import "WalletListViewCell.h"

@interface WalletListViewCell()

@property(nonatomic, strong) UITapGestureRecognizer *recognizer;

@end

@implementation WalletListViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.containerView.layer.cornerRadius = 5.0;
    self.containerView.layer.masksToBounds = YES;
    
    self.recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapColorView)];
    [self.colorView addGestureRecognizer:self.recognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)onTapColorView {
    if (self.delegate) {
        [self.delegate onClickWalletCell:self];
    }
}

@end
