//
//  NSString+Category.h
//  DEFWallet
//
//

#import <Foundation/Foundation.h>

@interface NSString (Category)

- (BOOL) isEmpty;

- (BOOL) isNotEmpty;

- (NSString *)replaceFirstOfStr:(NSString *)str;

- (NSNumber *)hexToNumber;

@end
