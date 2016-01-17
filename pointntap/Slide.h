//
//  Slide.h
//  pointntap
//
//  Created by James Hornitzky on 9/01/2016.
//  Copyright © 2016 James Hornitzky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Slide : NSObject

@property(nonatomic,strong) NSString *uuid;
@property(assign) bool isStart;
@property(nonatomic,strong) NSString *text;
@property(nonatomic,strong) NSString *imgPath;
@property(nonatomic,strong) UIImage *img;
@property(nonatomic,strong) NSMutableArray *points;


@end
