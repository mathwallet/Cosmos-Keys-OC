//
//  CosmosKeyPairTests.m
//  BlockchainkeysTests
//
//  Created by Yuzhiyou on 2019/4/30.
//  Copyright © 2019 Yuzhiyou. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CoinFamily.h"
#import "Categories.h"

@interface CosmosKeyPairTests : XCTestCase

@end

@implementation CosmosKeyPairTests

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
    CosmosDeterministicKey *rootKey = [[CosmosDeterministicKey alloc] initWithSeed:seed];
    NSMutableArray *path = [NSMutableArray new];
    [path addObject:[[ChildNumber alloc] initWithPath:44 Hardened:YES]];
    [path addObject:[[ChildNumber alloc] initWithPath:118 Hardened:YES]];
    [path addObject:[[ChildNumber alloc] initWithPath:0 Hardened:YES]];
    [path addObject:[[ChildNumber alloc] initWithPath:0 Hardened:NO]];
    [path addObject:[[ChildNumber alloc] initWithPath:0 Hardened:NO]];
    CosmosECKey *ecKey = [[rootKey Derive:path] toECKey];
    
    NSLog(@"Private Key[%@]",ecKey.privateKeyAsHex);
    NSLog(@"Public Key[%@]",ecKey.publicKeyAsHex);
    NSLog(@"Address[%@]",[[CosmosAddress alloc] initWithData:ecKey.publicKeyAsData]);
    NSLog(@"Base64 PublicKey[%@]",[[NSString alloc] initWithData:ecKey.publicKeyAsData.base64 encoding:NSUTF8StringEncoding]);
}
- (void)testImportByPrivateKey{
    // cosmos15ykw98m67m75cmzy43ywgkvptar5ap5gxt25q6
    CosmosECKey *ecKey = [[CosmosECKey alloc] initWithPriKey:[@"be2e5882e64eca3680c06aef13498de1794ea50106144f7e9f7824046b94b39f" hexToData]];
    
    NSLog(@"privateKey[%@]",ecKey.privateKeyAsHex);
    NSLog(@"address[%@]",[[CosmosAddress alloc] initWithData:ecKey.publicKeyAsData]);
}
-(void)testValidAddress{
    NSString *testAddress1 = @"cosmos15ykw98m67m75cmzy43ywgkvptar5ap5gxt25q6";
    XCTAssertTrue([CosmosAddress validAddress:testAddress1]);
    NSString *testAddress2 = @"cosmos15ykw98m67m75cmzy43ywgkvptar5ap5gxt25q5";
    XCTAssertTrue([CosmosAddress validAddress:testAddress2]);
}
-(void)testSign{
    // cosmos15ykw98m67m75cmzy43ywgkvptar5ap5gxt25q6
    CosmosECKey *ecKey = [[CosmosECKey alloc] initWithPriKey:[@"be2e5882e64eca3680c06aef13498de1794ea50106144f7e9f7824046b94b39f" hexToData]];
    NSLog(@"publicKey[%@]",ecKey.publicKeyAsHex);
    NSLog(@"address[%@]",[[CosmosAddress alloc] initWithData:ecKey.publicKeyAsData]);
    NSLog(@"base64 publicKey[%@]",[[NSString alloc] initWithData:ecKey.publicKeyAsData.base64 encoding:NSUTF8StringEncoding]);
    NSString *message = @"test";
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding].SHA256;
    //sign = 68fe2bc31119f03c2011155c6b338fd6d2c56fb7aa95978dec9811fdc91079fc640778f2c2232fcdcdc7882335a45b5e05ddf056e204040522f8f7af092da99a
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
