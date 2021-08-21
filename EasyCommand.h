#import <ControlCenterUIKit/CCUIToggleModule.h>
#import "CCSModuleProvider.h"
#import "ProvidedCommandModule.h"

@interface EasyCommand : NSObject <CCSModuleProvider>
{
  NSMutableDictionary* _moduleInstancesByIdentifier;
}


@end
