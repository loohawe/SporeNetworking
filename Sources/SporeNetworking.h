//
//  SporeNetworking.h
//  SporeNetworking
//
//  Created by Hanguang on 12/08/2017.
//  Copyright © 2017 luhao. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for SporeNetworking.
FOUNDATION_EXPORT double SporeNetworkingVersionNumber;

//! Project version string for SporeNetworking.
FOUNDATION_EXPORT const unsigned char SporeNetworkingVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SporeNetworking/PublicHeader.h>

@interface AbstractInputStream : NSInputStream

// Workaround for http://www.openradar.me/19809067
// This issue only occurs on iOS 8
- (instancetype)init;

@end

