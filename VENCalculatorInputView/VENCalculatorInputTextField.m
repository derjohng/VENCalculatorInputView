#import "VENCalculatorInputTextField.h"
#import "VENMoneyCalculator.h"
#import "UITextField+VENCalculatorInputView.h"

@interface VENCalculatorInputTextField ()
@property (strong, nonatomic) VENMoneyCalculator *moneyCalculator;
@end

@implementation VENCalculatorInputTextField

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpInit];
    }
    return self;
}

- (void)awakeFromNib {
    [self setUpInit];
}

- (void)setUpInit {
    self.locale = [NSLocale currentLocale];

    VENCalculatorInputView *inputView = [VENCalculatorInputView new];
    inputView.delegate = self;
    inputView.locale = self.locale;
    self.inputView = inputView;

    VENMoneyCalculator *moneyCalculator = [VENMoneyCalculator new];
    moneyCalculator.locale = self.locale;
    self.moneyCalculator = moneyCalculator;

    [self addTarget:self action:@selector(venCalculatorTextFieldDidEndEditing) forControlEvents:UIControlEventEditingDidEnd];
}


#pragma mark - Properties

- (void)setLocale:(NSLocale *)locale {
    _locale = locale;
    VENCalculatorInputView *inputView = (VENCalculatorInputView *)self.inputView;
    inputView.locale = locale;
    self.moneyCalculator.locale = locale;
}


#pragma mark - UITextField

- (void)venCalculatorTextFieldDidEndEditing {
    NSString *textToEvaluate = [self trimExpressionString:self.text];
    if (textToEvaluate.length<=0) return;
    NSString *evaluatedString = [self.moneyCalculator evaluateExpression:textToEvaluate];
    if (evaluatedString) {
        self.text = evaluatedString;
    }
}


#pragma mark - VENCalculatorInputViewDelegate

- (void)calculatorInputView:(VENCalculatorInputView *)inputView didTapKey:(NSString *)key {
    if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        NSRange range = [self selectedNSRange];
        if (![self.delegate textField:self shouldChangeCharactersInRange:range replacementString:key]) {
            return;
        }
    }

    [self insertText:key];
    NSString *subString = [self.text substringToIndex:self.text.length - 1];
    if ([key isEqualToString:@"+"] ||
        [key isEqualToString:@"−"] ||
        [key isEqualToString:@"×"] ||
        [key isEqualToString:@"÷"]) {
        NSString *evaluatedString = [self.moneyCalculator evaluateExpression:[self trimExpressionString:subString]];
        if (evaluatedString) {
            self.text = [NSString stringWithFormat:@"%@%@", evaluatedString, key];
        } else {
            self.text = subString;
        }
    } else if ([key isEqualToString:[self decimalSeparator]]
               && [self.text length]>1
               ) {
        NSString *secondToLastCharacterString = [self.text substringWithRange:NSMakeRange([self.text length] - 2, 1)];
        if ([secondToLastCharacterString isEqualToString:[self decimalSeparator]]) {
            self.text = subString;
        }
    }
}

- (void)calculatorInputViewDidTapBackspace:(VENCalculatorInputView *)calculatorInputView {
    [self deleteBackward];
}


#pragma mark - Helpers

/**
 Removes any trailing operations and decimals.
 @param expressionString The expression string to trim
 @return The trimmed expression string
 */
- (NSString *)trimExpressionString:(NSString *)expressionString {
//    NSString *txt = self.text;
    NSString *txt = expressionString;
    while ([txt length] > 0) {
        NSString *lastCharacterString = [txt substringFromIndex:[txt length] - 1];
        if ([lastCharacterString isEqualToString:@"+"] ||
            [lastCharacterString isEqualToString:@"−"] ||
            [lastCharacterString isEqualToString:@"×"] ||
            [lastCharacterString isEqualToString:@"÷"] ||
            [lastCharacterString isEqualToString:self.decimalSeparator]) {
            txt = [txt substringToIndex:txt.length - 1];
            
        }
        else {
            break;
        }
    }
    return txt;
}

- (NSString *)replaceGroupSeperatorString:(NSString *)pStr {
    return [pStr stringByReplacingOccurrencesOfString:self.groupSeparator withString:@""];
}

- (NSString *)decimalSeparator {
    return [self.locale objectForKey:NSLocaleDecimalSeparator];
}

- (NSString *)groupSeparator {
    return [self.locale objectForKey:NSLocaleGroupingSeparator];
}

@end
