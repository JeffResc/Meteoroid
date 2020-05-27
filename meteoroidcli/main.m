#import <stdio.h>
#import <string.h>
#import <dlfcn.h>
#import <objc/runtime.h>

void performSelectorWithInteger(id parent, SEL selector, NSInteger integer) {
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[parent methodSignatureForSelector:selector]];
    [inv setTarget:parent];
    [inv setSelector:selector];
    [inv setArgument:&integer atIndex:2];
    [inv invoke];
}

static UIImage* getImageOfSpace(int imageSource) {
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://jeffresc.dev/meteoroid_api/source%u.json", imageSource]];
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

  NSData *spaceImageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageURL]];
  UIImage *spaceImage = [UIImage imageWithData:spaceImageData];

  return spaceImage;
}

void setWallpaper(int source, int location, bool parallax) {
    UIImage *newImage = getImageOfSpace(source);

    dlopen("/System/Library/PrivateFrameworks/SpringBoardFoundation.framework/SpringBoardFoundation", RTLD_LAZY);
    void *SBUIServs = dlopen("/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/SpringBoardUIServices", RTLD_LAZY);

    id lightOptions = [[objc_getClass("SBFWallpaperOptions") alloc] init];
    id darkOptions = [[objc_getClass("SBFWallpaperOptions") alloc] init];

    if (!parallax) {
        performSelectorWithInteger(lightOptions, @selector(setParallaxFactor:), 0);
        performSelectorWithInteger(darkOptions, @selector(setParallaxFactor:), 0);
    }

    if (@available(iOS 13, *)) {
        int (*SBSUIWallpaperSetImages)(NSDictionary *imagesDict, NSDictionary *optionsDict, int location, int interfaceStyle) = dlsym(SBUIServs, "SBSUIWallpaperSetImages");

        performSelectorWithInteger(lightOptions, @selector(setWallpaperMode:), 1);
        performSelectorWithInteger(darkOptions, @selector(setWallpaperMode:), 2);
        SBSUIWallpaperSetImages(@{@"light":newImage, @"dark":newImage}, @{@"light":lightOptions, @"dark":darkOptions}, location, UIUserInterfaceStyleDark);
    }
    else {
        void (*SBSUIWallpaperSetImage)(UIImage *image, NSDictionary *optionsDict, NSInteger location) = dlsym(SBUIServs, "SBSUIWallpaperSetImage");
        SBSUIWallpaperSetImage(newImage, lightOptions, location);
    }
}

void displayUsage() {
    printf("Usage: meteoroidcli [source #] [location to set] [parallax on/off]\n");
    printf("       -s\tSet the image source\n");
    printf("       Source 1: NASA (IOTD)\n");
    printf("       Source 2: NASA (EO)\n");
    printf("       Source 3: NASA (APOD)\n");
    printf("       Source 4: SpaceX\n");
    printf("       Choose one source number to use at a time\n");
    printf("\n");
    printf("       -l\tSet only the lock screen wallpaper\n");
    printf("       -h\tSet only the home screen wallpaper\n");
    printf("       -b\tSet both wallpapers\n");
    printf("       Choose between -h, -l, and -b. Do not specify more than one\n");
    printf("\n");
    printf("       -p\tEnable parallax (optional parameter - parallax is off by default)\n");
    printf("       --help\tShow this help page\n");
    printf("\n");
    printf("       All arguments are required except -p\n");
}

int main(int argc, char *argv[], char *envp[]) {
    if (argc == 1 || !strcmp(argv[1], "--help")) {
        displayUsage();
        return 1;
    }

    int source;
    int location;
    bool parallax = false;

    for (int i = 1; i < argc; i++) { //parse the arguments
        if (!strcmp(argv[i], "-s")) {
          source = atoi(argv[i + 1]);
        } else if (!strcmp(argv[i], "-l")) {
          location = 1;
        } else if (!strcmp(argv[i], "-h")) {
          location = 2;
        } else if (!strcmp(argv[i], "-b")) {
          location = 3;
        } else if (!strcmp(argv[i], "-p")) {
          parallax = true;
        }
    }

    setWallpaper(source, location, parallax);
    return 0;
}
