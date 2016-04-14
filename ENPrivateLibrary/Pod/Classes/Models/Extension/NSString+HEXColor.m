//
//  NSString+HEXColor.m
//  Pods
//
//  Created by Veracruz on 16/4/14.
//
//

#import "NSString+HEXColor.h"



@implementation NSString (HEXColor)

- (UIColor *)colorFromHEXString {
    if (self.length != 6) {
        return nil;
    }
    
    NSArray <NSNumber *> *numbers = [self numbersFromHEXString];
    
    return [UIColor colorWithRed:(numbers[0].unsignedIntegerValue * 16 + numbers[1].unsignedIntegerValue) / 255.0
                           green:(numbers[2].unsignedIntegerValue * 16 + numbers[3].unsignedIntegerValue) / 255.0
                            blue:(numbers[4].unsignedIntegerValue * 16 + numbers[5].unsignedIntegerValue) / 255.0
                           alpha:1.0];
}

- (NSArray <NSNumber *> *)numbersFromHEXString {

    NSDictionary <NSString *, NSNumber *> *HEXMap = @{
                                                      @"0": @(0),
                                                      @"1": @(1),
                                                      @"2": @(2),
                                                      @"3": @(3),
                                                      @"4": @(4),
                                                      @"5": @(5),
                                                      @"6": @(6),
                                                      @"7": @(7),
                                                      @"8": @(8),
                                                      @"9": @(9),
                                                      @"A": @(10),
                                                      @"B": @(11),
                                                      @"C": @(12),
                                                      @"D": @(13),
                                                      @"E": @(14),
                                                      @"F": @(15),
                                                      @"a": @(10),
                                                      @"b": @(11),
                                                      @"c": @(12),
                                                      @"d": @(13),
                                                      @"e": @(14),
                                                      @"f": @(15),
                                                     };
    NSMutableArray *numbers = [NSMutableArray array];
    for (NSInteger i = 0; i < 6; i++) {
        NSString *numberString = [self substringWithRange:NSMakeRange(i, 1)];
        [numbers addObject:HEXMap[numberString]];
    }
    return [numbers copy];
    
}

@end
