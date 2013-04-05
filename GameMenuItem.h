//
//  GameMenuItem.h
//  GCSyncTestApp
//
//  Created by Fisher on 4/2/13.
//  Copyright (c) 2013 com.threadbaregames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Game.h"
#import "Constants.h"
#import "cocos2d.h"

@interface GameMenuItem : CCNode
{
    CGSize winSize;
    Game* gameObject;
}

-(id)initWithGame:(Game*)game;

-(id)getGameObject;

@end
