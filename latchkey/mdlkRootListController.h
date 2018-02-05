#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#include <spawn.h>

#define latchKeyPrefs @"/var/mobile/Library/Preferences/ch.mdaus.latchkey.plist"

@interface mdlkRootListController : PSListController
@end

@protocol PreferencesTableCustomView
- (id)initWithSpecifier:(PSSpecifier *)specifier;
- (CGFloat)preferredHeightForWidth:(CGFloat)width;
@end

@interface PSHeaderCell : PSTableCell <PreferencesTableCustomView> {
    UIImageView *headerImageView;
}
@end
