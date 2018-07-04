//
//  OSSSyncMutableDictionary.h
//  DEFWallet
//
//

#import <Foundation/Foundation.h>

/**
Dictionary with safe thread
 */
@interface OSSSyncMutableDictionary : NSObject
@property (nonatomic, strong) NSMutableDictionary *dictionary;
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

- (id)objectForKey:(id)aKey;
- (NSArray *)allKeys;
- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey;
- (void)removeObjectForKey:(id)aKey;
@end
