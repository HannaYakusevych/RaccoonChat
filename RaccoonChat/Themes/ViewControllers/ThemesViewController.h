//
//  ThemesViewController.h
//  RaccoonChat
//
//  Created by Анна Якусевич on 03/03/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Themes.h"
#import "ThemesViewControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThemesViewController<ThemesViewControllerDelegate>: UIViewController


- (IBAction) didSelectTheme:(UIButton*)sender;
- (IBAction)dismiss:(UIBarButtonItem *)sender;

@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *themeButtons;
@property (nonatomic, assign) id<ThemesViewControllerDelegate> delegate;

@property (nonatomic, retain) Themes* model;

@end

NS_ASSUME_NONNULL_END
