//
//  Themes.h
//  RaccoonChat
//
//  Created by Анна Якусевич on 03/03/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Themes: NSObject

-(instancetype)initWithFirstColor:(UIColor*)firstColor second:(UIColor*)secondColor third:(UIColor*)thirdColor;

@property (nonatomic, retain) UIColor* theme1;
@property (nonatomic, retain) UIColor* theme2;
@property (nonatomic, retain) UIColor* theme3;


@end
