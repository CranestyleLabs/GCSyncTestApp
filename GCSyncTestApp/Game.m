//
//  Game.m
//  GCSyncTestApp
//
//  Created by Fisher on 4/1/13.
//  Copyright (c) 2013 com.threadbaregames. All rights reserved.
//

#import "Game.h"
#import "Lobby.h"
#import "PlayerMenuItem.h"



@implementation Game

static CCScene* scene;

-(CCScene*)scene
{
	// 'scene' is an autorelease object.
    if (!scene)
    {
        scene = [CCScene node];
	
        // add layer as a child to scene
        [scene addChild: self];
    }
	
	// return the scene
	return scene;
}

-(id)init
{
    if (self = [super init])
    {
        winSize = [[CCDirector sharedDirector] winSize];
        playersDict = [[NSMutableDictionary alloc] init];
        gameId = -1;
        self.ready = NO;
        self.state = GAMESTATE_INIT;
        
        playerListLayer = [[CCLayerColor alloc] initWithColor:ccc4(255, 255, 255, 100)];
        [playerListLayer setAnchorPoint:ccp(0,1)];
        [playerListLayer setContentSize:CGSizeMake(winSize.width, winSize.height * 0.75)];
        [playerListLayer setPosition:ccp(0, winSize.height - playerListLayer.contentSize.height)];
        [self addChild:playerListLayer];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    // decode stuff
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    // encode stuff
}

-(void)onEnter
{
    [super onEnter];
    [self setupButtons];
    [self setupStatusLabel];
    [self refreshPlayerList];
}

-(void)setupStatusLabel
{
    [self removeChild:statusLabel];
    statusLabel = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:36];
    [self setStatusText];
    [statusLabel setPosition:ccp(winSize.width/2, statusLabel.contentSize.height/2 + 5)];
    [self addChild:statusLabel];
}

-(void)setupPlayersMenu
{
    CGPoint start  = ccp(playerListLayer.contentSize.width/2, playerListLayer.contentSize.height);
    int i = 0;
    for (NSString* key in playersDict)
    {
        GKPlayer* player = [playersDict objectForKey:key];
        CCLOG(@"setting up player menu item for %@", player.alias);
        PlayerMenuItem* pmi = [[PlayerMenuItem alloc] initWithGame:self andWithPlayerID:key andWithPlayerAlias:player.alias];
        [pmi setPosition:ccpAdd(start, ccp(pmi.contentSize.width * i, pmi.contentSize.height * i))];
        [self addChild:pmi z:2];
        i++;
    }
    for (CCNode* node in self.children)
    {
        if ([node isKindOfClass:[PlayerMenuItem class]])
        {
            PlayerMenuItem* pmi = (PlayerMenuItem*)node;
            CCLOG(@"player menu item for %@ located at %@", [pmi getPlayerAlias], NSStringFromCGPoint(pmi.position));
        }
    }
}

-(void)setupButtons
{
    [self removeChild:menuReady];
    CCMenuItemFont* buttonReady = [CCMenuItemFont itemWithString:@"Ready" target:self selector:@selector(clickedReadyButton)];
    CCMenuItemFont* buttonLobby = [CCMenuItemFont itemWithString:@"Lobby" target:self selector:@selector(clickedLobbyButton)];
    menuReady = [CCMenu menuWithItems:buttonLobby, buttonReady, nil];
    [menuReady alignItemsHorizontallyWithPadding:20];
    [menuReady setPosition:ccp(winSize.width/2, 150)];
    [self addChild:menuReady];
}

-(void)refreshPlayerList
{
//    [playerListLayer removeAllChildrenWithCleanup:YES];
}

-(void)clickedReadyButton
{
    self.ready = !self.ready;
    [self setStatusText];
}

-(void)clickedLobbyButton
{
    [[CCDirectorIOS sharedDirector] popScene];
}

-(void)setStatusText
{
    if (self.ready && statusLabel)
    {
        [statusLabel setColor:ccGREEN];
        [statusLabel setString:@"Status:\nI'm ready!"];
    }
    else
    {
        [statusLabel setColor:ccRED];
        [statusLabel setString:@"Status:\nI'm not ready!"];
    }
}

-(void)addPlayer:(id)player withId:(NSString*)playerId
{
    [playersDict setObject:player forKey:playerId];
}

-(void)addPlayersForIDSync:(NSArray*)playerIDs
{   
    gameIdSyncPlayersArray = [playerIDs mutableCopy];
    [self lookupPlayerAliases];
}

-(void)receiveGameIdSyncMessageFromPlayerId:(NSString*)thisPlayerId withGameId:(int)theGameId
{   
    [self setGameId: (theGameId > [self getGameId] ? theGameId : [self getGameId])];
    CCLOG(@"Game id set to %d", gameId);
    
    NSMutableArray* forRemoval = [[NSMutableArray alloc] init];
    for (NSString* playerId in gameIdSyncPlayersArray)
    {
        if ([playerId isEqualToString:thisPlayerId])
        {
            [forRemoval addObject:playerId];
        }
    }
    [gameIdSyncPlayersArray removeObjectsInArray:forRemoval];
    
    if (gameIdSyncPlayersArray.count > 0)
    {
        // set state still waiting
        self.state = GAMESTATE_WAITING_FOR_GAMEID_SYNC;
    }
    else
    {
        // set state done waiting, ready to go!
        self.state = GAMESTATE_READY_TO_BEGIN;
    }
    
}

- (void)lookupPlayerAliases
{
    
    NSLog(@"Looking up %d players...", self.match.playerIDs.count);
    [GKPlayer loadPlayersForIdentifiers:self.match.playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
        
        if (error != nil)
        {
            NSLog(@"Error retrieving player info: %@", error.localizedDescription);
            [[Lobby sharedLobby] matchEnded];
        }
        else
        {
            
            // Populate players dict
            for (GKPlayer *player in players)
            {
                NSLog(@"Found player: %@ [%@]", player.alias, player.playerID);
                [self addPlayer:player withId:player.playerID];
            }
            // setup players menu
            [self setupPlayersMenu];
            
            // Notify delegate match can begin
            [[Lobby sharedLobby] matchStarted];
            
        }
    }];
    
}

-(int)getGameId
{
    return gameId;
}

-(void)setGameId:(int)id
{
    gameId = id;
}

@end
