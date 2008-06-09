//
// cocos2d for iphone
// InstantAction
//


#import <UIKit/UIKit.h>

#import "Action.h"

//
// InstantAction
//
@interface InstantAction : Action <NSCopying>
{
	double duration;
}
@property (readonly,assign) double duration;

-(void) step;
-(BOOL) isDone;
@end

//
// Show
//
@interface Show : InstantAction
{
}
@end

//
// Hide
//
@interface Hide : InstantAction
{
}
@end

//
// ToggleVisibility
//
@interface ToggleVisibility : InstantAction
{
}
@end

//
// Place
//
@interface Place : InstantAction <NSCopying>
{
	CGPoint position;
}
+(id) actionWithPosition: (CGPoint) pos;
-(id) initWithPosition: (CGPoint) pos;
@end

//
// CallFunc
//
@interface CallFunc : InstantAction <NSCopying>
{
	NSInvocation *invocation;
}
+(id) actionWithTarget: (id) receiver selector:(SEL) callback;
-(id) initWithTarget: (id) receiver selector:(SEL) callback;
@end
