#import "EasyCommand.h"
#import "ProvidedCommandModuleRootListController.h"

@implementation EasyCommand

- (instancetype)init
{
  self = [super init];
  _moduleInstancesByIdentifier = [NSMutableDictionary new];
  return self;
}

- (NSUInteger)numberOfProvidedModules
{
  NSUInteger value = 1;

  NSString* numberOfProvidedModules = [[[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.tweakios.easycommand"] objectForKey:@"ModuleNumber"];
  if(numberOfProvidedModules)
  {
    value = (NSUInteger)numberOfProvidedModules.integerValue;
  }

  return value;
}

- (NSString*)identifierForModuleAtIndex:(NSUInteger)index
{
  NSString* identifier = [NSString stringWithFormat:@"com.tweakios.providedcommandmodule.%lu", (unsigned long)index];
  return identifier;
}

- (id)moduleInstanceForModuleIdentifier:(NSString*)identifier
{
  ProvidedCommandModule* module = [_moduleInstancesByIdentifier objectForKey:identifier];
  if(!module)
  {
    module = [[ProvidedCommandModule alloc] init];
    module.settingsIdentifier = identifier;
    [_moduleInstancesByIdentifier setObject:module forKey:identifier];
  }

  return module;
}

- (NSString*)displayNameForModuleIdentifier:(NSString*)identifier
{
  NSString* numString = [identifier stringByReplacingOccurrencesOfString:@"com.tweakios.providedcommandmodule." withString:@""];
  NSString* displayName = [NSString stringWithFormat:@"Provided Command Module %i", [numString intValue]+1];
  return displayName;
}

- (BOOL)providesListControllerForModuleIdentifier:(NSString*)identifier
{
  return YES;
}

- (id)listControllerForModuleIdentifier:(NSString*)identifier
{
  ProvidedCommandModuleRootListController* moduleListController = [[ProvidedCommandModuleRootListController alloc] init];
  moduleListController.settingsIdentifier = identifier;
  moduleListController.displayName = [self displayNameForModuleIdentifier:identifier];
  return moduleListController;
}

- (UIImage*)settingsIconForModuleIdentifier:(NSString*)identifier
{
  return [UIImage imageNamed:@"Icon" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}

@end

void reloadCommandsNotificationReceived(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"easycommand/ReloadCommands" object:nil];
}

__attribute__((constructor))
static void init(void)
{
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, reloadCommandsNotificationReceived, CFSTR("com.tweakios.easycommand/ReloadCommands"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}

