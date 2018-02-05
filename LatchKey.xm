#import <Foundation/Foundation.h>
#import <UIKit/UiKit.h>
#import <UIKit/UIWindow+Private.h>

#define latchKeyPrefs @"/var/mobile/Library/Preferences/ch.mdaus.latchkey.plist"

@interface SBUIProudLockIconView : UIView
-(void)_configureAutolayoutFlagsNeedingLayout:(BOOL)arg1;
@end

@interface SBCoverSheetWindow : UIWindow
@end

static NSMutableDictionary *settings;
BOOL enabled = YES;
BOOL hideCarrier = NO;
NSInteger option = 1;
float xPos =  176.0;
float yPos =  53.0;
float scale = 1.0;


void refreshPrefs() {
  settings = nil;
  settings = [[NSMutableDictionary alloc] initWithContentsOfFile:[latchKeyPrefs stringByExpandingTildeInPath]];
  if([settings objectForKey:@"enabled"])enabled = [[settings objectForKey:@"enabled"] boolValue];
  if([settings objectForKey:@"option"])option = [[settings objectForKey:@"option"] intValue];
  if([settings objectForKey:@"hideCarrier"])hideCarrier = [[settings objectForKey:@"hideCarrier"] boolValue];
  if([settings objectForKey:@"xPos"])xPos = [[settings objectForKey:@"xPos"] floatValue];
  if([settings objectForKey:@"yPos"])yPos = [[settings objectForKey:@"yPos"] floatValue];
  if([settings objectForKey:@"scale"])scale = [[settings objectForKey:@"scale"] floatValue];
}


static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  refreshPrefs();
}


//Override Face ID View
%hook SBUIProudLockIconView
-(void)layoutSubviews{
    %orig; //Call Original layout subviews to set up everything

    //make sure our kill switch isnt enabled
    if(enabled){
        //Now we override the frame to move the glyph and shrink it down
        //[self setAlpha:1.0f];
        //self.layer.zPosition = 100000;
        switch(option){
            case(1):
                self.frame = CGRectMake(35,10,12,20);
                break;
            case(2):
                self.frame = CGRectMake(72,16,6.5,13);
                break;
            case(3):
                self.frame = CGRectMake(12,16,6.5,13);
                break;
            case(4):
                self.frame = CGRectMake(0,0,0,0);
                break;
            case(5):
                self.frame = CGRectMake(xPos,yPos,23 * scale,40 * scale);
            default:;
                //self.frame = CGRectMake(176,35,23,40);

        }

        //Now we need to remove all the auto layout constraints apple added
        //to the view by looping through the superview and removing each
        //constraint containing our SBUIProudLockIconView object
        UIView *super = self.superview;
        while (super != nil) {
            for (NSLayoutConstraint *c in super.constraints) {
                if (c.firstItem == self || c.secondItem == self) {
                    [super removeConstraint:c];
                }
            }
            super = super.superview; //Go up another level
        }
        /*
        super = self.superview;
        [self removeFromSuperview];
        [super addSubview: self];
        */
        //Remove all the constraints our object holds
        [self removeConstraints:self.constraints];
        self.translatesAutoresizingMaskIntoConstraints = YES;

        //This fixes some other autolayout issues when scrolling
        [self performSelector:@selector(_configureAutolayoutFlagsNeedingLayout:)
                        withObject:@FALSE];

    }

}

//We need a this so we can call it properly with perform selector
-(void)_configureAutolayoutFlagsNeedingLayout:(BOOL)arg1{
    %orig(arg1); //We dont need to modify anything, call original method
}
%end

//Override Carrier Name
%hook SBStatusBarStateAggregator
- (id)_sbCarrierNameForOperator:(id)arg1 {
    if(enabled && ((option == 1) || hideCarrier))
        return @" "; //We cant have the carrier enabled to show the glyph in the statusbar.
    else
        return %orig(arg1);
}
%end



%ctor {
  @autoreleasepool {
    settings = [[NSMutableDictionary alloc] initWithContentsOfFile:[latchKeyPrefs stringByExpandingTildeInPath]];
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, CFSTR("ch.mdaus.latchkey.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    refreshPrefs();

  }
}
