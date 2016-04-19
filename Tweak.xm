//#import <CommonCrypto/CommonCryptor.h>

#define WhoAmI @"Passregex"
#define DEBUG

#ifdef DEBUG
#define DebugLog(FORMATSTR, ...) NSLog(@"\e[32m[%@]\e[39m@%d %@", WhoAmI, __LINE__, [NSString stringWithFormat:FORMATSTR, ## __VA_ARGS__])
#else
#define DebugLog(...)
#endif

#define prefPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.coord-e.passregex.plist"]

%hook SBDeviceLockController

- (BOOL)attemptDeviceUnlockWithPassword: (NSString*)passcode appRequested: (BOOL)requested {

								if(requested)
																return %orig;

								UIAlertController *alert;

								if(![[NSFileManager defaultManager] fileExistsAtPath:prefPath])
																return %orig;

								NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
								NSString *realPass = (NSString*)prefs[@"pass"];
								NSString *regex = (NSString*)prefs[@"regex"];
								BOOL enabled = prefs[@"enabled"] == nil ? YES : [prefs[@"enabled"] boolValue];
								BOOL masterRealPass = prefs[@"enabled"] == nil ? YES : [prefs[@"enabled"] boolValue];

								if(![regex length])
																regex = @".*";

								if(!enabled)
																return %orig;

								if(![realPass length]) {
																alert = [UIAlertController alertControllerWithTitle:@"Passregex" message:@"Please enter your real passcode in setting." preferredStyle:UIAlertControllerStyleAlert];
																[alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
																[[%c(SpringBoard) sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
																return %orig;
								}

								NSError *error = nil;
								NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"(%@)",regex] options:0 error:&error];
								NSRange rangeOfFirstMatch = [regexp rangeOfFirstMatchInString:passcode options:0 range:NSMakeRange(0, [passcode length])];
								if(!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound,0))) {
																BOOL ok = %orig(realPass,requested);
																if(!ok) {
																								alert = [UIAlertController alertControllerWithTitle:@"Passregex" message:@"Your real passcode is wrong. Please enter again." preferredStyle:UIAlertControllerStyleAlert];
																								[alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
																								[[%c(SpringBoard) sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
																								return %orig;
																}
																return YES;
								}else{
																if(masterRealPass)
																								if(%orig(passcode,requested))
																																return YES;
								}

								return NO;
}

%end

/*****Not supported: Password Encryption
static void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
	NSData *rawPass = [(NSString*)prefs[@"pass"] dataUsingEncoding:NSUTF8StringEncoding];
	NSString *key = @"AAABBBCCCDDDYEAR";//[UIDevice currentDevice].identifierForVendor.UUIDString;
	DebugLog(@"UDID: %@",key);
	DebugLog(@"PASS: %@",(NSString*)prefs[@"pass"] );
	char keyPtr[kCCKeySizeAES256+1];
  bzero(keyPtr, sizeof(keyPtr));

  [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

  NSUInteger dataLength = [rawPass length];

  size_t bufferSize = dataLength + kCCBlockSizeAES128;
  void *buffer = malloc(bufferSize);

  size_t numBytesEncrypted = 0;
  CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                                                   kCCOptionPKCS7Padding | kCCOptionECBMode,
                                                                   keyPtr, kCCKeySizeAES256,
                                                                   NULL,
                                                                   [rawPass bytes], dataLength,
                                                                   buffer, bufferSize,
                                                                   &numBytesEncrypted);
  if (cryptStatus == kCCSuccess) {
           prefs[@"pass"] = [[NSString alloc] initWithData:[NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted] encoding:NSUTF8StringEncoding];
  } else {
		DebugLog(@"crypt error");
		return;
	}
  free(buffer);
	DebugLog(@"Encrypted: %@", prefs[@"pass"]);
	//if(![prefs writeToFile:DataPath atomically:YES])
	//							DebugLog(@"Failed to write plist");
}

%ctor
{
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &prefsChanged, CFSTR("com.coord-e.passregex.notify"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	%init;
}
*/
