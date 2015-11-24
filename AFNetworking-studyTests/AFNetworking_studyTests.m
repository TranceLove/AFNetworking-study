//
//  AFNetworking_studyTests.m
//  AFNetworking-studyTests
//
//  Created by Raymond Lai on 24/11/2015.
//  Copyright © 2015 Raymond Lai. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AFHTTPSessionManager.h"
#import "AFURLResponseSerialization.h"

@interface AFNetworking_studyTests : XCTestCase
@property (readwrite,nonatomic,strong) AFHTTPSessionManager *manager;
@end

NSString *urlPrefix = @"http://httpbin.org";

@implementation AFNetworking_studyTests

- (void)setUp {
    [super setUp];
    self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://httpbin.org"]];
}

- (void)tearDown {
    [super tearDown];
    self.manager = nil;
}

- (void)testSimpleGet {
    XCTestExpectation *expect = [self expectationWithDescription:@"Test expectations"];
    //Response serializer is required or task will fail with unacceptable content type text/html
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSURLSessionDataTask *task = [self.manager GET:@"/"
           parameters:nil
              success:^(NSURLSessionDataTask *task, id responseObject){
                  XCTAssertTrue(YES);
                  NSData *responseData = responseObject;
                  NSString *response = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
                  XCTAssertNotNil(response);
                  [expect fulfill];
              }
            failure:^(NSURLSessionDataTask *task, NSError *error){
                NSLog(@"%@", error.localizedDescription);
                XCTAssertNil(error);
            }];
    
    [task resume];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error){
        if(error)
            NSLog(@"Timed out with error: %@", error);
    }];
}

- (void)testSimpleGetJson {
    XCTestExpectation *expect = [self expectationWithDescription:@"Test expectations"];
    //Response serializer is required or task will fail with unacceptable content type text/html
    self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
   [self.manager GET:@"/get"
          parameters:nil
             success:^(NSURLSessionDataTask *task, NSDictionary *response){
                XCTAssertNotNil(response);
                XCTAssertEqualObjects([response objectForKey:@"url"], @"http://httpbin.org/get");
                [expect fulfill];
             }
             failure:^(NSURLSessionDataTask *task, NSError *error){
                 NSLog(@"%@", error.localizedDescription);
                 XCTAssertNil(error);
             }
    ];
    

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error){
        if(error)
            NSLog(@"Timed out with error: %@", error);
    }];
}


@end
