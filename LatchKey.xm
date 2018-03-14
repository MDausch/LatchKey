#import <Foundation/Foundation.h>
#import <UIKit/UiKit.h>

#define latchKeyPrefs @"/var/mobile/Library/Preferences/ch.mdaus.latchkey.plist"
#define kThemeBundlePath @"/Library/Application Support/LatchKey/Themes/"

@interface SBUIProudLockIconView : UIView
-(void)_configureAutolayoutFlagsNeedingLayout:(BOOL)arg1;
@end

@interface SBLockScreenManager : NSObject
+ (id)sharedInstance;
- (void)tapToWakeControllerDidRecognizeWakeGesture:(id)arg1;
- (void)lockScreenViewControllerRequestsUnlock;
@end


static NSMutableDictionary *settings;
BOOL enabled = YES;
BOOL hideCarrier = NO;
NSInteger option = 1;
float xPos =  176.0;
float yPos =  53.0;
float scale = 1.0;
NSString *currentTheme;
NSString *currentThemeName = @"duck";
NSBundle *themeBundle = nil;

void refreshPrefs() {
  settings = nil;
  settings = [[NSMutableDictionary alloc] initWithContentsOfFile:[latchKeyPrefs stringByExpandingTildeInPath]];
  if([settings objectForKey:@"enabled"])enabled = [[settings objectForKey:@"enabled"] boolValue];
  if([settings objectForKey:@"option"])option = [[settings objectForKey:@"option"] intValue];
  if([settings objectForKey:@"hideCarrier"])hideCarrier = [[settings objectForKey:@"hideCarrier"] boolValue];
  if([settings objectForKey:@"xPos"])xPos = [[settings objectForKey:@"xPos"] floatValue];
  if([settings objectForKey:@"yPos"])yPos = [[settings objectForKey:@"yPos"] floatValue];
  if([settings objectForKey:@"scale"])scale = [[settings objectForKey:@"scale"] floatValue];
  if([settings objectForKey:@"currentTheme"])currentTheme = [[settings objectForKey:@"currentTheme"] stringValue];

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

        // Decide where to place the lock based on user choice
        switch(option){
            case(1): // Status bar
                self.frame = CGRectMake(35,10,12,20);
                break;
            case(2): //Compact Status Bar (right of carrier)
                self.frame = CGRectMake(72,16,6.5,13);
                break;
            case(3): //Compact Status Bar (right of carrier)
                self.frame = CGRectMake(12,16,6.5,13);
                break;
            case(4): // Hidden
                self.frame = CGRectMake(0,0,0,0);
                break;
            case(5): //Custom position
                self.frame = CGRectMake(xPos,yPos,23 * scale,40 * scale);
            default:;

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

//Here we add a gesture for tapping the icon to prompt for unlock
%hook SBDashBoardView
-(void)setProudLockIconView:(id)arg1{

    //Grab the view and store it so we can add to it
    SBUIProudLockIconView *glyphView = arg1;
    glyphView.userInteractionEnabled = YES;

    //Create our gesture recognizer and add it to the view
    UITapGestureRecognizer *glyphTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(glyphWantsUnlock)];
    glyphTap.numberOfTapsRequired = 1;
    [glyphView addGestureRecognizer:glyphTap];

    %orig(glyphView);

}

//Our tap handler to prompt for unlock
%new
- (void)glyphWantsUnlock {
    [[NSClassFromString(@"SBLockScreenManager") sharedInstance] lockScreenViewControllerRequestsUnlock];
}

%end


//Theme Stuff
%hook SBUICAPackageView
-(id)initWithPackageName:(id)arg1 inBundle:(id)arg2{

    //Create our theme based off of user choice
    themeBundle = [[[NSBundle alloc] initWithPath:[NSString stringWithFormat:@"%@/%@", kThemeBundlePath, currentTheme]] autorelease];

    //We need the name, but minus the .bundle to properly call the method
    currentThemeName = [currentTheme stringByReplacingOccurrencesOfString:@".bundle" withString:@""];

    //Return our custom theme and bundle
    return %orig(currentThemeName,themeBundle);
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
