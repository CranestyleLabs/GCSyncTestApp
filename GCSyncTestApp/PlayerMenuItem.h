//
//  PlayerMenuItem.h
//  GCSyncTestApp
//
//  Created by Fisher on 4/2/13.
//  Copyright (c) 2013 com.threadbaregames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Game.h"
#import "Constants.h"
#import "cocos2d.h"

@interface PlayerMenuItem : CCNode
{
    CGSize winSize;
    Game* gameObject;
    NSString* playerID;
    NSString* playerAlias;
    CCMenuItemFont* buttonReinvite;
    CCSprite* indicator;
}

-(id)initWithGame:(Game*)game
  andWithPlayerID:(NSString*)pid
andWithPlayerAlias:(NSString*)alias;

-(id)getGameObject;
-(void)disconnected;
-(void)reconnected;
-(NSString*)getPlayerID;

@end
