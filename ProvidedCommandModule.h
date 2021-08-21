#import <ControlCenterUIKit/CCUIToggleModule.h>

@interface ProvidedCommandModule : CCUIToggleModule
{
  BOOL _selected;
}
@property (nonatomic, retain) NSString* settingsIdentifier;

@end
