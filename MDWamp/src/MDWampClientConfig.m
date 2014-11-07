//
//  MDWampClientConfig.m
//  MDWamp
//
//  Created by Niko Usai on 09/10/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampClientConfig.h"

#pragma Constants

NSString * const kMDWampRolePublisher   = @"publisher";
NSString * const kMDWampRoleSubscriber  = @"subscriber";
NSString * const kMDWampRoleCaller      = @"caller";
NSString * const kMDWampRoleCallee      = @"callee";
NSString * const kMDWampAuthMethodCRA   = @"wampcra";
NSString * const kMDWampAuthMethodTicket      = @"ticket";

@interface MDWampClientConfig()

@end

@implementation MDWampClientConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        self.authmethods = @[kMDWampAuthMethodCRA];
        self.roles = @{
          kMDWampRolePublisher : @{
                  @"subscriber_blackwhite_listing": @YES,
                  @"publisher_exclusion":           @YES,
                  @"publisher_identification":      @YES
                  },
          kMDWampRoleSubscriber : @{
                  @"publication_trustlevels":       @YES,
                  @"pattern_based_subscription":    @YES
                  },
          kMDWampRoleCaller : @{},
          kMDWampRoleCallee : @{}
        };
        self.publisher_acknowledge = NO;
        self.publisher_exclude_me = YES;
        self.publisher_identification = NO;
    }
    return self;
}

- (NSDictionary *)getHelloDetails {
    NSMutableDictionary* d = [NSMutableDictionary dictionaryWithDictionary:@{ @"roles" : self.roles, @"authmetods" : self.authmethods }];
    
    if (self.agent) {
        d[@"agent"] = self.agent;
    }
    
    if (self.authid) {
        d[@"authid"] = self.authid;
    }
    
    // Integrity checks
    if ([self.authmethods containsObject:kMDWampAuthMethodCRA] && (!self.authid || !self.sharedSecret) ) {
        // if wampcra MUST be provided authid
#ifdef DEBUG
        [NSException raise:@"it.mogui.mdwamp" format:@"Inconsistent MDWampClientConfig with wampcra an authid and sharedSecred must be provided"];
#else
        MDWampDebugLog(@"Inconsistent MDWampClientConfig with wampcra an authid must be provided");
#endif
    }
    
    if ([self.authmethods containsObject:kMDWampAuthMethodTicket] && (!self.authid || !self.ticket) ) {
        // if wampcra MUST be provided authid
#ifdef DEBUG
        [NSException raise:@"it.mogui.mdwamp" format:@"Inconsistent MDWampClientConfig with ticket based auth an authid and ticket must be provided"];
#else
        MDWampDebugLog(@"Inconsistent MDWampClientConfig with ticket based auth an authid and ticket must be provided");
#endif
    }
    
    return [NSDictionary dictionaryWithDictionary:d];
}

@end
