//
//  Header.h
//  KMLKit
//
//  Created by Weston Bustraan on 11/19/24.
//

#import <Foundation/Foundation.h>

//! Project version number for KMLKit.
FOUNDATION_EXPORT double KMLKitVersionNumber;

//! Project version string for KMLKit.
FOUNDATION_EXPORT const unsigned char KMLKitVersionString[];


NS_INLINE NSException * _Nullable tryBlock(void(^_Nonnull tryBlock)(void)) {
    @try {
        tryBlock();
    }
    @catch (NSException *exception) {
        return exception;
    }
    return nil;
}
