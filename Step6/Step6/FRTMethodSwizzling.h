#import <Foundation/Foundation.h>

extern void FRTSwizzleInstanceMethod(Class class, SEL originalSelector, SEL alternativeSelector);
extern void FRTSwizzleClassMethod(Class class, SEL originalSelector, SEL alternativeSelector);
