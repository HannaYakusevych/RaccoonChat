//
//  ThemesViewController.m
//  RaccoonChat
//
//  Created by Анна Якусевич on 03/03/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

#import "ThemesViewController.h"

@interface ThemesViewController()

@end

@implementation ThemesViewController

@synthesize model = _model;
@synthesize delegate = _delegate;

// MARK: - Actions
- (IBAction) didSelectTheme:(UIButton*)sender {
  NSUInteger index = [_themeButtons indexOfObject:sender];
  UIColor* backgroundColor;
  switch (index) {
    case 0:
      backgroundColor = _model.theme1;
      break;
    case 1:
      backgroundColor = _model.theme2;
      break;
    case 2:
      backgroundColor = _model.theme3;
      break;
    default:
      [NSException raise:@"wrong button idx" format:@""];
      break;
  }
  
  if (_delegate) {
    [_delegate themesViewController:self didSelectTheme:backgroundColor];
  }
}

- (IBAction)dismiss:(UIBarButtonItem *)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [_themeButtons[0] setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.8]];
  [_themeButtons[1] setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.8]];
  [_themeButtons[2] setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.8]];
    // Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  
}

// MARK: - Getters
- (Themes*) model {
  return _model;
}

- (id<ThemesViewControllerDelegate>)delegate {
  return _delegate;
}

// MARK: - Setters
- (void)setModel:(Themes *)newModel {
  if (_model != newModel) {
    id oldModel = _model;
    _model = [newModel retain];
    [oldModel release];
  }
}

- (void)setDelegate:(id<ThemesViewControllerDelegate>)delegate {
  if (_delegate != delegate) {
    id oldDelegate = _delegate;
    _delegate = [delegate retain];
    [oldDelegate release];
  }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
  [_model release];
  [_themeButtons release];
  [super dealloc];
}
@end
