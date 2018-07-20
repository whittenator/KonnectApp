//
//  MainViewController.h
//  LGSideMenuControllerDemo
//

#import "LGSideMenuController.h"

@interface MainViewController : LGSideMenuController<LGSideMenuDelegate>

- (void)setupWithType:(NSUInteger)type;

@end
