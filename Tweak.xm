#define WhoAmI @"Passregex"

#ifdef DEBUG
#define DebugLog(FORMATSTR, ...) NSLog(@"\e[32m[%@]\e[39m@%d %@", WhoAmI, __LINE__, [NSString stringWithFormat:FORMATSTR, ## __VA_ARGS__])
#else
#define DebugLog(...)
#endif

#define prefPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.coord-e.passregex.plist"]

@interface SpringBoard
+ (void)showAlertWithTitle: (NSString*)title message: (NSString*)message button: (NSString*)button cancel: (NSString*)cancel action: (void (^)(UIAlertAction *action))block;
@end

%hook SpringBoard

%new
+ (void)showAlertWithTitle: (NSString*)title message: (NSString*)message button: (NSString*)button cancel: (NSString*)cancel action: (void (^)(UIAlertAction *action))block
{
								UIViewController *base = [UIApplication sharedApplication].keyWindow.rootViewController;
								while (base.presentedViewController != nil && !base.presentedViewController.isBeingDismissed) {
																base = base.presentedViewController;
								}

								UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

								[alert addAction:[UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:nil]];
								if(block != nil)
									[alert addAction:[UIAlertAction actionWithTitle:button style:UIAlertActionStyleDefault handler:block]];

								[base presentViewController:alert animated:YES completion:nil];
}

%end

%hook SBDeviceLockController

- (BOOL)attemptDeviceUnlockWithPassword: (NSString*)passcode appRequested: (BOOL)requested {

								if(requested)
									return %orig;

								if(![[NSFileManager defaultManager] fileExistsAtPath:prefPath]) {
																[%c(SpringBoard) showAlertWithTitle: @"Passregex" message: @"Thank you for installing Passregex. Please go to Settings->Passregex." button: nil cancel: @"OK" action: nil];
																return %orig;
								}

								NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
								NSString *realPass = (NSString*)[prefs objectForKey:@"pass"];
								NSString *regex = (NSString*)[prefs objectForKey:@"regex"];

								if(![regex length])
																regex = @".*";

								if(![[prefs objectForKey:@"enabled"] boolValue])
																return %orig;

								if(![realPass length]) {
																[%c(SpringBoard) showAlertWithTitle: @"Passregex" message: @"Please enter your real passcode in setting." button: nil cancel: @"OK" action: nil];
																return %orig;
								}

								NSError *error = nil;
								NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"(%@)",regex] options:0 error:&error];
								NSRange rangeOfFirstMatch = [regexp rangeOfFirstMatchInString:passcode options:0 range:NSMakeRange(0, [passcode length])];
								if(!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound,0))) {
																BOOL ok = %orig(realPass,requested);
																if(!ok) {
																								[%c(SpringBoard) showAlertWithTitle: @"Passregex" message: @"Your real passcode is wrong. Please enter again." button: @"OK" cancel: @"Cancel" action: nil];
																								return %orig;
																}
																return YES;
								}else{
																if([[prefs objectForKey:@"master"] boolValue])
																								if(%orig(passcode,requested))
																																return YES;
								}

								return NO;
}

%end
