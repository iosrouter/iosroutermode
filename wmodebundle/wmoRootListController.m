#import <Foundation/Foundation.h>
#import "wmoRootListController.h"

@implementation wmoRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

@end
