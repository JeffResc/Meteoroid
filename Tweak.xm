#import <PhotoLibrary/PLStaticWallpaperImageViewController.h>
#import "MeteoroidClasses.h"
#define LD_DEBUG NO

  /*
   * Preference variables
   */
  static int wallpaperMode;
  static NSDate *fireTime;
  static NSString *imageSource;

  /*
   * Global variables
   */
  BOOL meteoroidInitalAlertShown;
  BOOL shouldUpdateWallpaper;
  BOOL savedInitalWallpaper;
  int timerInterval;
  NSData *spaceImageData;
  NSString *currentImageURL;
  NSString *currentShownImageURL;
  PCSimpleTimer *timer;
  SBHomeScreenViewController *HomeScreenViewController;

  extern "C" CFArrayRef CPBitmapCreateImagesFromData(CFDataRef cpbitmap, void*, int, void*);

static UIImage* getImageOfSpace() {
  if([imageSource isEqualToString:@""] || imageSource == nil) {
    imageSource = @"1";
  }
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://jeffresc.com/api/meteoroid.php?source=%@", imageSource]];
  NSData *data = [NSData dataWithContentsOfURL:url];
  NSError *error = nil;
  NSDictionary *dict;
  if(data == nil) {
    return nil;
  } else {
    dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
  }
  NSMutableDictionary *saveddata = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/User/Library/Preferences/com.jeffresc.meteoroidsaveddata.plist"];

  NSString *imageURL = dict[@"imageURL"];
  NSString *imageView = dict[@"imageView"];

  [saveddata setObject:imageURL forKey:@"currentImageURL"];
  [saveddata setObject:imageView forKey:@"currentShownImageURL"];
  [saveddata writeToFile:@"/User/Library/Preferences/com.jeffresc.meteoroidsaveddata.plist" atomically:YES];

  spaceImageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageURL]];
  UIImage *spaceImage = [UIImage imageWithData:spaceImageData];

  return spaceImage;
}

  /*
  * Shows inital alert after install. Allows user to save current wallpapers if they want
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
      NSLog(@"shouldUpdateWallpaper - %d", shouldUpdateWallpaper);
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

    if((([currentDate compare:fireTime] == NSOrderedDescending) && ([currentDate compare:fireTimeGate] == NSOrderedAscending)) || shouldUpdateWallpaper) {
      UIImage *newWallpaper = getImageOfSpace();
      shouldUpdateWallpaper = NO;

      if(newWallpaper != nil) {
        PLStaticWallpaperImageViewController *wallpaperViewController = [[[PLStaticWallpaperImageViewController alloc] initWithUIImage:newWallpaper] autorelease];
        wallpaperViewController.saveWallpaperData = YES;
        uintptr_t address = (uintptr_t)&wallpaperMode;
        object_setInstanceVariable(wallpaperViewController, "_wallpaperMode", *(PLWallpaperMode **)address);
        [wallpaperViewController _savePhoto];
      } else {
        NSLog(@"UIImage (newWallpaper) is empty!");
      }

    } if(![self.apolloTimer isValid]) {
      [self createTimer];

    } if(LD_DEBUG) {
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateFormat:@"HH:mm:ss"];
      NSLog(@"fireTime - %@ || Current Date - %@ || fireTimeGate - %@", [dateFormatter stringFromDate:fireTime], [dateFormatter stringFromDate:currentDate], [dateFormatter stringFromDate:fireTimeGate]);
    }
  }
%end

  /*
   * Simple function to manually update the wallpaper
   */
static void updateSpaceImage() {
  shouldUpdateWallpaper = YES;
  [HomeScreenViewController setSpaceWallpaper];
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
   * Resprings the device
   */
static void respring() {
  [[%c(FBSystemService) sharedInstance] exitAndRelaunch:YES];
}

  /*
   * Loads my preferences. If either plist has less objects than there are suppossed to be they are reset.
   */
static void loadPrefs() {
  NSMutableDictionary *preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/User/Library/Preferences/com.jeffresc.meteoroidprefs.plist"];
  NSMutableDictionary *saveddata = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/User/Library/Preferences/com.jeffresc.meteoroidsaveddata.plist"];
  if(!preferences || [preferences count] < 2) {
    preferences = [[NSMutableDictionary alloc] init];
    [preferences setObject:[NSNumber numberWithInt:2] forKey:@"wallpaperMode"];
    [preferences setObject:[NSNumber numberWithInt:1] forKey:@"imageSource"];
    [preferences writeToFile:@"/User/Library/Preferences/com.jeffresc.meteoroidprefs.plist" atomically:YES];
  } if(!saveddata || [saveddata count] < 4) {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:[NSDate date]];
    NSDate *defaultTime = [[NSCalendar currentCalendar] dateFromComponents:components];
    saveddata = [[NSMutableDictionary alloc] init];
    [saveddata setObject:defaultTime forKey:@"fireTime"];
    [saveddata setObject:@"" forKey:@"currentShownImageURL"];
    [saveddata setObject:@"" forKey:@"currentImageURL"];
    [saveddata setObject:[NSNumber numberWithBool:0] forKey:@"meteoroidInitalAlertShown"];
    [saveddata writeToFile:@"/User/Library/Preferences/com.jeffresc.meteoroidsaveddata.plist" atomically:YES];
  } else {
    wallpaperMode = [[preferences objectForKey:@"wallpaperMode"] intValue];
    imageSource = [preferences objectForKey:@"imageSource"];
    fireTime = [saveddata objectForKey:@"fireTime"];
    currentImageURL = [saveddata objectForKey:@"currentImageURL"];
    currentShownImageURL = [saveddata objectForKey:@"currentShownImageURL"];
  }
}

static NSString *nsNotificationString = @"com.jeffresc.meteoroidprefs/preferences.changed";
static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  loadPrefs();
}

  /*
   * Setup notifications
   */
%ctor {
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  loadPrefs();
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, notificationCallback, (CFStringRef)nsNotificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updateSpaceImage, CFSTR("com.jeffresc.meteoroidprefs-updateSpaceImage"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)saveImage, CFSTR("com.jeffresc.meteoroidprefs-saveImage"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)respring, CFSTR("com.jeffresc.meteoroidprefs-respring"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
  [pool release];
}
