//
//  NSString+Category.m
//  DEFWallet
//
//

#import "NSString+Category.h"

@implementation NSString (Category)

- (BOOL) isEmpty {
    return self == nil || [self isEqualToString:@""];
}

- (BOOL) isNotEmpty {
    return self != nil && ![self isEqualToString:@""];
}

- (NSString *)replaceFirstOfStr:(NSString *)str {
    
    NSRange range = [self rangeOfString:str];
    if (range.location == NSNotFound) {
        return self;
    }
    
    return [self stringByReplacingCharactersInRange:range withString:@""];
}

- (NSNumber *)hexToNumber {
    
    if([self isEmpty]) {
        return nil;
    }
    
    NSScanner * scanner = [NSScanner scannerWithString:self];
    unsigned long long longlongValue;
    [scanner scanHexLongLong:&longlongValue];
    
    NSNumber * hexNumber = [NSNumber numberWithLongLong:longlongValue];
    return hexNumber;
}

@end
