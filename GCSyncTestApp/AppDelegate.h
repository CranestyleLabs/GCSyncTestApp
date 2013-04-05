//
//  AppDelegate.h
//  GCSyncTestApp
//
//  Created by Fisher on 4/1/13.
//  Copyright com.threadbaregames 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

// Added only for iOS 6 support
@interface MyNavigationController : UINavigationController <CCDirectorDelegate>
@end

@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow*                         window_;
	MyNavigationController*           navController_;
	CCDirectorIOS*__unsafe_unretained director_;     // weak ref
}

@property (nonatomic, retain) UIWindow*      window;
@property (readonly) MyNavigationController* navController;
@property (readonly) CCDirectorIOS*          director;

@end
