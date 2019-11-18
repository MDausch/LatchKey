#include "mdFeedbackController.h"

#define kBundleIdentifier @"ch.mdaus.latchkey"
#define kTweakName @"LatchKey"


@implementation mdFeedbackControllerLatchkey
- (void)viewDidLoad {
    [super viewDidLoad];
    //UIImage *heartImage = [UIImage imageNamed:@"Heart.png" inBundle:self.bundle];
    UIBarButtonItem *submitBTN = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(submit)];
    [self.navigationItem setRightBarButtonItem:submitBTN];
    [self.navigationItem setTitle:@"Feedback"];

    CGFloat padding = ([UIScreen mainScreen].bounds.size.width - 336) / 2;

    self.selectLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding,100 + 0,336,15)];
    self.selectLabel.text = @"Type Of Feedback:";
    self.selectLabel.textColor = [UIColor grayColor];
    [self.selectLabel setFont:[UIFont systemFontOfSize:12]];
    [self.view addSubview:self.selectLabel];

    NSArray *itemArray = [NSArray arrayWithObjects: @"Bug Report", @"Feature Request", @"Comment", nil];
    self.type = [[UISegmentedControl alloc] initWithItems:itemArray];
    self.type.frame = CGRectMake(padding,self.selectLabel.frame.origin.y + 30,336,25);
    self.type.segmentedControlStyle = UISegmentedControlStylePlain;
    //[self.type addTarget:self action:@selector(adjustText:) forControlEvents: UIControlEventValueChanged];
    self.type.selectedSegmentIndex = 0;
    [self.view addSubview:self.type];

    self.emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding,self.type.frame.origin.y + 40,336,15)];
    self.emailLabel.text = @"Your Email:";
    self.emailLabel.textColor = [UIColor grayColor];
    [self.emailLabel setFont:[UIFont systemFontOfSize:12]];
    [self.view addSubview:self.emailLabel];

    self.emailField = [[UITextView alloc] initWithFrame:CGRectMake(padding,self.emailLabel.frame.origin.y + 30,336,25)];
    self.emailField.delegate = self;
    [self.emailField.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.25] CGColor]];
    [self.emailField.layer setBorderWidth:2.0];
    self.emailField.layer.cornerRadius = 5;
    self.emailField.clipsToBounds = YES;
    [self.view addSubview:self.emailField];

    self.commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding,self.emailField.frame.origin.y + 40,336,15)];
    self.commentsLabel.text = @"Details:";
    self.commentsLabel.textColor = [UIColor grayColor];
    [self.commentsLabel setFont:[UIFont systemFontOfSize:12]];
    [self.view addSubview:self.commentsLabel];

    self.commentsField = [[UITextView alloc] initWithFrame:CGRectMake(padding,self.commentsLabel.frame.origin.y + 30,336,150)];
    self.commentsField.delegate = self;
    [self.commentsField.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.25] CGColor]];
    [self.commentsField.layer setBorderWidth:2.0];
    self.commentsField.layer.cornerRadius = 5;
    self.commentsField.clipsToBounds = YES;
    [self.view addSubview:self.commentsField];
}

- (void)submit
{
  NSString *labelText = @"keyIzlBbFnbcXd5PS";
  NSString *type = @"";

  NSInteger errorChecking = self.type.selectedSegmentIndex;
  if(![[self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] || ![[self.commentsField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length])
    errorChecking = 3;

  NSCharacterSet *cset = [NSCharacterSet characterSetWithCharactersInString:@"@"];
  NSRange range = [self.emailField.text rangeOfCharacterFromSet:cset];
  if (range.location == NSNotFound)
    errorChecking = 3;

  switch(errorChecking){
    case(0):type = @"Bug"; break;
    case(1):type = @"Feature Request"; break;
    case(2):type = @"Comment"; break;
    default: {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:@"Your feedback could not be submitted. Make sure everything is filled out properly."
                                                         delegate:self
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
      [alert show];
      [alert release];
      return;
    }
  }


  NSString* dpkgQuery = [NSString stringWithFormat:@"dpkg -s %@ | grep Version", kBundleIdentifier];
  FILE *f = popen([dpkgQuery UTF8String], "r");
  NSMutableString *result = [NSMutableString stringWithCapacity:256];
  if (f != NULL) {
    char buffer[4096];

    // Read up to 4095 non-newline characters, then read and discard the newline
    int charsRead;
    do
    {
        if(fscanf(f, "%4095[^\n]%n%*c", buffer, &charsRead) == 1)
            [result appendFormat:@"%s", buffer];
        else
            break;
    } while(charsRead == 4095);

  }
  pclose(f);

  NSString *version = [result stringByReplacingOccurrencesOfString:@"Version: " withString:@""];


  NSDictionary *fields = [[NSDictionary alloc] initWithObjectsAndKeys:
                    kTweakName, @"Tweak",
                    type, @"Type",
                    version,@"Version",
                    @"TBD",@"Priority",
                    @"Not Started", @"Status",
                    self.commentsField.text, @"Bug Description",
                    self.emailField.text, @"From",
                    nil];

  NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:
                    fields, @"fields",
                     nil];
  NSError *error;
  NSData *postData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];

  //Air Table Post
  NSMutableURLRequest *airTable =[[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:@"https://api.airtable.com/v0/appcI2jhheCugx14a/Bugs%20%26%20Issues"]];
  [airTable setHTTPMethod:@"POST"];
  [airTable setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [airTable setValue:[NSString stringWithFormat:@"Bearer %@", labelText] forHTTPHeaderField:@"Authorization"];
  [airTable setHTTPBody:postData];
  [[NSURLConnection alloc] initWithRequest:airTable delegate:self];

  //Email Post
  NSMutableURLRequest *emailPost =[[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:@"https://script.google.com/macros/s/AKfycbwbuy2Ln7JJozDLt7qWjCbRngwV5O1PDPlwr9qhC-3VXEKVKVs/exec"]];
  [emailPost setHTTPMethod:@"POST"];
  [emailPost setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [emailPost setHTTPBody:postData];
  [[NSURLConnection alloc] initWithRequest:emailPost delegate:self];


  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                     message:@"Your feedback has been recorded!"
                                                     delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
  [alert show];
  [alert release];
  UINavigationController *navigationController = self.navigationController;
  [navigationController popViewControllerAnimated:YES];
}


@end
