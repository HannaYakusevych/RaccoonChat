//
//  ThemesViewControllerDelegate.h
//  RaccoonChat
//
//  Created by Анна Якусевич on 03/03/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

#ifndef ThemesViewControllerDelegate_h
#define ThemesViewControllerDelegate_h

#import <Foundation/Foundation.h>
@class ThemesViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol ThemesViewControllerDelegate <NSObject>

- (void)themesViewController:(ThemesViewController *) controller didSelectTheme: (UIColor *) selectedTheme;

@end

NS_ASSUME_NONNULL_END

#endif
