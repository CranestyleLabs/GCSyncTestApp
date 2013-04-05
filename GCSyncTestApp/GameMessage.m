//
//  GameMessage.m
//  GCSyncTestApp
//
//  Created by Fisher on 4/4/13.
//  Copyright (c) 2013 com.threadbaregames. All rights reserved.
//

#import "GameMessage.h"

@implementation GameMessage

-(id)initWithGameId:(int)gameId andType:(gameMessageType)messageType
{
    if (self = [super init])
    {
        self.gameId = gameId;
        self.type = messageType;
    }
    return self;
}

-(id)initWithGameId:(int)gameId andType:(gameMessageType)messageType andData:(NSData *)data
{
    if (self = [super init])
    {
        self.gameId = gameId;
        self.type = messageType;
        self.gameData = data;
    }
    return self;
}

#define kGAME_MESSAGE_GAME_ID   @"GameMessageGameId"
#define kGAME_MESSAGE_GAME_TYPE @"GameMessageGameType"
#define kGAME_MESSAGE_GAME_DATA @"GameMessageGameData"

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (aDecoder)
    {
        [self setGameId:   [aDecoder decodeIntForKey:kGAME_MESSAGE_GAME_ID]];
        [self setType:     [aDecoder decodeIntForKey:kGAME_MESSAGE_GAME_TYPE]];
        [self setGameData: [aDecoder decodeObjectForKey:kGAME_MESSAGE_GAME_DATA]];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    if (aCoder)
    {
        [aCoder encodeInt:self.gameId      forKey:kGAME_MESSAGE_GAME_ID];
        [aCoder encodeInt:self.type        forKey:kGAME_MESSAGE_GAME_TYPE];
        [aCoder encodeObject:self.gameData forKey:kGAME_MESSAGE_GAME_DATA];
    }
}

@end
