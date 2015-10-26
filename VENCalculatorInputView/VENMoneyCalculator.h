#import <Foundation/Foundation.h>

@interface VENMoneyCalculator : NSObject

@property (strong, nonatomic) NSLocale *locale;
@property (nonatomic) NSUInteger digits;


/**
 * Evaluates a mathematical expression containing +, −, ×, and ÷.
 * @param expression The expression to evaluate
 * @return The evaluated expression. Returns nil if the expression is invalid.
 */
- (NSString *)evaluateExpression:(NSString *)expression;
- (NSNumberFormatter *)numberFormatter;

@end
