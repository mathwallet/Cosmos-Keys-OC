//
//  IRISKeyPairTests.m
//  BlockchainkeysTests
//
//  Created by Yuzhiyou on 2019/4/30.
//  Copyright © 2019 Yuzhiyou. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CoinFamily.h"
#import "Categories.h"

@interface IRISKeyPairTests : XCTestCase

@end

@implementation IRISKeyPairTests

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
    // Path（44'/118'/0'/0/0）
    IRISDeterministicKey *rootKey = [[IRISDeterministicKey alloc] initWithSeed:seed];
    NSMutableArray *path = [NSMutableArray new];
    [path addObject:[[ChildNumber alloc] initWithPath:44 Hardened:YES]];
    [path addObject:[[ChildNumber alloc] initWithPath:118 Hardened:YES]];
    [path addObject:[[ChildNumber alloc] initWithPath:0 Hardened:YES]];
    [path addObject:[[ChildNumber alloc] initWithPath:0 Hardened:NO]];
    [path addObject:[[ChildNumber alloc] initWithPath:0 Hardened:NO]];
    IRISECKey *ecKey = [[rootKey Derive:path] toECKey];
    
    NSLog(@"privateKey[%@]",ecKey.privateKeyAsHex);
    NSLog(@"publicKey[%@]",ecKey.publicKeyAsHex);
    NSLog(@"address[%@]",[[IRISAddress alloc] initWithData:ecKey.publicKeyAsData]);
    NSLog(@"address[%@]",[[NSString alloc] initWithData:ecKey.publicKeyAsData.base64 encoding:NSUTF8StringEncoding]);
}
- (void)testImportByPrivateKey{
    // iaa1zhtku7t0szlqy9mrwxfyhynt7a5ehgsfmn7qh2
    IRISECKey *ecKey = [[IRISECKey alloc] initWithPriKey:[@"5c2afe173cd1d24f9bc8275b43bfcd611fdb1708ff1f194f73ff0b7822d2c96e" hexToData]];
    
    NSLog(@"privateKey[%@]",ecKey.privateKeyAsHex);
    NSLog(@"address[%@]",[[IRISAddress alloc] initWithData:ecKey.publicKeyAsData]);
}
-(void)testValidAddress{
    NSString *testAddress1 = @"iaa1zhtku7t0szlqy9mrwxfyhynt7a5ehgsfmn7qh2";
    XCTAssertTrue([IRISAddress validAddress:testAddress1]);
    NSString *testAddress2 = @"iaa1zhtku7t0szlqy9mrwxfyhynt7a5ehgsfmn7qh1";
    XCTAssertTrue([IRISAddress validAddress:testAddress2]);
}
-(void)testSign{
    // iaa1zhtku7t0szlqy9mrwxfyhynt7a5ehgsfmn7qh2
    IRISECKey *ecKey = [[IRISECKey alloc] initWithPriKey:[@"5c2afe173cd1d24f9bc8275b43bfcd611fdb1708ff1f194f73ff0b7822d2c96e" hexToData]];
    NSLog(@"address[%@]",[[IRISAddress alloc] initWithData:ecKey.publicKeyAsData]);
    NSLog(@"base64 publicKey[%@]",[[NSString alloc] initWithData:ecKey.publicKeyAsData.base64 encoding:NSUTF8StringEncoding]);
    NSString *message = @"test";
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding].SHA256;
    
    NSLog(@"data->%@",data.hexString);
    //sign = 13b31bc3ea109448ab1b10867ca88b34a6bb26d6441dd224c3582ae8c71f00c1445df00fa91868389d1f534b0f825cb3c960a2de71b0adb2f64e4d2071ff4983
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
