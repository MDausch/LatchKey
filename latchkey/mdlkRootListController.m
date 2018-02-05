#include "mdlkRootListController.h"
#define latchKeyPrefs @"/var/mobile/Library/Preferences/ch.mdaus.latchkey.plist"


@implementation mdlkRootListController

-(id)readPreferenceValue:(PSSpecifier *)specifier {
    NSDictionary *POSettings = [NSDictionary dictionaryWithContentsOfFile:latchKeyPrefs];
    
    if(!POSettings[specifier.properties[@"key"]]) {
        return specifier.properties[@"default"];
    }
    return POSettings[specifier.properties[@"key"]];
}


-(void)setPreferenceValue:(id)value specifier:(PSSpecifier*) specifier {
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:latchKeyPrefs]];
    [defaults setObject:value forKey:specifier.properties[@"key"]];
    [defaults writeToFile:latchKeyPrefs atomically:YES];
    CFStringRef CPPost = (CFStringRef)CFBridgingRetain(specifier.properties[@"PostNotification"]);
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CPPost, NULL, NULL, YES);
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
    }
    
    return _specifiers;
}

-(void)respring{
        pid_t respringID;
        char *argv[] = {"/usr/bin/killall", "backboardd", NULL};
        posix_spawn(&respringID, argv[0], NULL, NULL, argv, NULL);
        waitpid(respringID, NULL, WEXITED);
}

-(void)goToGithub{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/MDausch/LatchKey/"]];
    
}

-(void)goToTwitter{
    NSString *user = @"m_dausch";
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:user]]];
    else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:user]]];
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:user]]];
    
}

@end



@implementation PSHeaderCell
- (id)initWithSpecifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"headerCell" specifier:specifier];
    if (self) {
        //headerImageView = [[UIImageView alloc] initWithFrame:[self frame]];
        UIImage *header = [[UIImage alloc] initWithContentsOfFile:[[NSBundle bundleWithPath:@"/bootstrap/Library/PreferenceBundles/LatchKey.bundle"] pathForResource:@"header" ofType:@"png"]];
        //headerImageView.layer.masksToBounds = YES;
        headerImageView = [[UIImageView alloc] initWithImage:header];
        headerImageView.contentMode = UIViewContentModeScaleAspectFit;

        [self addSubview:headerImageView];
        [headerImageView release];
    }
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
    // Return a custom cell height.
    return 200.0f;
}
@end

