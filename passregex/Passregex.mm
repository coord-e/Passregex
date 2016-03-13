#import <Preferences/Preferences.h>

@interface PassregexListController: PSListController {
}
@end

@implementation PassregexListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Passregex" target:self];
	}
	return _specifiers;
}
- (void)github:(id)specifier {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/coord-e/passregex/"]];
}
- (void)twitter:(id)specifier {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/coord_e/"]];
}
@end

// vim:ft=objc
