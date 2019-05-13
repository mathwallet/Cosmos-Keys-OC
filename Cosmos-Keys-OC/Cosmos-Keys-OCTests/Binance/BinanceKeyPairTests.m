//
//  BinanceKeyPairTests.m
//  BlockchainkeysTests
//
//  Created by Yuzhiyou on 2019/4/30.
//  Copyright © 2019 Yuzhiyou. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CoinFamily.h"
#import "Categories.h"

@interface BinanceKeyPairTests : XCTestCase

@end

@implementation BinanceKeyPairTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testCreateNewWallet {
    // Random
    NSData *randomData = [NSData randomWithSize:16];
    if (!randomData) { return; }
    // Mnemonic
    MnemonicCode *mnemonicCode  = [MnemonicCode shareInstance];
    NSString *mnemonicText = [mnemonicCode toMnemonic:randomData];
    NSLog(@"Mnemonic[%@]",mnemonicText);
    
    NSData *seed = [mnemonicCode toSeed:[mnemonicCode toMnemonicArray:randomData] withPassphrase:@""];
    // Path（44'/714'/0'/0/0）
    BinanceDeterministicKey *rootKey = [[BinanceDeterministicKey alloc] initWithSeed:seed];
    NSMutableArray *path = [NSMutableArray new];
    [path addObject:[[ChildNumber alloc] initWithPath:44 Hardened:YES]];
    [path addObject:[[ChildNumber alloc] initWithPath:714 Hardened:YES]];
    [path addObject:[[ChildNumber alloc] initWithPath:0 Hardened:YES]];
    [path addObject:[[ChildNumber alloc] initWithPath:0 Hardened:NO]];
    [path addObject:[[ChildNumber alloc] initWithPath:0 Hardened:NO]];
    BinanceECKey *ecKey = [[rootKey Derive:path] toECKey];
    
    NSLog(@"privateKey[%@]",ecKey.privateKeyAsHex);
    NSLog(@"publicKey[%@]",ecKey.publicKeyAsHex);
    NSLog(@"base64 publicKey[%@]",[[NSString alloc] initWithData:ecKey.publicKeyAsData.base64 encoding:NSUTF8StringEncoding]);
    NSLog(@"address[%@]",[[BinanceAddress alloc] initWithData:ecKey.publicKeyAsData]);
}
- (void)testImportByPrivateKey{
    // bnb1ea0rwlud34y0nf2kc0vcgmjr92he052jay6u4y
    BinanceECKey *ecKey = [[BinanceECKey alloc] initWithPriKey:[@"011a5a8261b275a9e06b57a259fb0cda81ed7c83c417bf99e91c6942fc625d8a" hexToData]];
    
    NSLog(@"privateKey[%@]",ecKey.privateKeyAsHex);
    NSLog(@"uncompressed pubkey[%@]",ecKey.uncompressedPubKey.hexString);
    NSLog(@"address[%@]",[[BinanceAddress alloc] initWithData:ecKey.publicKeyAsData]);
}
-(void)testValidAddress{
    NSString *testAddress1 = @"bnb1ea0rwlud34y0nf2kc0vcgmjr92he052jay6u4y";
    XCTAssertTrue([BinanceAddress validAddress:testAddress1]);
    NSString *testAddress2 = @"bnb1ea0rwlud34y0nf2kc0vcgmjr92he052jay6u4k";
    XCTAssertTrue([BinanceAddress validAddress:testAddress2]);
}
-(void)testSign{
    BinanceECKey *ecKey = [[BinanceECKey alloc] initWithPriKey:[@"011a5a8261b275a9e06b57a259fb0cda81ed7c83c417bf99e91c6942fc625d8a" hexToData]];
    NSLog(@"address[%@]",[[BinanceAddress alloc] initWithData:ecKey.publicKeyAsData]);
    NSLog(@"base64 publicKey[%@]",[[NSString alloc] initWithData:ecKey.publicKeyAsData.base64 encoding:NSUTF8StringEncoding]);
    NSString *message = @"test";
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding].SHA256;
    
    //sign = 6e0a7c4f8ce88c694b5ef79f1017cb2c0b5092232402b19651540ceefa43849836c621c1fc7a9e4c9ee534350560706d20db48daba4449c2835f6266d4ebcb49
    ECKeySignature *signature = [ecKey sign:data];
    
    NSLog(@"Sign->%@",signature.toDataNoV.hexString);
    NSLog(@"Sign base64->%@",[[NSString alloc] initWithData:signature.toDataNoV.base64 encoding:NSUTF8StringEncoding]);
}
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
