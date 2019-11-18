#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface mdFeedbackControllerLatchkey : PSListController <UITextViewDelegate>
@property (nonatomic,retain) UISegmentedControl *type;
@property (nonatomic,retain) UITextView *commentsField;
@property (nonatomic,retain) UITextView *emailField;
@property (nonatomic,retain) UILabel *selectLabel;
@property (nonatomic,retain) UILabel *emailLabel;
@property (nonatomic,retain) UILabel *commentsLabel;
@end
