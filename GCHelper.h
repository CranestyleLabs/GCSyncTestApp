//
//  GCHelper.h
//  GCSyncTestApp
//
//  Created by Fisher on 4/2/13.
//  Copyright (c) 2013 com.threadbaregames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol GCHelperDelegate
- (void)matchStarted;
- (void)matchEnded;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data
   fromPlayer:(NSString *)playerID;
@end

@interface GCHelper : NSObject
{
    UIViewController* presentingViewController;
//    GKMatch* match;
    BOOL matchStarted;
    id <GCHelperDelegate> delegate;
    
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
}

@property (assign, readonly) BOOL gameCenterAvailable;
@property UIViewController* presentingViewController;
@property GKMatch* currentMatch;
@property id <GCHelperDelegate> delegate;

+(GCHelper *)sharedInstance;
-(void)authenticateLocalUser;
    
//-(void)findMatchWithMinPlayers:(int)minPlayers
//                    maxPlayers:(int)maxPlayers
//                viewController:(UIViewController *)viewController
//                      delegate:(id<GCHelperDelegate>)theDelegate;

@end
