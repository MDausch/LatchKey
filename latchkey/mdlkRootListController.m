#include "mdlkRootListController.h"
#define kLatchKeyPrefs @"/var/mobile/Library/Preferences/ch.mdaus.latchkey.plist"
#define kThemeBundlePathiOS11 @"/Library/Application Support/LatchKey/Themes/ios11/"
#define kThemeBundlePathiOS12 @"/Library/Application Support/LatchKey/Themes/ios12/"



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
        char *argv[] = {(char *)"/usr/bin/killall", (char *)"backboardd", NULL};
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
    NSArray* files;
    if(@available(iOS 12.0, *)) 
        files = [fm contentsOfDirectoryAtPath:kThemeBundlePathiOS12  error:nil];
    else 
        files = [fm contentsOfDirectoryAtPath:kThemeBundlePathiOS11  error:nil];

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
    NSArray* files;
    if(@available(iOS 12.0, *)) 
        files = [fm contentsOfDirectoryAtPath:kThemeBundlePathiOS12  error:nil];
    else 
        files = [fm contentsOfDirectoryAtPath:kThemeBundlePathiOS11  error:nil];   
    NSMutableArray *listOfFiles = [files mutableCopy];

    return listOfFiles;
}

- (void)viewWillAppear:(BOOL)animated
  {
  	[self reload];
  	[super viewWillAppear:animated];
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

// Thanks to https://github.com/hbang/libcephei 
@implementation mdLatchkeyTwitterCell
- (CGFloat)preferredHeightForWidth:(CGFloat)width {
    // Return a custom cell height.
    return 29.0f;
}
-(id)initWithStyle:(UITableViewCellStyle)arg1 reuseIdentifier:(id)arg2 specifier:(PSSpecifier *)arg3 { //init method
 self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:arg2 specifier:arg3]; //call the super init method
 if (self) 
 {
    CGFloat size = 29.f;

	UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, [UIScreen mainScreen].scale);
	arg3.properties[@"iconImage"] = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

    twitterImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"Twitter" inBundle:[NSBundle bundleWithPath:@"/Library/PreferenceBundles/LatchKey.bundle"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];	
    twitterImageView.tintColor = [UIColor colorWithRed:0.886 green:0.882 blue:0.898 alpha:1.00];
	twitterImageView.backgroundColor = [UIColor clearColor];
	[twitterImageView setFrame:CGRectMake(0, 0, 16.0, 16.0)];
	self.accessoryView = twitterImageView;

	profileImageView = [[UIImageView alloc] initWithFrame:self.imageView.bounds];
    profileImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    profileImageView.backgroundColor = [UIColor clearColor];
    profileImageView.userInteractionEnabled = NO;
    profileImageView.clipsToBounds = YES;
    profileImageView.layer.cornerRadius = self.imageView.bounds.size.height/2;
    profileImageView.layer.masksToBounds = YES;

    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textColor = [UIColor colorWithRed:0.255 green:0.255 blue:0.259 alpha:1.00];

    [self.imageView addSubview:profileImageView];
    user = arg3.properties[@"twitterUsername"];
    [self loadProfileImage];

    self.detailTextLabel.numberOfLines = 1;
    self.detailTextLabel.text = [NSString stringWithFormat:@"@%@",user];
    self.detailTextLabel.textColor = [UIColor colorWithRed:0.255 green:0.255 blue:0.259 alpha:1.00];
 }
 return self;
}

-(void)loadProfileImage
{
	if(profileImageView.image){
		return;
	}

	static dispatch_queue_t queue;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		queue = dispatch_queue_create("ch.mdaus.twitterProfile", DISPATCH_QUEUE_SERIAL);
	});

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSError *error = nil;
		NSString *size = [UIScreen mainScreen].scale > 2 ? @"original" : @"bigger";
		NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/%@/profile_image?size=%@", user, size]]] returningResponse:nil error:&error];

		if (error) {
			return;
		}

		UIImage *image = [UIImage imageWithData:data];

		dispatch_async(dispatch_get_main_queue(), ^{
			profileImageView.image = image;
			profileImageView.layer.cornerRadius = self.imageView.bounds.size.height/2;
			profileImageView.layer.masksToBounds = YES;

			self.titleLabel.textColor = [UIColor colorWithRed:0.255 green:0.255 blue:0.259 alpha:1.00];
			self.detailTextLabel.textColor = [UIColor colorWithRed:0.255 green:0.255 blue:0.259 alpha:1.00];

		});
	});
}

@end