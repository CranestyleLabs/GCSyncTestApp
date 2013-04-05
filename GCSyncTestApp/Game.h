//
//  Game.h
//  GCSyncTestApp
//
//  Created by Fisher on 4/1/13.
//  Copyright (c) 2013 com.threadbaregames. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"

#import "GCHelper.h"

@interface Game : CCLayer <NSCoding>
{
    CGSize winSize;
    CCLabelTTF* statusLabel;
    CCMenu* menuReady;
    int gameId;
    NSMutableDictionary* playersDict;
    NSMutableArray* gameIdSyncPlayersArray;
}

typedef enum
{
    GAMESTATE_INIT,
    GAMESTATE_WAITING_FOR_GAMEID_SYNC,
    GAMESTATE_READY_TO_BEGIN
} gameState;

@property BOOL ready;
@property GKMatch* match;
@property gameState state;

-(CCScene*)scene;

-(void)addPlayer:(id)player withId:(NSString*)playerId;
-(void)receiveGameIdSyncMessageFromPlayerId:(NSString*)thisPlayerId withGameId:(int)theGameId;

-(int)getGameId;
-(void)setGameId:(int)id;

@end
