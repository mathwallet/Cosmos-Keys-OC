//
//  CosmosAddress.m
//  BlockchainKeys
//
//  Created by Yuzhiyou on 2019/4/30.
//  Copyright © 2019 Yuzhiyou. All rights reserved.
//

#import "CosmosAddress.h"
#import "NSData+Hash.h"
#import "NSData+Extend.h"
#import "NSString+Base58.h"

#import "segwit_addr.h"

static NSString *COSMOS_PREFIX = @"cosmos";
static NSString *COSMOS_VALIDATOR_PREFIX = @"cosmosvaloper";
static NSString *COSMOS_PUB_PREFIX = @"cosmospub";

@implementation CosmosAddress

/**
 * @brief Initialization method
 */
- (instancetype)initWithData:(NSData *)publicKeyData{
    self = [super init];
    if (self) {
        _publicKeyData = publicKeyData;
        _address = [self encodeAddress:_publicKeyData];
    }
    return self;
}
- (NSString*)encodeAddress:(NSData *)publicKeyData {
    NSData *hash = publicKeyData.hash160;
    NSMutableData *result = [[NSMutableData alloc] initWithCapacity:89];
    default_addr_encode(result.mutableBytes,COSMOS_PREFIX.UTF8String,hash.bytes,hash.length);
    return [NSString stringWithUTF8String:result.bytes];
}
+ (NSString *)decodeAddress:(NSString *)address prefix:(NSString *)prefix{
    uint8_t data[40];
    size_t data_len = 0;
    int result = default_addr_decode(data, &data_len, prefix.UTF8String, address.UTF8String);
    return (result == 1) ? [NSData dataWithBytes:data length:data_len].hexString : nil;
}
- (NSString*)description {
    return _address;
}


/**
 Valid Address
 
 @return YES/NO
 */
+(BOOL)validAddress:(NSString *)address{
    return [CosmosAddress decodeAddress:address prefix:COSMOS_PREFIX]?YES:NO;
}
+(BOOL)validValidatorAddress:(NSString *)address{
    return [CosmosAddress decodeAddress:address prefix:COSMOS_VALIDATOR_PREFIX]?YES:NO;
}
+(BOOL)validPubAddress:(NSString *)address{
    return [CosmosAddress decodeAddress:address prefix:COSMOS_PUB_PREFIX]?YES:NO;
}
@end
