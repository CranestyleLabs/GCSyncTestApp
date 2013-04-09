//
//  Lobby.h
//  GCSyncTestApp
//
//  Created by Fisher on 4/1/13.
//  Copyright (c) 2013 com.threadbaregames. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "GameMenuItem.h"
#import "Constants.h"
#import "GCHelper.h"
#import "AppDelegate.h"

@interface Lobby : CCLayer <GKMatchmakerViewControllerDelegate, GKMatchDelegate>
{
    CGSize winSize;
    NSMutableDictionary* activeGames;
    CCLayerColor* activeGamesMenuLayer;
    UIViewController* presentingViewController;
    
    Game* newGame;
    
    AppController* delegate;

//    int gameId;
}



+(CCScene*)scene;
+(Lobby*)sharedLobby;

-(void)matchStarted;
-(void)matchEnded;

-(void)reinvitePlayersToGame:(Game*)game;

@end
