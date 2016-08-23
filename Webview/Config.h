//
//  Config.h
//  Webview
//
//  Created by iOS on 19/08/16.
//  Copyright © 2016 iOS. All rights reserved.
//

#ifndef Config_h
#define Config_h


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define kStausBarFrameHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define DB @"USUARIO"
#define kStausBarFrameHeight [UIApplication sharedApplication].statusBarFrame.size.height

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#endif /* Config_h */
