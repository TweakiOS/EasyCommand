
#import <stdio.h>
#import <string.h>
#import <dlfcn.h>
#import "../NSTask.h"
#define FLAG_PLATFORMIZE (1 << 1)

#define PLIST_PATH @"/var/mobile/Library/Preferences/"

NSString* GetPrefString(NSString *plist, NSString *key)
{
	return [[[NSDictionary dictionaryWithContentsOfFile:plist] valueForKey:key] stringValue];
}

NSUInteger numberOfProvidedModules()
{
  NSUInteger value = 1;

  NSString* numberOfProvidedModules = [[[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.tweakios.easycommand"] objectForKey:@"ModuleNumber"];
  if(numberOfProvidedModules)
  {
    value = (NSUInteger)numberOfProvidedModules.integerValue;
  }

  return value;
}

NSString* identifierForModuleAtIndex(NSUInteger index)
{
  NSString* identifier = [NSString stringWithFormat:@"com.tweakios.providedcommandmodule.%lu", (unsigned long)index];
  return identifier;
}


@interface CCUIModuleCollectionViewController : UIViewController
- (void)viewDidLoad;
- (void)dealloc;
- (void)startCommandModule:(NSNotification *)notification;
@end

%hook CCUIModuleCollectionViewController
- (void)viewDidLoad {
    %orig;
    for(int i=0; i<numberOfProvidedModules(); i++) {
        NSString *str = [NSString stringWithFormat:@"%@.run", identifierForModuleAtIndex(i)];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startCommandModule:) name:str object:nil];
    }
}

- (void)dealloc {
    %orig;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

%new
- (void)startCommandModule:(NSNotification *)notification { //this method is run upon receiving the notification that the user invoked my tweak
    NSLog(@"Smiley: %@\n", notification);
    NSString* plist = [notification.name stringByReplacingOccurrencesOfString:@".run" withString:@".plist"];
    NSString* cmd = GetPrefString([NSString stringWithFormat:@"%@%@", PLIST_PATH, plist], @"Command File");
    NSLog(@"Smiley: plist file %@, %@", plist, cmd);

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"CommandModule Running" message:cmd preferredStyle:UIAlertControllerStyleAlert];

    if (@available(iOS 13, *)) { //for some reason, Control Center does not update its traitCollection with iOS 13's dark mode, so I have to manually make my alert dark if necessary
        UIWindow *sb;
        NSArray *windows = [(UIApplication *)[[UIApplication sharedApplication] delegate] windows];
        for (UIWindow *win in windows) {
            if ([win isKindOfClass:%c(SBHomeScreenWindow)]) {
                sb = win;
                break;
            }
        }
        if (sb.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            alert.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
        }
    }
    
    [self presentViewController:alert animated:YES completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) { //must dispatch_async so the UI doesn't freeze while the script is running

            NSString *file = @"/var/mobile/Library/Preferences/com.tweakios.commandmodule.sh";
            BOOL isDirectory = NO;
            BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:&isDirectory];
            NSData *data = [cmd dataUsingEncoding:NSUTF8StringEncoding];
            if(!exists) {
                [[NSFileManager defaultManager] createFileAtPath:file contents:data attributes:nil];
            } else {
                [data writeToFile:file atomically:YES];
            }

            NSTask *task = [[NSTask alloc] init];
            task.launchPath = @"/usr/bin/commandmoduled";
            [task launch];
            [task waitUntilExit];

            dispatch_sync(dispatch_get_main_queue(), ^{ //once the script is finished, update the UI
                [alert dismissViewControllerAnimated:YES completion:nil];
            });
        });
    }];
}
%end
