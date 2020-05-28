#import <Cephei/HBPreferences.h>
#import "MeteoroidClasses.h"
#import "NSTask.h"

#define LD_DEBUG NO

  /*
   * Preference variables
   */
  static int wallpaperMode;
  static NSDate *fireTime;
  static int imageSource;

  /*
   * Global variables
   */
  BOOL meteoroidInitalAlertShown;
  BOOL savedInitalWallpaper;
  BOOL parallax;
  BOOL timerEnabled;
  int timerInterval;
  NSString *currentImageURL;
  NSString *currentShownImageURL;
  PCSimpleTimer *timer;
  SBHomeScreenViewController *HomeScreenViewController;

  extern "C" CFArrayRef CPBitmapCreateImagesFromData(CFDataRef cpbitmap, void*, int, void*);

  /*
  * Shows inital alert after install. Allows user to save current wallpapers if they want
  * Thanks! - Lacertosus' "Stellae" (https://github.com/LacertosusRepo)
  */
%hook SpringBoard
  -(void)applicationDidFinishLaunching:(id)arg1 {
    %orig;

    NSMutableDictionary *saveddata = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/User/Library/Preferences/com.jeffresc.meteoroidsaveddata.plist"];
    meteoroidInitalAlertShown = [[saveddata objectForKey:@"meteoroidInitalAlertShown"] boolValue];

    if(!meteoroidInitalAlertShown) {
      [saveddata setObject:[NSNumber numberWithBool:1] forKey:@"meteoroidInitalAlertShown"];
      [saveddata writeToFile:@"/User/Library/Preferences/com.jeffresc.meteoroidsaveddata.plist" atomically:YES];

      UIAlertController *meteoroidInitalAlert = [UIAlertController alertControllerWithTitle:@"Meteoroid" message:@"Thanks for installing Meteoroid! Would you like to backup your wallpaper(s) to your photo library?" preferredStyle:UIAlertControllerStyleAlert];
      UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Sure!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        if([[NSFileManager defaultManager] fileExistsAtPath:@"/User/Library/SpringBoard/OriginalHomeBackground.cpbitmap"]) {
          NSData *homeData = [NSData dataWithContentsOfFile:@"/User/Library/SpringBoard/OriginalHomeBackground.cpbitmap"];
          CFArrayRef homeArrayRef = CPBitmapCreateImagesFromData((__bridge CFDataRef)homeData, NULL, 1, NULL);
          NSArray *homeArray = (__bridge NSArray*)homeArrayRef;
          UIImage *homeWallpaper = [[UIImage alloc] initWithCGImage:(__bridge CGImageRef)(homeArray[0])];
          UIImageWriteToSavedPhotosAlbum(homeWallpaper, nil, nil, nil);
          CFRelease(homeArrayRef);

        } if([[NSFileManager defaultManager] fileExistsAtPath:@"/User/Library/SpringBoard/OriginalLockBackground.cpbitmap"]) {
          NSData *lockData = [NSData dataWithContentsOfFile:@"/User/Library/SpringBoard/OriginalLockBackground.cpbitmap"];
          CFArrayRef lockArrayRef = CPBitmapCreateImagesFromData((__bridge CFDataRef)lockData, NULL, 1, NULL);
          NSArray *lockArray = (__bridge NSArray*)lockArrayRef;
          UIImage *lockWallpaper = [[UIImage alloc] initWithCGImage:(__bridge CGImageRef)(lockArray[0])];
          UIImageWriteToSavedPhotosAlbum(lockWallpaper, nil, nil, nil);
          CFRelease(lockArrayRef);
        }
      }];
      UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No Thanks" style:UIAlertActionStyleCancel handler:nil];

      [meteoroidInitalAlert addAction:confirmAction];
      [meteoroidInitalAlert addAction:cancelAction];
      [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:meteoroidInitalAlert animated:YES completion:nil];
    }
  }
%end

  /*
   * Main chunk of it all. Creates timer on init, gets the current time and fire time and converts them to NSDates with time only.
   * Once the timer fires it calls setSpaceWallpaper, invalidates the timer and creates another checking if the current time is
   * within an hour of the fireTime.
   */
%hook SBHomeScreenViewController
%property (nonatomic, retain) PCSimpleTimer *apolloTimer;

  -(id)initWithNibName:(id)arg1 bundle:(id)arg2 {
    [self createTimer];
    return HomeScreenViewController = %orig;
  }

%new
  /*
   * Thank you Tateu, very cool!
   * https://github.com/tateu/TimerExample/blob/master/Tweak.xm
   */
  -(void)createTimer {
    if (timerEnabled) {
      if(LD_DEBUG) {
        timerInterval = 30;
      } else {
        timerInterval = 1800;
      }

      if(timer) {
        [timer invalidate];
        [self.apolloTimer invalidate];

        timer = nil;
        self.apolloTimer = nil;
      }

      timer = [[%c(PCSimpleTimer) alloc] initWithTimeInterval:timerInterval serviceIdentifier:@"com.jeffresc.meteoroid" target:self selector:@selector(setSpaceWallpaper) userInfo:nil];
      timer.disableSystemWaking = NO;
      [timer scheduleInRunLoop:[NSRunLoop mainRunLoop]];
      self.apolloTimer = timer;

      if(LD_DEBUG) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        NSLog(@"Timer - %@", timer);
        NSLog(@"Timer isValid - %d", [timer isValid]);
        NSLog(@"fireTime - %@", [dateFormatter stringFromDate:fireTime]);
      }
    }
  }

%new
  -(void)setSpaceWallpaper {
    NSMutableDictionary *saveddata = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/User/Library/Preferences/com.jeffresc.meteoroidsaveddata.plist"];
    fireTime = [saveddata objectForKey:@"fireTime"];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *fireTimeComponents = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:fireTime];
    fireTimeComponents.hour = fireTimeComponents.hour + 1;
    NSDate *fireTimeGate = [calendar dateFromComponents:fireTimeComponents];

		NSDateComponents *components = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:[NSDate date]];
		NSDate *currentDate = [calendar dateFromComponents:components];

    if((([currentDate compare:fireTime] == NSOrderedDescending) && ([currentDate compare:fireTimeGate] == NSOrderedAscending))) {
      CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.jeffresc.meteoroid-runCommand"), nil, nil, true);
    }
    if (![self.apolloTimer isValid]) {
      [self createTimer];
    }
    if(LD_DEBUG) {
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateFormat:@"HH:mm:ss"];
      NSLog(@"fireTime - %@ || Current Date - %@ || fireTimeGate - %@", [dateFormatter stringFromDate:fireTime], [dateFormatter stringFromDate:currentDate], [dateFormatter stringFromDate:fireTimeGate]);
    }
  }
%end

/*
 * Runs the update command using meteoroidcli
 */
static void runUpdateCommand() {
  // Set locationFlag
  char locationFlag;
  switch (wallpaperMode) {
    case 0:
      locationFlag = 'b';
      break;
    case 1:
      locationFlag = 'h';
      break;
    case 2:
      locationFlag = 'l';
      break;
  }

  NSTask *task = [[NSTask alloc] init];
  NSLog(@"cmd-wallpaperMode: %d", wallpaperMode);
  NSLog(@"cmd-parallax: %d", parallax);
  NSLog(@"cmd-imageSource: %d", imageSource);
  NSLog(@"cmd-timerEnabled: %d", timerEnabled);
  [task setLaunchPath:@"/usr/bin/meteoroidcli"];
  NSLog(@"/usr/bin/meteoroidcli -s %@ -%c", [NSString stringWithFormat:@"%d", imageSource], locationFlag);
  if (parallax) {
    [task setArguments:[NSArray arrayWithObjects:@"-s", [NSString stringWithFormat:@"%d", imageSource], [NSString stringWithFormat:@"-%c", locationFlag], @"-p", nil]];
  } else {
    [task setArguments:[NSArray arrayWithObjects:@"-s", [NSString stringWithFormat:@"%d", imageSource], [NSString stringWithFormat:@"-%c", locationFlag], nil]];
  }
  [task launch];
}

  /*
   * Saves the current wallpapers based on where the space image is applied to
   *
   * wallpaperMode: 1 = homescreen, 2 = lockscreen, 0 = both
   */
static void saveImage() {
  if((wallpaperMode == 1 || wallpaperMode == 0) && [[NSFileManager defaultManager] fileExistsAtPath:@"/User/Library/SpringBoard/OriginalHomeBackground.cpbitmap"]) {
    NSData *homeData = [NSData dataWithContentsOfFile:@"/User/Library/SpringBoard/OriginalHomeBackground.cpbitmap"];
    CFArrayRef homeArrayRef = CPBitmapCreateImagesFromData((__bridge CFDataRef)homeData, NULL, 1, NULL);
    NSArray *homeArray = (__bridge NSArray*)homeArrayRef;
    UIImage *homeWallpaper = [[UIImage alloc] initWithCGImage:(__bridge CGImageRef)(homeArray[0])];
    UIImageWriteToSavedPhotosAlbum(homeWallpaper, nil, nil, nil);
    CFRelease(homeArrayRef);

  } if((wallpaperMode == 2 || wallpaperMode == 0) && [[NSFileManager defaultManager] fileExistsAtPath:@"/User/Library/SpringBoard/OriginalLockBackground.cpbitmap"]) {
    NSData *lockData = [NSData dataWithContentsOfFile:@"/User/Library/SpringBoard/OriginalLockBackground.cpbitmap"];
    CFArrayRef lockArrayRef = CPBitmapCreateImagesFromData((__bridge CFDataRef)lockData, NULL, 1, NULL);
    NSArray *lockArray = (__bridge NSArray*)lockArrayRef;
    UIImage *lockWallpaper = [[UIImage alloc] initWithCGImage:(__bridge CGImageRef)(lockArray[0])];
    UIImageWriteToSavedPhotosAlbum(lockWallpaper, nil, nil, nil);
    CFRelease(lockArrayRef);
  }
}

  /*
   * Loads my preferences. If saveddata plist has less objects than there are suppossed to be, it is reset.
   */
static void loadPrefs() {
  // Preferences
  HBPreferences *file = [[HBPreferences alloc] initWithIdentifier:@"com.jeffresc.meteoroidprefs"];
  wallpaperMode = [([file objectForKey:@"wallpaperMode"] ?: @(2)) intValue];
  parallax = [([file objectForKey:@"parallax"] ?: @(NO)) boolValue];
  imageSource = [([file objectForKey:@"imageSource"] ?: @(0)) intValue];
  timerEnabled = [([file objectForKey:@"timerEnabled"] ?: @(NO)) boolValue];
  NSLog(@"wallpaperMode: %d", wallpaperMode);
  NSLog(@"parallax: %d", parallax);
  NSLog(@"imageSource: %d", imageSource);
  NSLog(@"timerEnabled: %d", timerEnabled);
  // Saved data
  NSMutableDictionary *saveddata = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/User/Library/Preferences/com.jeffresc.meteoroidsaveddata.plist"];
  if(!saveddata || [saveddata count] < 4) {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:[NSDate date]];
    NSDate *defaultTime = [[NSCalendar currentCalendar] dateFromComponents:components];
    saveddata = [[NSMutableDictionary alloc] init];
    [saveddata setObject:defaultTime forKey:@"fireTime"];
    [saveddata setObject:@"" forKey:@"currentShownImageURL"];
    [saveddata setObject:@"" forKey:@"currentImageURL"];
    [saveddata setObject:[NSNumber numberWithBool:0] forKey:@"meteoroidInitalAlertShown"];
    [saveddata writeToFile:@"/User/Library/Preferences/com.jeffresc.meteoroidsaveddata.plist" atomically:YES];
  }
}

  /*
   * Setup notifications
   */
%ctor {
  @autoreleasepool {
    loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)runUpdateCommand, CFSTR("com.jeffresc.meteoroid-runCommand"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)saveImage, CFSTR("com.jeffresc.meteoroidprefs-saveImage"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.jeffresc.meteoroidprefs-loadPrefs"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
  }
}
