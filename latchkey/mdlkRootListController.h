#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#include <spawn.h>

#define kLatchKeyPrefs @"/var/mobile/Library/Preferences/ch.mdaus.latchkey.plist"

@interface mdlkRootListController : PSListController
@end


@protocol PreferencesTableCustomView
- (id)initWithSpecifier:(PSSpecifier *)specifier;
- (CGFloat)preferredHeightForWidth:(CGFloat)width;
@end

@interface mdLKHeaderCell : PSTableCell <PreferencesTableCustomView> {
    UIImageView *headerImageView;
}
@end


