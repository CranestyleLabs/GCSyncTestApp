//
//  GCHelper.m
//  GCSyncTestApp
//
//  Created by Fisher on 4/2/13.
//  Copyright (c) 2013 com.threadbaregames. All rights reserved.
//

#import "GCHelper.h"
#import "AppDelegate.h"

@implementation GCHelper

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] \
compare:v options:NSNumericSearch] == NSOrderedAscending)

@synthesize gameCenterAvailable;
@synthesize presentingViewController;
@synthesize delegate;

#pragma mark Initialization

static GCHelper *sharedHelper = nil;

+(GCHelper *) sharedInstance
{
    if (!sharedHelper)
    {
        sharedHelper = [[GCHelper alloc] init];
    }
    return sharedHelper;
}

- (id)init
{
    if ((self = [super init]))
    {
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable)
        {
            NSNotificationCenter *nc =
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
        }
    }
    return self;
}

-(BOOL)isGameCenterAvailable
{
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

-(void)authenticationChanged
{
    
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated)
    {
        NSLog(@"Authentication changed: player authenticated.");
        userAuthenticated = TRUE;
    }
    else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated)
    {
        NSLog(@"Authentication changed: player not authenticated");
        userAuthenticated = FALSE;
    }
    
}

-(NSDictionary*)lookupPlayers:(GKMatch*)match
{
    
    NSLog(@"Looking up %d players...", match.playerIDs.count);
    __block NSMutableDictionary* playersDict;
    [GKPlayer loadPlayersForIdentifiers:match.playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
        
        if (error != nil)
        {
            NSLog(@"Error retrieving player info: %@", error.localizedDescription);
        }
        else
        {
            // Populate players dict
            playersDict = [NSMutableDictionary dictionaryWithCapacity:players.count];
            for (GKPlayer *player in players)
            {
                NSLog(@"Found player: %@", player.alias);
                [playersDict setObject:player forKey:player.playerID];
            }
        }
    }];
    return playersDict;
}


#pragma mark User functions

- (void)authenticateLocalUser
{
    
    if (!gameCenterAvailable) return;
    
    NSLog(@"Authenticating local user...");
    
    if ([GKLocalPlayer localPlayer].authenticated == NO)
    {
    
        if (SYSTEM_VERSION_LESS_THAN(@"6.0"))
        {
            // ios 5.x and below
            [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error)
             {
                 //[self checkLocalPlayer];
             }];
        }
        else
        {
            // ios 6.0 and above
            [[GKLocalPlayer localPlayer] setAuthenticateHandler:(^(UIViewController* viewcontroller, NSError *error) {
                if (!error && viewcontroller)
                {
                    AppController* appdelegate = (AppController*)[[UIApplication sharedApplication] delegate];
                    [appdelegate.navController presentViewController:viewcontroller animated:YES completion:nil];
                }
                else
                {
    //                [self checkLocalPlayer];
                }
            })];
        }
    
    }
    else
    {
        NSLog(@"Already authenticated!");
    }
    
}

//-(void)findMatchWithMinPlayers:(int)minPlayers
//                     maxPlayers:(int)maxPlayers
//                 viewController:(UIViewController *)viewController
//                       delegate:(id<GCHelperDelegate>)theDelegate
//{
//    
//    if (!gameCenterAvailable)
//    {
//        return;
//    }
//    
//    matchStarted = NO;
//    self.currentMatch = nil;
//    self.presentingViewController = viewController;
//    delegate = theDelegate;
//    [presentingViewController dismissModalViewControllerAnimated:NO];
//    
//    GKMatchRequest *request = [[GKMatchRequest alloc] init];
//    request.minPlayers = minPlayers;
//    request.maxPlayers = maxPlayers;
//    
//    GKMatchmakerViewController *mmvc =
//    [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
//    mmvc.matchmakerDelegate = self;
//    
//    [presentingViewController presentModalViewController:mmvc animated:YES];
//    
//}
//
//#pragma mark GKMatchmakerViewControllerDelegate
//
//// The user has cancelled matchmaking
//- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController*)viewController
//{
//    [presentingViewController dismissModalViewControllerAnimated:YES];
//}
//
//// Matchmaking has failed with an error
//- (void)matchmakerViewController:(GKMatchmakerViewController*)viewController didFailWithError:(NSError*)error
//{
//    [presentingViewController dismissModalViewControllerAnimated:YES];
//    NSLog(@"Error finding match: %@", error.localizedDescription);
//}
//
//// A peer-to-peer match has been found, the game should start
//- (void)matchmakerViewController:(GKMatchmakerViewController*)viewController didFindMatch:(GKMatch*)theMatch
//{
//    [presentingViewController dismissModalViewControllerAnimated:YES];
//    self.currentMatch = theMatch;
//    match.delegate = self;
//    if (!matchStarted && match.expectedPlayerCount == 0)
//    {
//        NSLog(@"Ready to start match!");
//    }
//}
//
//
//#pragma mark GKMatchDelegate
//
//// The match received data sent from the player.
//- (void)match:(GKMatch*)theMatch didReceiveData:(NSData*)data fromPlayer:(NSString*)playerID
//{
//    
//    if (match != theMatch)
//    {
//        return;
//    }
//    
//    [delegate match:theMatch didReceiveData:data fromPlayer:playerID];
//    
//}
//
//// The player state changed (eg. connected or disconnected)
//- (void)match:(GKMatch*)theMatch player:(NSString*)playerID didChangeState:(GKPlayerConnectionState)state
//{
//    
//    if (match != theMatch)
//    {
//        return;
//    }
//    
//    switch (state)
//    {
//            
//        case GKPlayerStateConnected:
//            
//            // handle a new player connection.
//            NSLog(@"Player connected!");
//            
//            if (!matchStarted && theMatch.expectedPlayerCount == 0)
//            {
//                NSLog(@"Ready to start match!");
//            }
//            
//            break;
//            
//            
//        case GKPlayerStateDisconnected:
//            
//            // a player just disconnected.
//            NSLog(@"Player disconnected!");
//            matchStarted = NO;
//            [delegate matchEnded];
//            break;
//    }
//    
//}
//
//// The match was unable to connect with the player due to an error.
//- (void)match:(GKMatch *)theMatch connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error
//{
//    
//    if (match != theMatch)
//    {
//        return;
//    }
//    
//    NSLog(@"Failed to connect to player with error: %@", error.localizedDescription);
//    matchStarted = NO;
//    
//    [delegate matchEnded];
//    
//}
//
//// The match was unable to be established with any players due to an error.
//- (void)match:(GKMatch*)theMatch didFailWithError:(NSError*)error
//{
//    
//    if (match != theMatch)
//    {
//        return;
//    }
//    
//    NSLog(@"Match failed with error: %@", error.localizedDescription);
//    matchStarted = NO;
//    
//    [delegate matchEnded];
//    
//}

@end
