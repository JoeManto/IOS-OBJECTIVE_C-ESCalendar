# (IOS-OBJECTIVE_C-ESCalendar)
optimal template example of an Objective C working calendar using NSDate and NSDateComponents with custom data object inputs
<br>
<br>
![Calendar View](https://github.com/JoeManto/IOS-OBJECTIVE_C-ESCalendar/blob/master/md_res/s1.png)
<br>
<br>
This template has 'UIViewAnimations' on both the header month label and on the calendar view itself.

**UIAnimations-**:+1:
___

```objc
-(void)removeMonthLabelForNewMonth:(NSInteger)newMonth{
[UIView animateWithDuration: 0.5 animations:^{
[_monthLabel  setFrame:CGRectMake(self.bounds.size.width+_monthLabel.frame.size.width/2, _monthLabel.frame.origin.y, _monthLabel.frame.size.width, _monthLabel.frame.size.height)];

}completion:^(BOOL finished){

[_monthLabel setText:[NSString stringWithFormat:@"%@",[self monthNumToString:newMonth]]];
[_monthLabel setFrame:CGRectMake(0-_monthLabel.frame.size.width,_monthLabel.frame.origin.y,_monthLabel.frame.size.width,_monthLabel.frame.size.height)];

[UIView animateWithDuration: 0.3 animations:^{

[_monthLabel setFrame:CGRectMake(dayViewPaddingSize, _monthLabel.frame.origin.y, _monthLabel.frame.size.width, _monthLabel.frame.size.height)];

}completion:^(BOOL finished){

}];
}];
```

**The Methods**
___
```objc
-(id)initWithDate:(NSDate*)showDate withFrame:(CGRect)frame
-(void)configView:(NSDate*)showDate withFrame:(CGRect)frame
-(void)swipeRightHandler:(UISwipeGestureRecognizer *)recognizer
-(void)swipeLeftHandler:(UISwipeGestureRecognizer *)recognizer 
-(void)fillDaysView:(NSDateComponents*)currentDate withDaysView:(UIView*)daysView withNumDays:(int) numDays
-(void)removeMonthLabelForNewMonth:(NSInteger)newMonth
-(void)switchMonthForNewMonth:(NSDateComponents*)date
-(UIButton*)DayButton:(CGRect)frame withDay:(int)dayNum
-(int)getNumOfDaysForDate:(NSDateComponents*)comp
-(NSInteger)getDaysOffsetForDate:(NSDateComponents*)date
-(void)dayButtonPressed:(UIButton *)dayButtonPressed
-(NSString*)monthNumToString:(NSInteger)num
-(void)removeButtonsFromSuperView
-(UIButton*)getbuttonForDay:(NSUInteger)day
-(void)setEventDays:(NSArray *)eventDays
```
