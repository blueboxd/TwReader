//
//  ClickableImageView.m
//  TwReader
//
//  Created by bluebox on 19/05/25.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import "ClickableImageView.h"


@implementation ClickableImageView

- (void)resetCursorRects {
	[self addCursorRect:[self bounds] cursor:[NSCursor pointingHandCursor]];
}

- (void) mouseDown:(NSEvent *)theEvent {
	[super sendAction:[super action] to:[super target]];
}

@end
