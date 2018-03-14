#include "mdlkRootListController.h"
#define kLatchKeyPrefs @"/var/mobile/Library/Preferences/ch.mdaus.latchkey.plist"
#define kThemeBundlePath @"/Library/Application Support/LatchKey/Themes/"



@implementation mdlkRootListController

-(id)readPreferenceValue:(PSSpecifier *)specifier {
    NSDictionary *POSettings = [NSDictionary dictionaryWithContentsOfFile:kLatchKeyPrefs];
    
    if(!POSettings[specifier.properties[@"key"]]) {
        return specifier.properties[@"default"];
    }
    return POSettings[specifier.properties[@"key"]];
}


-(void)setPreferenceValue:(id)value specifier:(PSSpecifier*) specifier {
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:kLatchKeyPrefs]];
    [defaults setObject:value forKey:specifier.properties[@"key"]];
    [defaults writeToFile:kLatchKeyPrefs atomically:YES];
    CFStringRef CPPost = (CFStringRef)CFBridgingRetain(specifier.properties[@"PostNotification"]);
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CPPost, NULL, NULL, YES);
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"latchkeyPrefsMain" target:self] retain];
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

-(void)savePrefs{
    [self.view endEditing:YES];
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

//Theme selectors
-(NSArray *)themeDisplayTitles {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray* files = [fm contentsOfDirectoryAtPath:kThemeBundlePath error:nil];
    NSMutableArray *listOfFiles = [files mutableCopy];
    
    for (int i = 0; i < listOfFiles.count; ++i) {
        NSString *entry = [listOfFiles objectAtIndex:i];
        entry = [entry stringByReplacingOccurrencesOfString:@"_" withString:@" "];
        entry = [entry stringByReplacingOccurrencesOfString:@".bundle" withString:@""];
        [listOfFiles replaceObjectAtIndex:i withObject:entry];
    }
    
    return listOfFiles;
}


-(NSArray *)themeBundleToUse {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray* files = [fm contentsOfDirectoryAtPath:kThemeBundlePath error:nil];
    NSMutableArray *listOfFiles = [files mutableCopy];
    
    return listOfFiles;
}


@end





@implementation mdLKHeaderCell
- (id)initWithSpecifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"latchKeyHeader" specifier:specifier];
    if (self) {
        UIImage *header = [[UIImage alloc] initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/PreferenceBundles/LatchKey.bundle"] pathForResource:@"mdlatchkeyHeader" ofType:@"png"]];
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
