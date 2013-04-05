//
//  GameMessage.h
//  GCSyncTestApp
//
//  Created by Fisher on 4/4/13.
//  Copyright (c) 2013 com.threadbaregames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameMessage : NSObject <NSCoding>
{
    //
}

typedef enum
{
    GAME_MESSAGE_MOVE,
    GAME_MESSAGE_SYNC_GAMEID,
    GAME_MESSAGE_GAME_BEGIN,
    GAME_MESSAGE_GAME_OVER,
    GAME_MESSAGE_QUIT
} gameMessageType;


-(id)initWithGameId:(int)gameId
            andType:(gameMessageType)messageType;

-(id)initWithGameId:(int)gameId
            andType:(gameMessageType)messageType
            andData:(NSData*)data;

@property int gameId;
@property NSData* gameData;
@property gameMessageType type;

@end
