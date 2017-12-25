//
//  ESCalandarView.m
//  EventStacks
//
//  Created by Joe Manto on 10/10/17.
//  Copyright © 2017 Joe Manto. All rights reserved.
//

#import "ESCalandarView.h"

@implementation ESCalandarView{
    //is the padding of the dayview on one given side
    int dayViewPaddingSize;
    NSInteger curYear;
    NSInteger curMonth;
    NSInteger curDay;
}
//defines the size of the button
#define ROUND_BUTTON_SIZE 35
//defines the horz gap of the buttons
#define DAY_HORZ_GAP 50
//defines the vert gap of the buttons
#define DAY_VERT_GAP 40


/*  @parm showDate (starting date) NSdate 
    @parm frame (given frame of the super view) CGRect
    sets up the day button array, some global variables and the SwipeGestures on the super view.
*/

- (id)initWithDate:(NSDate*)showDate withFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        
        _daysButtons = [[NSMutableArray alloc]init];
        dayViewPaddingSize = (self.frame.size.width - ((15+ROUND_BUTTON_SIZE)*6)-ROUND_BUTTON_SIZE)/2;
        [self configView:showDate withFrame:frame];
        
        UISwipeGestureRecognizer *rightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightHandler:)];
        [rightGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
        [self addGestureRecognizer:rightGestureRecognizer];
        
        UISwipeGestureRecognizer *leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftHandler:)];
        [leftGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
        [self addGestureRecognizer:leftGestureRecognizer];
    }
    return self;
}


/*  @parm showDate (starting date) NSDate 
    creates all the views to the showdate given in the constructor 
    and adds all the view to the superview
*/
-(void)configView:(NSDate*)showDate withFrame:(CGRect)frame{
    self.backgroundColor = [UIColor whiteColor];
    
    _components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:showDate];
    _components.day = 20;
    
    NSDateComponents * now = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    curDay = now.day;
    curMonth = now.month;
    curYear = now.year;
    
    _monthLabel = [[UILabel alloc]initWithFrame:CGRectMake(dayViewPaddingSize, -50, 200, 100)];
    [_monthLabel setText:[NSString stringWithFormat:@"%@",[self monthNumToString:_components.month]]];
    [_monthLabel setTextColor:[UIColor colorWithRed:255.f/255.f green:235.f/255.f blue:59/255.f alpha:1.f]];
    [_monthLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold"  size:24]];
    [_monthLabel setTextAlignment:NSTextAlignmentLeft];
    [self addSubview:_monthLabel];
    
    UILabel *weekDays = [[UILabel alloc]initWithFrame:CGRectMake(dayViewPaddingSize, 0, self.frame.size.width, 50)];
    NSString *daysOfTheWeekString = @" Sun      Mon       Tue      Wed       Thur        Fri       Sat";
    [weekDays setText:daysOfTheWeekString];
    [weekDays setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
    [weekDays setTextColor:[UIColor colorWithRed:66.f/255.f green:66.f/255.f blue:66.f/255.f alpha:1.f]];
    [weekDays setTextAlignment:NSTextAlignmentLeft];
    [self addSubview:weekDays];
    
    _daysView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height/2-90, self.frame.size.width, 215)];
    _daysView.backgroundColor = [UIColor whiteColor];
    
    [self fillDaysView:now withDaysView:_daysView withNumDays:[self getNumOfDaysForDate:(now)]];
    [self addSubview:_daysView];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    //[path moveToPoint:CGPointMake(20.0, 20.0)];
    [path moveToPoint:CGPointMake(40, 35.0)];
    [path addLineToPoint:CGPointMake(40, 35.0)];
    [path addLineToPoint:CGPointMake(370, 35.0)];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor colorWithRed:97.f/255.f green:97.f/255 blue:97.f/255.f alpha:1.f]CGColor];
    shapeLayer.lineWidth = 1.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    
    [self.layer addSublayer:shapeLayer];
    
}

/*  @parm recognizer UISwipeGestureRecognizer
    runs when the user swipes right
    checks for critical endpoint month changes
    also changes the year for [12/XX/XXXX] to [1/XX/XXXX] and [1/XX/XXX] to [12/XX/XXXX]
 */
-(void)swipeRightHandler:(UISwipeGestureRecognizer *)recognizer {
    NSLog(@"swiped right");
    if(_components.month == 12){
        _components.month = 1;
        _components.year++;
    }else{
        _components.month++;
    }
    [self removeMonthLabelForNewMonth:_components.month];
    [self switchMonthForNewMonth:_components];
   
}

/*  @parm recognizer UISwipeGestureRecognizer
    runs when the user swipes left
    checks for critical endpoint month changes 
    also changes the year for [12/XX/XXXX] to [1/XX/XXXX] and [1/XX/XXX] to [12/XX/XXXX]
*/
-(void)swipeLeftHandler:(UISwipeGestureRecognizer *)recognizer {
    NSLog(@"swiped left");
    if(_components.month == 1){
        _components.month = 12;
        _components.year--;
    }else{
        _components.month--;
    }
    [self removeMonthLabelForNewMonth:_components.month];
    [self switchMonthForNewMonth:_components];
}


/*  @parm components NSDateComponents 
    @parm daysView UIView 
    @parm numDays Int
    Fills the daysView with button at different x's and y's based on different gabs and offsets
    
    fetchs the offset of the first day
    sets an indicator to keep track of the current day on the x scale
    loop through 0 to the offset to fix the Xpos of the first week
    loop through all numDays and adding dayButtons 
    set xpos to endPoints and Ypos += 40 when the indicator is ready for another row
*/
-(void)fillDaysView:(NSDateComponents*)currentDate withDaysView:(UIView*)daysView withNumDays:(int) numDays{
    
    NSInteger firstWeekOffset = [self getDaysOffsetForDate:currentDate];
    NSInteger dayIndicator = firstWeekOffset;
    NSLog(@"%ld",(long)firstWeekOffset);
    int xEndPoints = dayViewPaddingSize;
    int posX = xEndPoints;
    int posY = 10;
    
    for(int i = 0;i<firstWeekOffset;i++){
         posX+=DAY_HORZ_GAP;
    }
    
    for(NSInteger i = 0;i<numDays;i++){
        [_daysButtons addObject:[self DayButton:CGRectMake(posX, posY, ROUND_BUTTON_SIZE, ROUND_BUTTON_SIZE) withDay:(int)i+1]];
        [daysView addSubview:[_daysButtons lastObject]];
        dayIndicator++;
        posX+=DAY_HORZ_GAP;
        if(dayIndicator > 6){
            posX = xEndPoints;
            posY += 40;
            dayIndicator = 0;
        }
       
    }
    
}

/*  @parm newMonth NSInteger
    Same Animation Process of switching the dayView but with the month label
*/

-(void)removeMonthLabelForNewMonth:(NSInteger)newMonth{
        [UIView animateWithDuration: 0.5 animations:^{
            [_monthLabel setFrame:CGRectMake(self.bounds.size.width+_monthLabel.frame.size.width/2, _monthLabel.frame.origin.y, _monthLabel.frame.size.width, _monthLabel.frame.size.height)];
        }completion:^(BOOL finished){
            [_monthLabel setText:[NSString stringWithFormat:@"%@",[self monthNumToString:newMonth]]];
            [_monthLabel setFrame:CGRectMake(0-_monthLabel.frame.size.width,_monthLabel.frame.origin.y,_monthLabel.frame.size.width,_monthLabel.frame.size.height)];
            [UIView animateWithDuration: 0.3 animations:^{
                [_monthLabel setFrame:CGRectMake(dayViewPaddingSize, _monthLabel.frame.origin.y, _monthLabel.frame.size.width, _monthLabel.frame.size.height)];
            }completion:^(BOOL finished){
                
            }];
        }];
    
}

/*  @parm _componments NSDateComponents
    Animates the buttons off the screen then on completion removes
    the buttons and creates a new button array. Then fills the array
    with new buttons based on the new month. moves the x pos of the view to the right off screen
    then Animates the return of the button view.
*/
-(void)switchMonthForNewMonth:(NSDateComponents*)date{
    
    [UIView animateWithDuration: 0.5 animations:^{
        [_daysView setFrame:CGRectMake(self.frame.size.width+_daysView.frame.size.width/2, _daysView.frame.origin.y, _daysView.frame.size.width, _daysView.frame.size.height)];
    }completion:^(BOOL finished){
        [self removeButtonsFromSuperView];
         [_daysView setFrame:CGRectMake(-_daysView.frame.size.width, _daysView.frame.origin.y, _daysView.frame.size.width, _daysView.frame.size.height)];
        [self fillDaysView:_components withDaysView:_daysView withNumDays:[self getNumOfDaysForDate:_components]];
        [UIView animateWithDuration: 0.5 animations:^{
            [_daysView setFrame:CGRectMake(0, _daysView.frame.origin.y, _daysView.frame.size.width, _daysView.frame.size.height)];
        }completion:^(BOOL finished){
            
        }];
    }];
  

}

/*  @parm CGRect frame of the button
    @parm int day number
 
    creates one button
       - loops through provided event date dates 
       - checkes if the day button is for the current date 
    returns the button
*/
-(UIButton*)DayButton:(CGRect)frame withDay:(int)dayNum{
   
    UIColor * matRed = [UIColor colorWithRed:244.f/255.f green:67.f/255.f blue:57.f/255.f alpha:1.f];
    UIColor * selColor =[UIColor colorWithRed:33.f/255.f green:150.f/255.f blue:243.f/255.f alpha:1.f];
    UIButton * dayButton = [[UIButton alloc]initWithFrame:frame];
    dayButton.backgroundColor = matRed;
    dayButton.layer.cornerRadius = ROUND_BUTTON_SIZE/2.0f;

    [dayButton setTitle:[NSString stringWithFormat:@"%d",dayNum] forState:UIControlStateNormal];
    if(dayNum == curDay &&  _components.month == curMonth && _components.year == curYear){
        
        CAShapeLayer *circleLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, ROUND_BUTTON_SIZE, ROUND_BUTTON_SIZE)];
        [circleLayer setPath:[path CGPath]];
        circleLayer.strokeColor = [[UIColor colorWithRed:255.f/255.f green:235.f/255.f blue:59/255.f alpha:1.f]CGColor];
        circleLayer.lineWidth = 2.0;
        circleLayer.fillColor = [[UIColor clearColor] CGColor];
        [dayButton.layer addSublayer:circleLayer];
    }
    
    //for(int i = 0;i<[_eventDays count];i++){
    // if((int)[_eventDays objectAtIndex:i] == dayNum){
    //  dayButton.backgroundColor = selColor;
    
    if(dayNum == 24 || dayNum == 11 || dayNum == 16){
            CAShapeLayer *circleLayer = [CAShapeLayer layer];
            UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-ROUND_BUTTON_SIZE/2+16, -ROUND_BUTTON_SIZE/2+16, 10, 10)];
            [circleLayer setPath:[path CGPath]];
            circleLayer.strokeColor = [selColor CGColor];
            circleLayer.lineWidth = 2.0;
            circleLayer.fillColor = [selColor CGColor];
            [dayButton.layer addSublayer:circleLayer];
    }
    //  break;
    // }
    //}
    [dayButton.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
    [dayButton addTarget:self action:@selector(dayButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [dayButton setTag:dayNum-1];
    return dayButton;
}

/*  @parm _componments NSDateComponents
    returns the number of days in the month given the month from dateComponents
*/
-(int)getNumOfDaysForDate:(NSDateComponents*)comp{
    NSCalendar *c = [NSCalendar currentCalendar];
    NSDate * currentDate = [c dateFromComponents:comp];
    NSRange days = [c rangeOfUnit:NSCalendarUnitDay
                           inUnit:NSCalendarUnitMonth
                          forDate:currentDate];
    NSLog(@"%d",(int)days.length);
    return (int)days.length;
}

/*  @parm _componments NSDateComponents
    return (int) the day of the week of the month given in the DateComponents
    Used as an offset for creating the Calendar
*/
-(NSInteger)getDaysOffsetForDate:(NSDateComponents*)date{
    //1-7 sunday - saturday
    [date setDay:1];

    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *weekdayComponents =
    [gregorian components:(NSCalendarUnitDay |
                           NSCalendarUnitWeekday) fromDate:[gregorian dateFromComponents:date]];

    //0-6 offset
    return [weekdayComponents weekday]-1;
}

-(void)dayButtonPressed:(UIButton *)dayButtonPressed
{
    NSInteger index = dayButtonPressed.tag;
    NSDateComponents * selectedDate = _components;
    [selectedDate setDay:index+1];
    
    //delegate method
    [self.delegate userDidSelectEvent:[[NSCalendar currentCalendar] dateFromComponents:_components]];
   
}

-(NSString*)monthNumToString:(NSInteger)num{
    switch(num){
        case 1:
            return @"January";
        case 2:
            return @"February";
        case 3:
            return @"March";
        case 4:
            return @"April";
        case 5:
            return @"May";
        case 6:
            return @"June";
        case 7:
            return @"July";
        case 8:
            return @"August";
        case 9:
            return @"September";
        case 10:
            return @"October";
        case 11:
            return @"November";
        case 12:
            return @"December";
        default:
            return @"null";
        
    }
}

-(void)removeButtonsFromSuperView{
    for(int i = 0;i<_daysButtons.count;i++){
        [_daysButtons[i] removeFromSuperview];
    }
    [_daysButtons removeAllObjects];
    _daysButtons = [[NSMutableArray alloc]init];
}

-(UIButton*)getbuttonForDay:(NSUInteger)day{
    return [_daysButtons objectAtIndex:day];
}

-(void)setEventDays:(NSArray *)eventDays{
    _eventDays = eventDays;
}
@end
