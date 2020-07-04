#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <libcolorpicker.h>

#define latchKeyPrefs @"/var/mobile/Library/Preferences/ch.mdaus.latchkey.plist"
#define kThemeBundlePathiOS11 @"/Library/Application Support/LatchKey/Themes/ios11/"
#define kThemeBundlePathiOS12 @"/Library/Application Support/LatchKey/Themes/ios12/"

@interface _UILegibilitySettings : NSObject 
-(id)initWithStyle:(NSInteger)style primaryColor:(UIColor *)primaryColor secondaryColor:(UIColor *)secondaryColor  shadowColor:(UIColor *) shadowColor;
@end 

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