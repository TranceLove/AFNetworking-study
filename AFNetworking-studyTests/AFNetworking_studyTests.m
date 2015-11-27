//
//  AFNetworking_studyTests.m
//  AFNetworking-studyTests
//
//  Created by Raymond Lai on 24/11/2015.
//  Copyright © 2015 Raymond Lai. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AFHTTPSessionManager.h"
#import "AFURLRequestSerialization.h"
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

- (void)testRequestTimeout {
    XCTestExpectation *expect = [self expectationWithDescription:@"Test expectations"];
    //Response serializer is required or task will fail with unacceptable content type text/html
    self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.manager.requestSerializer setTimeoutInterval:5];
    [self.manager GET:@"/delay/10"
           parameters:nil
              success:^(NSURLSessionDataTask *task, NSDictionary *response){
                  XCTAssertNil(response);
              }
              failure:^(NSURLSessionDataTask *task, NSError *error){
                  NSLog(@"%@", error.localizedDescription);
                  XCTAssertNotNil(error);
                  [expect fulfill];
              }
     ];
    
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error){
        if(error)
            NSLog(@"Timed out with error: %@", error);
    }];
}

- (void)testSlowCall {
    XCTestExpectation *expect = [self expectationWithDescription:@"Test expectations"];
    //Response serializer is required or task will fail with unacceptable content type text/html
    self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.manager.requestSerializer setTimeoutInterval:10];
    [self.manager GET:@"/delay/5"
           parameters:nil
              success:^(NSURLSessionDataTask *task, NSDictionary *response){
                  XCTAssertNotNil(response);
                  [expect fulfill];
              }
              failure:^(NSURLSessionDataTask *task, NSError *error){
                  NSLog(@"%@", error.localizedDescription);
                  XCTAssertNil(error);
              }
     ];
    
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error){
        if(error)
            NSLog(@"Timed out with error: %@", error);
    }];
}

- (void)testCancelCall {
    XCTestExpectation *expect = [self expectationWithDescription:@"Test expectations"];
    //Response serializer is required or task will fail with unacceptable content type text/html
    self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [self.manager.requestSerializer setTimeoutInterval:10];
    NSURLSessionDataTask *task = [self.manager GET:@"/delay/5"
           parameters:nil
              success:^(NSURLSessionDataTask *task, NSDictionary *response){
                  XCTAssertNotNil(response);
            }
              failure:^(NSURLSessionDataTask *task, NSError *error){
                  NSLog(@"%@", error.localizedDescription);
                  XCTAssertNil(error);
              }
     ];
    
    [task resume];
    [task cancel];
    
    XCTAssertEqual(task.state, NSURLSessionTaskStateCanceling);
    XCTAssertNotEqual(task.state, NSURLSessionTaskStateCompleted);
    [expect fulfill];
        
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error){
        if(error)
            NSLog(@"Timed out with error: %@", error);
    }];
}

- (void)testEnsureAsyncness {
    XCTestExpectation *expect = [self expectationWithDescription:@"Test expectations"];
    //Response serializer is required or task will fail with unacceptable content type text/html
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:2];
    self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.manager.requestSerializer setTimeoutInterval:10];
    [self.manager GET:@"/delay/5"
           parameters:nil
              success:^(NSURLSessionDataTask *task, NSDictionary *response){
                  XCTAssertNotNil(response);
                  [results addObject:[NSNumber numberWithInt:2]];
                  [expect fulfill];
              }
              failure:^(NSURLSessionDataTask *task, NSError *error){
                  NSLog(@"%@", error.localizedDescription);
                  XCTAssertNil(error);
              }
     ];
    
    [results addObject:[NSNumber numberWithInt:1]];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error){
        if(error)
            NSLog(@"Timed out with error: %@", error);
    }];
    
    XCTAssertEqualObjects([results objectAtIndex:0], [NSNumber numberWithInt:1]);
    XCTAssertEqualObjects([results objectAtIndex:1], [NSNumber numberWithInt:2]);
}

- (void)testPostForm {
    XCTestExpectation *expect = [self expectationWithDescription:@"Test expectations"];
    //Response serializer is required or task will fail with unacceptable content type text/html
    self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    NSURLSessionDataTask *task = [self.manager POST:@"/post"
                                         parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"bar", @"foo", nil]
                                            success:^(NSURLSessionDataTask *task, NSDictionary *response){
                                                XCTAssertNotNil(response);
                                                XCTAssertNotNil([response objectForKey:@"form"]);
                                                NSDictionary *formData = [response objectForKey:@"form"];
                                                XCTAssertEqualObjects([formData objectForKey:@"foo"], @"bar");
                                                NSDictionary *headers = [response objectForKey:@"headers"];
                                                XCTAssertEqualObjects([headers objectForKey:@"Content-Type"], @"application/x-www-form-urlencoded");
                                                [expect fulfill];
                                            }
                                            failure:^(NSURLSessionDataTask *task, NSError *error){
                                                NSLog(@"%@", error.localizedDescription);
                                                XCTAssertNil(error);
                                            }
                                  ];
    
    [task resume];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error){
        if(error)
            NSLog(@"Timed out with error: %@", error);
    }];
}

@end
