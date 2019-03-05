//
//  Themes.m
//  RaccoonChat
//
//  Created by Анна Якусевич on 03/03/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

#import "Themes.h"

@implementation Themes

// MARK: - Initialization
@synthesize theme1 = _theme1;
@synthesize theme2 = _theme2;
@synthesize theme3 = _theme3;
-(id)initWithFirstColor:(UIColor*)firstColor second:(UIColor*)secondColor third:(UIColor*)thirdColor {
  self = [super init];
  if (self) {
    self.theme1 = [firstColor retain];
    self.theme2 = [secondColor retain];
    self.theme3 = [thirdColor retain];
  }
  return self;
}

// MARK: - Deinitialization
-(void)dealloc {
  [_theme1 release];
  [_theme2 release];
  [_theme3 release];
  [super dealloc];
}

// MARK: - get property methods
- (UIColor*)theme1 {
  return _theme1;
}
- (UIColor*)theme2 {
  return _theme2;
}
- (UIColor*)theme3 {
  return _theme3;
}

// MARK: - set property methods
- (void)setTheme1:(UIColor *)newTheme {
  if (_theme1 != newTheme) {
    UIColor* oldTheme = _theme1;
    _theme1 = newTheme;
    [oldTheme release];
  }
}
- (void)setTheme2:(UIColor *)newTheme {
  if (_theme2 != newTheme) {
    UIColor* oldTheme = _theme2;
    _theme2 = newTheme;
    [oldTheme release];
  }
}
- (void)setTheme3:(UIColor *)newTheme {
  if (_theme3 != newTheme) {
    UIColor* oldTheme = _theme3;
    _theme3 = newTheme;
    [oldTheme release];
  }
}


@end
