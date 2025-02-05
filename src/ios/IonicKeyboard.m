#import "IonicKeyboard.h"
// #import "UIWebViewExtension.h"
#import <Cordova/CDVAvailability.h>

@interface IonicKeyboard () <UIScrollViewDelegate>
@property (nonatomic, readwrite, assign) BOOL keyboardIsVisible;
@end

@implementation IonicKeyboard

@synthesize hideKeyboardAccessoryBar = _hideKeyboardAccessoryBar;
@synthesize disableScroll = _disableScroll;
//@synthesize styleDark = _styleDark;

- (void)pluginInitialize {

    Class wkClass = NSClassFromString([@[@"UI", @"Web", @"Browser", @"View"] componentsJoinedByString:@""]);
    wkMethod = class_getInstanceMethod(wkClass, @selector(inputAccessoryView));
    wkOriginalImp = method_getImplementation(wkMethod);
    Class uiClass = NSClassFromString([@[@"WK", @"Content", @"View"] componentsJoinedByString:@""]);
    uiMethod = class_getInstanceMethod(uiClass, @selector(inputAccessoryView));
    uiOriginalImp = method_getImplementation(uiMethod);
    nilImp = imp_implementationWithBlock(^(id _s) {
        return nil;
    });

    //set defaults
    self.hideKeyboardAccessoryBar = YES;
    self.disableScroll = NO;
    //self.styleDark = NO;

    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    __weak IonicKeyboard* weakSelf = self;
    _keyboardShowObserver = [nc addObserverForName:UIKeyboardWillShowNotification
                               object:nil
                               queue:[NSOperationQueue mainQueue]
                               usingBlock:^(NSNotification* notification) {
                                    if (!self.keyboardIsVisible) {

                                        CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
                                        keyboardFrame = [self.viewController.view convertRect:keyboardFrame fromView:nil];

                                        [weakSelf.commandDelegate evalJs:[NSString stringWithFormat:@"cordova.plugins.KeyboardUtils.isVisible = true; cordova.fireWindowEvent('native.keyboardshow', { 'keyboardHeight': %@ }); ", [@(keyboardFrame.size.height) stringValue]]];

                                        //deprecated
                                        [weakSelf.commandDelegate evalJs:[NSString stringWithFormat:@"cordova.fireWindowEvent('native.showkeyboard', { 'keyboardHeight': %@ }); ", [@(keyboardFrame.size.height) stringValue]]];
                                        self.keyboardIsVisible = true;
                                    }
                               }];

    _keyboardHideObserver = [nc addObserverForName:UIKeyboardWillHideNotification
                               object:nil
                               queue:[NSOperationQueue mainQueue]
                               usingBlock:^(NSNotification* notification) {
                                    if (self.keyboardIsVisible) {
                                        [weakSelf.commandDelegate evalJs:@"cordova.plugins.KeyboardUtils.isVisible = false; cordova.fireWindowEvent('native.keyboardhide'); "];

                                        //deprecated
                                        [weakSelf.commandDelegate evalJs:@"cordova.fireWindowEvent('native.hidekeyboard'); "];
                                        self.keyboardIsVisible = false;
                                    }
                               }];
}

- (BOOL)disableScroll {
    return _disableScroll;
}

- (void)setDisableScroll:(BOOL)disableScroll {
    if (disableScroll == _disableScroll) {
        return;
    }
    if (disableScroll) {
        self.webView.scrollView.scrollEnabled = NO;
        self.webView.scrollView.delegate = self;
    }
    else {
        self.webView.scrollView.scrollEnabled = YES;
        self.webView.scrollView.delegate = nil;
    }

    _disableScroll = disableScroll;
}

//keyboard swizzling inspired by:
//https://github.com/cjpearson/cordova-plugin-keyboard/

- (BOOL)hideKeyboardAccessoryBar {
    return _hideKeyboardAccessoryBar;
}

- (void)setHideKeyboardAccessoryBar:(BOOL)hideKeyboardAccessoryBar {
    if (hideKeyboardAccessoryBar == _hideKeyboardAccessoryBar) {
        return;
    }

    if (hideKeyboardAccessoryBar) {
        method_setImplementation(wkMethod, nilImp);
        method_setImplementation(uiMethod, nilImp);
    } else {
        method_setImplementation(wkMethod, wkOriginalImp);
        method_setImplementation(uiMethod, uiOriginalImp);
    }

    _hideKeyboardAccessoryBar = hideKeyboardAccessoryBar;
}

/*
- (BOOL)styleDark {
    return _styleDark;
}

- (void)setStyleDark:(BOOL)styleDark {
    if (styleDark == _styleDark) {
        return;
    }
    if (styleDark) {
        self.webView.styleDark = YES;
    }
    else {
        self.webView.styleDark = NO;
    }

    _styleDark = styleDark;
}
*/


/* ------------------------------------------------------------- */

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView setContentOffset: CGPointZero];
}

/* ------------------------------------------------------------- */

- (void)dealloc {
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];

    [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

/* ------------------------------------------------------------- */

- (void) disableScroll:(CDVInvokedUrlCommand*)command {
    if (!command.arguments || ![command.arguments count]){
      return;
    }
    id value = [command.arguments objectAtIndex:0];
    if (value != [NSNull null]) {
      self.disableScroll = [value boolValue];
    }
}

- (void) hideKeyboardAccessoryBar:(CDVInvokedUrlCommand*)command {
    if (!command.arguments || ![command.arguments count]){
        return;
    }
    id value = [command.arguments objectAtIndex:0];
    if (value != [NSNull null]) {
        self.hideKeyboardAccessoryBar = [value boolValue];
    }
}

- (void) close:(CDVInvokedUrlCommand*)command {
    [self.webView endEditing:YES];
}

- (void) show:(CDVInvokedUrlCommand*)command {
    NSLog(@"Showing keyboard not supported in iOS due to platform limitations.");
}

/*
- (void) styleDark:(CDVInvokedUrlCommand*)command {
    if (!command.arguments || ![command.arguments count]){
      return;
    }
    id value = [command.arguments objectAtIndex:0];

    self.styleDark = [value boolValue];
}
*/

@end

