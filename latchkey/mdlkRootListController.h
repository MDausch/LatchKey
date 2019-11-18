#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#include <spawn.h>
#import <libcolorpicker.h>


#define kLatchKeyPrefs @"/var/mobile/Library/Preferences/ch.mdaus.latchkey.plist"

@interface mdlkRootListController : PSListController
@end


@protocol PreferencesTableCustomView
// - (id)initWithSpecifier:(PSSpecifier *)specifier;
// - (CGFloat)preferredHeightForWidth:(CGFloat)width;
@end


@interface mdLKHeaderCell : PSTableCell <PreferencesTableCustomView> {
    UIImageView *headerImageView;
}
@end

@interface mdLatchkeyTwitterCell : PSTableCell <PreferencesTableCustomView>
{
    NSString *user;
    UIImageView *profileImageView;
    UIImageView *twitterImageView;
    UILabel *nameLabel;
    UILabel *profileLabel;
}
@end