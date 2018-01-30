#import <Foundation/Foundation.h>
#import <UIKit/UiKit.h>

@interface SBUIProudLockIconView : UIView
-(void)_configureAutolayoutFlagsNeedingLayout:(BOOL)arg1;
@end

//Override Face ID View
%hook SBUIProudLockIconView
-(void)layoutSubviews{
    %orig; //Call Original layout subviews to set up everything

    //Now we override the frame to move the glyph and shrink it down
    self.frame = CGRectMake(35,10,12,20);

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
                        withObject:@YES];

}

//We need a this so we can call it properly with perform selector
-(void)_configureAutolayoutFlagsNeedingLayout:(BOOL)arg1{
    %orig(arg1); //We dont need to modify anything, call original method
}
%end

//Override Carrier Name
%hook SBStatusBarStateAggregator
- (id)_sbCarrierNameForOperator:(id)arg1 {
	return @" "; //We cant have the carrier enabled to show the glyph
}
%end;
