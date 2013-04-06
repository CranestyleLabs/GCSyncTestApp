//
//  PlayerMenuItem.m
//  GCSyncTestApp
//
//  Created by Fisher on 4/2/13.
//  Copyright (c) 2013 com.threadbaregames. All rights reserved.
//

#import "PlayerMenuItem.h"


@implementation PlayerMenuItem

-(id)initWithGame:(Game*)game andWithPlayerID:(NSString*)pid andWithPlayerAlias:(NSString*)alias
{
    if (self = [super init])
    {
        winSize = [[CCDirector sharedDirector] winSize];
        gameObject = game;
        playerID = pid;
        playerAlias = alias;
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
        
        CCLabelTTF* aliasLabel = [CCLabelTTF labelWithString:playerAlias fontName:@"Marker Felt" fontSize:32];
        [aliasLabel setPosition:ccp(200, self.contentSize.height/2)];
        
        indicator = [CCSprite spriteWithFile:@"spacer.png"];
        [indicator setScaleX:self.contentSize.height/2];
        [indicator setScaleY:self.contentSize.height/2];
        [indicator setColor:ccGREEN];
        [indicator setPosition:ccp(100, self.contentSize.height/2)];
        
        [self createMenu];
        [self addChild:aliasLabel];
        [self addChild:indicator];
        
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
    buttonReinvite = [CCMenuItemFont itemWithString:[NSString stringWithFormat:@"Re-invite"] target:self selector:@selector(launchGame)];
    [buttonReinvite setColor:ccBLACK];
    [buttonReinvite setIsEnabled:NO];

    [buttonReinvite setFontSize:28.0f];
    
    CCMenu* menu = [CCMenu menuWithItems:buttonReinvite, nil];
    
    [menu alignItemsHorizontallyWithPadding:25];
    [menu setPosition:ccp(self.contentSize.width - 25, self.contentSize.height/2)];
    [self addChild:menu];
}

-(void)disconnected
{
    [buttonReinvite setColor:ccWHITE];
    [buttonReinvite setIsEnabled:YES];
    [indicator setColor:ccRED];
}

-(void)reconnected
{
    [buttonReinvite setColor:ccBLACK];
    [buttonReinvite setIsEnabled:NO];
    [indicator setColor:ccGREEN];
}

-(void)reinvite
{
    CCLOG(@"Reinvite %@", playerAlias);
}

-(void)draw
{
    glLineWidth(2);
    ccDrawRect(self.anchorPoint, ccp(self.contentSize.width, self.contentSize.height));
}

@end
