//
//  ESCalandarView.h
//  EventStacks
//
//  Created by Joe Manto on 10/10/17.
//  Copyright © 2017 Joe Manto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ESCalandarViewDelegate <NSObject>
- (void) userDidSelectEvent:(NSDate*)date;
@end

@interface ESCalandarView : UIView

- (id)initWithDate:(NSDate*)currentDate withFrame:(CGRect)frame;
@property (nonatomic, weak) id <ESCalandarViewDelegate> delegate;

@property (nonatomic) NSDateComponents *components;
@property (nonatomic) NSMutableArray * daysButtons;
@property (nonatomic) UIView * daysView;
@property (nonatomic) UILabel *monthLabel;
@property (nonatomic) NSArray* eventDays;



@end
