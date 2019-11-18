#import <Foundation/Foundation.h>
#import <UIKit/UiKit.h>
#import <UIKit/_UILegibilitySettings.h>
#import <objc/runtime.h>
#import <libcolorpicker.h>

#define latchKeyPrefs @"/var/mobile/Library/Preferences/ch.mdaus.latchkey.plist"
#define kThemeBundlePathiOS11 @"/Library/Application Support/LatchKey/Themes/ios11/"
#define kThemeBundlePathiOS12 @"/Library/Application Support/LatchKey/Themes/ios12/"

@interface SBUIProudLockIconView : UIView
@property (nonatomic,assign) BOOL handleMediaColoring;
- (void)_configureAutolayoutFlagsNeedingLayout:(BOOL)arg1;
- (void)handleColoring:(NSNotification *)notification;
- (void)mdartsyFixColors:(UIView *)parentView color:(UIColor*)colorToUse;
@end

@interface SBLockScreenManager : NSObject
+ (id)sharedInstance;
- (void)tapToWakeControllerDidRecognizeWakeGesture:(id)arg1;
- (void)lockScreenViewControllerRequestsUnlock;
@end

@interface SBUICAPackageView : UIView
@end

static NSMutableDictionary *settings;
BOOL enabled = YES;
BOOL hideCarrier = NO;
BOOL wantsCustomColor = NO;
UIColor * customColor = [UIColor redColor];

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
    if([settings objectForKey:@"wantsCustomColor"])wantsCustomColor = [[settings objectForKey:@"wantsCustomColor"] boolValue];
}


inline NSString * getString(NSString *key) {
    return [[[NSDictionary dictionaryWithContentsOfFile:latchKeyPrefs] valueForKey:key] stringValue];
}


inline float getFloat(NSString *key) {
    return [[[NSDictionary dictionaryWithContentsOfFile:latchKeyPrefs] valueForKey:key] floatValue];
}


inline NSInteger getInt(NSString *key) {
    return [[[NSDictionary dictionaryWithContentsOfFile:latchKeyPrefs] valueForKey:key] intValue];
}


inline bool getBool(NSString *key) {
    return [[[NSDictionary dictionaryWithContentsOfFile:latchKeyPrefs] valueForKey:key] boolValue];
}


inline UIColor * getColor(NSString *key) {
    return LCPParseColorString([[NSDictionary dictionaryWithContentsOfFile:latchKeyPrefs] objectForKey:key], @"#FF0000");
}


static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    refreshPrefs();
}


//Override Face ID View
%hook SBUIProudLockIconView
%property (nonatomic,assign) BOOL handleMediaColoring;
- (id)initWithFrame:(CGRect)arg1  {
    SBUIProudLockIconView *orig = %orig;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(handleColoring:)
                                              name:@"ArtsyColorLockscreen"
                                              object:nil];

    //Watch for battery changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(handleColoring:)
                                          name:@"ArtsyUndoLockscreen"
                                          object:nil];
    return orig;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    %orig;
}


// Stop the use faceID to unlock prompt
-(void)setState:(long long)arg1 animated:(BOOL)arg2 options:(long long)arg3 completion:(/*^block*/id)arg4 {
    if(arg1 == 19 || arg1 == 16)
      arg1 = 1;
      %orig;
}


- (void)layoutSubviews {
    %orig; //Call Original layout subviews to set up everything

     //make sure our kill switch isnt enabled
    if(enabled) {
        
        // Get lock View
        SBUICAPackageView *lock = MSHookIvar<SBUICAPackageView*>(self, "_lockView");

        // For some unknown reason the lockview's y position is nowhere near where the actual position is, 
        // so we use the coaching view to get the base position.
        if(@available(iOS 12.0, *)) {
            UIView *coachingView = MSHookIvar<UIView*>(self, "_lazy_faceIDCoachingView");
          
            // Decide where to place the lock based on user choice  
            switch(option) {
                case(0): //Default
                    self.hidden = NO;
                    break; 
                case(1): // Status bar
                    self.hidden = NO;
                    [self setFrame:CGRectMake(-lock.frame.origin.x + 38, -coachingView.frame.origin.y, self.frame.size.width,self.frame.size.height)];
                    lock.transform = CGAffineTransformScale(CGAffineTransformIdentity, .6f, .6f);  
                    break;
                case(2): //Compact Status Bar (right of carrier)
                    self.hidden = NO;
                    [self setFrame:CGRectMake(-lock.frame.origin.x + 65, -coachingView.frame.origin.y + 3, self.frame.size.width,self.frame.size.height)];
                    lock.transform = CGAffineTransformScale(CGAffineTransformIdentity, .4f, .4f);  
                    break;
                case(3): //Compact Status Bar (right of carrier)
                    self.hidden = NO;
                    [self setFrame:CGRectMake(-lock.frame.origin.x + 14, -coachingView.frame.origin.y + 3, self.frame.size.width,self.frame.size.height)];
                    lock.transform = CGAffineTransformScale(CGAffineTransformIdentity, .4f, .4f);  
                    break;
                case(4): // Hidden
                    self.hidden = YES;
                    break;
                case(5): //Custom position
                    self.hidden = NO;
                    lock.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);  
                    [self setFrame:CGRectMake(-lock.frame.origin.x + xPos, -coachingView.frame.origin.y + yPos, self.frame.size.width,self.frame.size.height)];
                default:
                    self.hidden = NO;
                    lock.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);  
                    [self setFrame:CGRectMake(-lock.frame.origin.x + xPos, -coachingView.frame.origin.y + yPos, self.frame.size.width,self.frame.size.height)];
                    break;
            }
        } else {
            switch(option) {
                case(0): //Default
                    break; 
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
}


- (void)setContentColor:(UIColor *)arg1 {

  if(enabled && wantsCustomColor && !self.handleMediaColoring) {
    %orig(getColor(@"customColor"));
  } else {
    %orig(arg1);
  }
}


- (void)setLegibilitySettings:(id)arg1{

    if(enabled && wantsCustomColor) {
      _UILegibilitySettings *legibilitySettings  = [[_UILegibilitySettings alloc]initWithStyle:1
                                                  primaryColor:getColor(@"customColor")
                                                  secondaryColor:[UIColor colorWithWhite:0.25 alpha:1]
                                                  shadowColor:[UIColor colorWithWhite:0.1 alpha:0.23]];

      %orig(legibilitySettings);
    } else {
      %orig(arg1);
    }
}

%new
- (void)handleColoring:(NSNotification *)notification {
    if(notification == nil)
	    return;

    if(notification && [notification.name isEqualToString: @"ArtsyColorLockscreen"]) {
      self.handleMediaColoring = YES;
    } else {
      self.handleMediaColoring = YES;
    }
}

%end

//Here we add a gesture for tapping the icon to prompt for unlock
%hook SBDashBoardView
-(void)setProudLockIconView:(id)arg1 {

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


// Theme Stuff
%hook SBUICAPackageView
- (id)initWithPackageName:(id)arg1 inBundle:(id)arg2 {
  // Default to the original implementation, this way we don't ever distribute Apple's files
  if(!currentTheme || [currentTheme isEqualToString:@"Apple_Default.bundle"]) {
    return %orig;
  }

  if(@available(iOS 12.0, *))
      themeBundle = [[[NSBundle alloc] initWithPath:[NSString stringWithFormat:@"%@/%@", kThemeBundlePathiOS12 , currentTheme]] autorelease];
  else 
      themeBundle = [[[NSBundle alloc] initWithPath:[NSString stringWithFormat:@"%@/%@", kThemeBundlePathiOS11, currentTheme]] autorelease];

  //We need the name, but minus the .bundle to properly call the method
  currentThemeName = [currentTheme stringByReplacingOccurrencesOfString:@".bundle" withString:@""];

  //Return our custom theme and bundle
  return %orig(currentThemeName,themeBundle);
}
%end 

// iOS 13
%hook BSUICAPackageView
- (id)initWithPackageName:(id)arg1 inBundle:(id)arg2 {

  // Default to the original implementation, this way we don't ever distribute Apple's files
  if(!currentTheme || [currentTheme isEqualToString:@"Apple_Default.bundle"]) {
    return %orig;
  }

  themeBundle = [[[NSBundle alloc] initWithPath:[NSString stringWithFormat:@"%@/%@", kThemeBundlePathiOS12 , currentTheme]] autorelease];

  //We need the name, but minus the .bundle to properly call the method
  currentThemeName = [currentTheme stringByReplacingOccurrencesOfString:@".bundle" withString:@""];

  //Return our custom theme and bundle
  return %orig(currentThemeName,themeBundle);
}
%end 


//Override Carrier Name
// TODO make this only for the lockscreen and not control center
%hook SBStatusBarStateAggregator
- (id)_sbCarrierNameForOperator:(id)arg1 {
  if(enabled && ((option == 1) || hideCarrier))
    return @" "; //We cant have the carrier enabled to show the glyph in the statusbar.
  else
    return %orig(arg1);
}
%end

%hook _UIStatusBarDataCellularEntry
-(void)setString:(NSString *)string {
  if(enabled && ((option == 1) || hideCarrier))
    %orig(@""); //We cant have the carrier enabled to show the glyph in the statusbar.
  else
    %orig;
}
%end


%ctor {
  @autoreleasepool {
    settings = [[NSMutableDictionary alloc] initWithContentsOfFile:[latchKeyPrefs stringByExpandingTildeInPath]];
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, CFSTR("ch.mdaus.latchkey.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    refreshPrefs();
  }
}
