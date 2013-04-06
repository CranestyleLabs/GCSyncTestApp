//
//  GameMenuItem.m
//  GCSyncTestApp
//
//  Created by Fisher on 4/2/13.
//  Copyright (c) 2013 com.threadbaregames. All rights reserved.
//

#import "GameMenuItem.h"


@implementation GameMenuItem

-(id)initWithGame:(Game*)game
{
    if (self = [super init])
    {
        winSize = [[CCDirector sharedDirector] winSize];
        gameObject = game;
        [self setAnchorPoint:ccp(0,0)];
        
        int borderWidth = 2;
        int itemHeight = 75;
        [self setContentSize:CGSizeMake(winSize.width - (borderWidth*2), itemHeight)];
        
        CCSprite* bg = [CCSprite spriteWithFile:@"spacer.png"];
        [bg setScaleX:self.contentSize.width];
        [bg setScaleY:self.contentSize.height];
        [bg setColor:ccBLACK];
        [bg setPosition:ccp(self.contentSize.width/2, self.contentSize.height/2)];
        [self addChild:bg z:-1];
        
        [self createMenu];
        
    }
    return self;
}

-(void)refresh
{
    //
}

-(id)getGameObject
{
    return gameObject;
}

-(void)createMenu
{
    CCMenuItemFont* buttonLaunch = [CCMenuItemFont itemWithString:[NSString stringWithFormat:@"Launch Game %d", [gameObject getGameId]] target:self selector:@selector(launchGame)];
    CCMenuItemFont* buttonCancel = [CCMenuItemFont itemWithString:@"X" target:self selector:@selector(cancelGame)];
    
    [buttonCancel setFontSize:28.0f];
    [buttonLaunch setFontSize:28.0f];
    
    CCMenu* menu = [CCMenu menuWithItems:buttonCancel, buttonLaunch, nil];
    
    CGSize menuSize = CGSizeMake((buttonLaunch.contentSize.width + buttonCancel.contentSize.width), buttonLaunch.contentSize.height);
    
    [menu alignItemsHorizontallyWithPadding:25];
    [menu setPosition:ccp(menuSize.width/2 + 25, self.contentSize.height/2)];
    [self addChild:menu];
}


-(void)launchGame
{
    [[NSNotificationCenter defaultCenter] postNotificationName:LAUNCH_GAME object:self];
}

-(void)cancelGame
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CANCEL_GAME object:self];
}

-(void)draw
{
    glLineWidth(2);
    ccDrawRect(self.anchorPoint, ccp(self.contentSize.width, self.contentSize.height));
}

@end
