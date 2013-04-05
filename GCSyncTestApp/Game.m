//
//  Game.m
//  GCSyncTestApp
//
//  Created by Fisher on 4/1/13.
//  Copyright (c) 2013 com.threadbaregames. All rights reserved.
//

#import "Game.h"



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
}

-(void)setupStatusLabel
{
    [self removeChild:statusLabel];
    statusLabel = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:36];
    [self setStatusText];
    [statusLabel setPosition:ccp(winSize.width/2, statusLabel.contentSize.height/2 + 5)];
    [self addChild:statusLabel];
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

-(void)receiveGameIdSyncMessageFromPlayerId:(NSString*)thisPlayerId withGameId:(int)theGameId
{
    
    if (!gameIdSyncPlayersArray)
    {
        gameIdSyncPlayersArray = [[NSMutableArray alloc] initWithCapacity:playersDict.count];
        for (NSString* key in playersDict)
        {
            [gameIdSyncPlayersArray addObject:key];
        }
    }
    
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

-(int)getGameId
{
    return gameId;
}
-(void)setGameId:(int)id
{
    gameId = id;
}

@end
