//
//  Lobby.m
//  GCSyncTestApp
//
//  Created by Fisher on 4/1/13.
//  Copyright (c) 2013 com.threadbaregames. All rights reserved.
//

#import "Lobby.h"
#import "Game.h"
#import "GameMessage.h"
#import "PlayerMenuItem.h"

#import <GameKit/GameKit.h>

static Lobby* sharedInstance;

@implementation Lobby

+(CCScene*)scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	Lobby *layer = [Lobby node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

+(Lobby*)sharedLobby
{
    if (!sharedInstance)
    {
        return [[Lobby alloc] init];
    }
    return sharedInstance;
}

-(id)init
{
    if (self = [super init])
    {
        sharedInstance = self;
        winSize = [[CCDirector sharedDirector] winSize];
        
        activeGames = [[NSMutableDictionary alloc] init];
        
        [self setupNewGameButton];
        
        activeGamesMenuLayer = [[CCLayerColor alloc] initWithColor:ccc4(255, 255, 255, 50)];
        [activeGamesMenuLayer setAnchorPoint:ccp(0,1)];
        [activeGamesMenuLayer setContentSize:CGSizeMake(winSize.width, winSize.height * 0.75)];
        [activeGamesMenuLayer setPosition:ccp(0, winSize.height - activeGamesMenuLayer.contentSize.height)];
        [self addChild:activeGamesMenuLayer z:0];
        
        delegate = (AppController*)[[UIApplication sharedApplication] delegate];
        presentingViewController = delegate.navController;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLaunchGame:) name:LAUNCH_GAME object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCancelGame:) name:CANCEL_GAME object:nil];
        
    }
    return self;
}

-(void)setupNewGameButton
{
    CCMenuItemFont* buttonNewGame = [CCMenuItemFont itemWithString:@"New Game" target:self selector:@selector(clickedNewGameButton)];
    CCMenu* menu = [CCMenu menuWithItems:buttonNewGame, nil];
    [menu setPosition:ccp(winSize.width/2, 150)];
    [self addChild:menu];
}

-(void)clickedNewGameButton
{
    newGame = nil;
    newGame = [[Game alloc] init];
    [newGame setGameId:arc4random()];
    [self findMatchWithMinPlayers:2 maxPlayers:3 viewController:delegate.navController];
}

-(void)refreshActiveGamesList
{
    [activeGamesMenuLayer removeAllChildrenWithCleanup:YES];
    int i = 0;
    for (NSNumber* key in activeGames)
    {
        Game* game = (Game*)[activeGames objectForKey:key];
        GameMenuItem* gameMenuItem = [[GameMenuItem alloc] initWithGame:game];
        [gameMenuItem setAnchorPoint:ccp(0,1)];
        [gameMenuItem setPosition:ccp(1, (activeGamesMenuLayer.contentSize.height - 1) - ((gameMenuItem.contentSize.height + 8) * i++) )];
        [activeGamesMenuLayer addChild:gameMenuItem];
    }
}

-(void)onEnter
{
    [super onEnter];
}

-(void)onExit
{
    [super onExit];
}

-(void)receiveLaunchGame:(NSNotification*)notification
{
    GameMenuItem* gameMenuItem = (GameMenuItem*)notification.object;
    [[CCDirectorIOS sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:1.0 scene:[ [gameMenuItem getGameObject] scene] ]];
}

-(void)receiveCancelGame:(NSNotification*)notification
{
    GameMenuItem* gameMenuItem = (GameMenuItem*)notification.object;
    CCLOG(@"Game %d cancelled by user", [[gameMenuItem getGameObject] getGameId]);
    for (NSNumber* key in activeGames)
    {
        if ([key intValue] == [[gameMenuItem getGameObject] getGameId])
        {
            CCLOG(@"sending cancellation message.");
            NSError* error;
            Game* gameToRemove = [activeGames objectForKey:key];
            GameMessage* cancelMessage = [[GameMessage alloc] initWithGameId:[key intValue] andType:GAME_MESSAGE_QUIT];
            [gameToRemove.match sendDataToAllPlayers:[self archiveMessage:cancelMessage] withDataMode:GKSendDataReliable error:&error];
            [self removeGame:gameToRemove];
        }
    }
}



-(void)sendDataToAllPlayers:(NSData *)data forGame:(Game*)game
{
    NSError *error;
    BOOL success = [game.match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
    if (!success)
    {
        CCLOG(@"Error sending init packet");
        [self matchEnded];
    }
}


#pragma mark Matchmaking
-(void)findMatchWithMinPlayers:(int)minPlayers
                    maxPlayers:(int)maxPlayers
                viewController:(UIViewController *)viewController
{
    
    if (![[GCHelper sharedInstance] gameCenterAvailable])
    {
        return;
    }
    
//    matchStarted = NO;
    presentingViewController = viewController;
    [presentingViewController dismissModalViewControllerAnimated:NO];
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = minPlayers;
    request.maxPlayers = maxPlayers;
    
    GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
    mmvc.matchmakerDelegate = self;
    
    [presentingViewController presentModalViewController:mmvc animated:YES];
    
}

- (void)matchStarted
{
    CCLOG(@"Match started");
}

- (void)matchEnded
{
    CCLOG(@"Match ended");
}




#pragma mark -- GKMatchmakerViewControllerDelegate

// The user has cancelled matchmaking
// A peer-to-peer match has been found, the game should start
- (void)matchmakerViewController:(GKMatchmakerViewController*)viewController didFindMatch:(GKMatch*)theMatch
{
    CCLOG(@"matchmaker view controller did find match.");
    [presentingViewController dismissModalViewControllerAnimated:YES];
    newGame.match = theMatch;
    [newGame addPlayersForIDSync:newGame.match.playerIDs];
    newGame.match.delegate = self;
    CCLOG(@"expected player count: %d", newGame.match.expectedPlayerCount);
    if (newGame.match.expectedPlayerCount == 0)
    {
        NSLog(@"Ready to start match!");
        
//        [self lookupPlayersForGame:newGame];
        
        NSLog(@"Sending gameid...");
        NSError* error;
        GameMessage* gameMessage = [[GameMessage alloc] initWithGameId:[newGame getGameId] andType:GAME_MESSAGE_SYNC_GAMEID];
        NSData* data = [self archiveMessage:gameMessage];
        [newGame.match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
    }
}
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController*)viewController
{
    [presentingViewController dismissModalViewControllerAnimated:YES];
    NSLog(@"Matchmaking cancelled by user.");
}

// Matchmaking has failed with an error
- (void)matchmakerViewController:(GKMatchmakerViewController*)viewController didFailWithError:(NSError*)error
{
    [presentingViewController dismissModalViewControllerAnimated:YES];
    NSLog(@"Error finding match: %@", error.localizedDescription);
}


- (void)lookupPlayersForGame:(Game*)game
{

    NSLog(@"Looking up %d players...", game.match.playerIDs.count);
    [GKPlayer loadPlayersForIdentifiers:game.match.playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
        
        if (error != nil)
        {
            NSLog(@"Error retrieving player info: %@", error.localizedDescription);
//            matchStarted = NO;
            [self matchEnded];
        }
        else
        {
            
            // Populate players dict
            for (GKPlayer *player in players)
            {
                NSLog(@"Found player: %@ [%@]", player.alias, player.playerID);
                [game addPlayer:player withId:player.playerID];
            }
            
            // Notify delegate match can begin
//            matchStarted = YES;
            [self matchStarted];
            
        }
    }];
    
}


#pragma mark -- GKMatchDelegate

// The match received data sent from the player.
-(void)match:(GKMatch*)theMatch didReceiveData:(NSData*)data fromPlayer:(NSString*)playerID
{
    
    CCLOG(@"Received data");
    NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    GameMessage* gameMessage = (GameMessage*)[unarchiver decodeObjectForKey:@"GAME_MESSAGE"];
    
//    GameMessage* gameMessage = (GameMessage*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    CCLOG(@"My gameId:         %d", [newGame getGameId] );
    CCLOG(@"Game id received:  %d", gameMessage.gameId);
    CCLOG(@"Game messgae type: %d", gameMessage.type);
    
//    GameMessage* gameMessage = (GameMessage*)[data bytes];
    
    if (gameMessage.type == GAME_MESSAGE_SYNC_GAMEID)
    {
        CCLOG(@"1");
        [newGame receiveGameIdSyncMessageFromPlayerId:playerID withGameId:gameMessage.gameId];
        if (newGame.state == GAMESTATE_READY_TO_BEGIN)
        {
            CCLOG(@"2");
            CCLOG(@"Game ID -  NSNumber: %@", [NSNumber numberWithInt:[newGame getGameId]]);
            CCLOG(@"Game ID -  int:      %d", [[NSNumber numberWithInt:[newGame getGameId]] intValue]);
            [activeGames setObject:newGame forKey:[NSNumber numberWithInt:[newGame getGameId]]];
        }
    }
    else if (gameMessage.type == GAME_MESSAGE_QUIT)
    {
        CCLOG(@"%@ quit game %d", playerID, gameMessage.gameId);
        Game* gameToRemove;
        for (NSNumber* key in activeGames)
        {
            if ([key intValue] == gameMessage.gameId)
            {
                gameToRemove = [activeGames objectForKey:key];
            }
        }
        if (gameToRemove != nil)
        {
            [self removeGame:gameToRemove];
        }
    }
    
    CCLOG(@"Number of active games: %d", activeGames.count);
    [self refreshActiveGamesList];
}

// The player state changed (eg. connected or disconnected)
- (void)match:(GKMatch*)theMatch player:(NSString*)playerID didChangeState:(GKPlayerConnectionState)state
{
    CCLOG(@"match did change state (to :%d)", state);
    switch (state)
    {
            
        case GKPlayerStateConnected:
            
            // handle a new player connection.
            NSLog(@"Player connected!");
            
            if (theMatch.expectedPlayerCount == 0)
            {
                NSLog(@"All players have joined!");
            }
            
            break;
            
            
        case GKPlayerStateDisconnected:
            
            // a player just disconnected.
            NSLog(@"Player disconnected! (%@)", playerID);
//            matchStarted = NO;
//            [self matchEnded];
            
            // figure out which game the player disconnected from
            for (NSString* key in activeGames)
            {
                Game* game = [activeGames objectForKey:key];
                if (game.match == theMatch)
                {
                    // get the player menu items for that game
                    for (PlayerMenuItem* pmi in game.children)
                    {
                        if ([pmi getPlayerID] == playerID)
                        {
                            [pmi disconnected];
                        }
                    }
                }
            }
            break;
    }
    
}

// The match was unable to connect with the player due to an error.
- (void)match:(GKMatch *)theMatch connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error
{
    
    NSLog(@"Failed to connect to player with error: %@", error.localizedDescription);
//    matchStarted = NO;
    
    [self matchEnded];
    
}

// The match was unable to be established with any players due to an error.
- (void)match:(GKMatch*)theMatch didFailWithError:(NSError*)error
{
    
    NSLog(@"Match failed with error: %@", error.localizedDescription);
//    matchStarted = NO;
    
    [self matchEnded];
    
}

-(NSData*)archiveMessage:(GameMessage*)gameMessage
{
    NSMutableData* data = [NSMutableData data];
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:gameMessage forKey:@"GAME_MESSAGE"];
    [archiver finishEncoding];
    return [NSData dataWithData:data];
}

-(void)removeGame:(Game*)game
{
    NSNumber* keyToRemove;
    for (NSNumber* key in activeGames)
    {
        if ([key intValue] == [game getGameId])
        {
            keyToRemove = key;
        }
    }
    
    if (keyToRemove != nil)
    {
        [activeGames removeObjectForKey:keyToRemove];
    }
    
    [self refreshActiveGamesList];
}

@end
