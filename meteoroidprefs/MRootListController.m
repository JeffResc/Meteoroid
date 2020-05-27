#include "MRootListController.h"
#import "MCustomHeaderClassCell.h"
#import "MTimePickerCell.h"
#import "PreferencesColorDefinitions.h"

@implementation MRootListController

	-(NSArray *)specifiers {
		if (!_specifiers) {
			_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
		}
		return _specifiers;
	}

	-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
		if (section == 0) {
			return (UIView *)[[MCustomHeaderCell alloc] init];
		}
    return nil;
	}

	-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
		if (section == 0) {
			return 160.0f;
		}
	return (CGFloat)-1;
	}

	-(void)viewDidLoad {
		//Adds GitHub button in top right of preference pane
		UIImage *iconBar = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/meteoroidprefs.bundle/github.png"];
		iconBar = [iconBar imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
		UIBarButtonItem *webButton = [[UIBarButtonItem alloc] initWithImage:iconBar style:UIBarButtonItemStylePlain target:self action:@selector(webButtonAction)];
		self.navigationItem.rightBarButtonItem = webButton;

		[webButton release];
		[super viewDidLoad];
	}

	-(IBAction)webButtonAction {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://github.com/JeffResc/Meteoroid"] options:@{} completionHandler:nil];
	}

	-(void)viewWillAppear:(BOOL)animated {
		[super viewWillAppear:animated];
			//Changed colors of Navigation Bar, Navigation Text
		self.navigationController.navigationController.navigationBar.tintColor = Sec_Color;
		self.navigationController.navigationController.navigationBar.barTintColor = Main_Color;
		self.navigationController.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
			//Changes colors of Slider Filler, Switches when enabled, Segment Switches, iOS 10+ friendly
		[UISlider appearanceWhenContainedInInstancesOfClasses:@[[self.class class]]].tintColor = Switch_Color;
		[UISwitch appearanceWhenContainedInInstancesOfClasses:@[[self.class class]]].onTintColor = Switch_Color;
		[UISegmentedControl appearanceWhenContainedInInstancesOfClasses:@[[self.class class]]].tintColor = Switch_Color;
	}

	-(void)viewWillDisappear:(BOOL)animated {
		[super viewWillDisappear:animated];
		//Returns normal colors to Navigation Bar
		self.navigationController.navigationController.navigationBar.tintColor = nil;
		self.navigationController.navigationController.navigationBar.barTintColor = nil;
		self.navigationController.navigationController.navigationBar.titleTextAttributes = nil;
	}

	-(void)_returnKeyPressed:(id)arg1 {
		[self.view endEditing:YES];
	}

	//https://github.com/angelXwind/KarenPrefs/blob/master/KarenPrefsListController.m
	-(id)readPreferenceValue:(PSSpecifier*)specifier {
		NSDictionary * prefs = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", [specifier.properties objectForKey:@"defaults"]]];
		if (![prefs objectForKey:[specifier.properties objectForKey:@"key"]]) {
			return [specifier.properties objectForKey:@"default"];
		}
		return [prefs objectForKey:[specifier.properties objectForKey:@"key"]];
	}

	-(void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
		NSMutableDictionary * prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", [specifier.properties objectForKey:@"defaults"]]];
		[prefs setObject:value forKey:[specifier.properties objectForKey:@"key"]];
		[prefs writeToFile:[NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", [specifier.properties objectForKey:@"defaults"]] atomically:YES];
		if([specifier.properties objectForKey:@"PostNotification"]) {
			CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)[specifier.properties objectForKey:@"PostNotification"], NULL, NULL, YES);
		}
		[super setPreferenceValue:value specifier:specifier];
	}

	-(void)respring {
		UIAlertController *respringAlert = [UIAlertController alertControllerWithTitle:@"Meteoroid"
																			message:@"Are you sure you want Respring?"
																			preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
				CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.jeffresc.meteoroidprefs-respring"), nil, nil, true);
		}];
		UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
		[respringAlert addAction:confirmAction];
		[respringAlert addAction:cancelAction];
		[self presentViewController:respringAlert animated:YES completion:nil];

	}

	-(void)updateSpaceImage {
		UIAlertController *updateImageAlert = [UIAlertController alertControllerWithTitle:@"Meteoroid"
																			message:@"Are you sure you want to update the wallpaper? You can't save it once its changed!"
																			preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
				CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.jeffresc.meteoroid-runCommand"), nil, nil, true);
		}];
		UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
		[updateImageAlert addAction:confirmAction];
		[updateImageAlert addAction:cancelAction];
		[self presentViewController:updateImageAlert animated:YES completion:nil];
	}

	-(void)saveImage {
		UIAlertController *saveImageAlert = [UIAlertController alertControllerWithTitle:@"Meteoroid"
																			message:@"Saving current wallpaper..."
																			preferredStyle:UIAlertControllerStyleAlert];
		[self presentViewController:saveImageAlert animated:YES completion:^{
			CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.jeffresc.meteoroidprefs-saveImage"), nil, nil, true);

			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [saveImageAlert dismissViewControllerAnimated:YES completion:nil];
			});
		}];
	}

	-(void)openCurrentImageSource {
		NSMutableDictionary *preferences = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.jeffresc.meteoroidsaveddata.plist"];
		NSString *currentShownImageURL = [preferences objectForKey:@"currentShownImageURL"];
		if([currentShownImageURL isEqualToString:@""] || currentShownImageURL == nil) {
			UIAlertController *openCurrentImageSourceError = [UIAlertController alertControllerWithTitle:@"Meteoroid" message:@"No image URL currently saved! Wait for the wallpaper to automatically update or manually update it yourself for this to be available." preferredStyle:UIAlertControllerStyleAlert];
			[self presentViewController:openCurrentImageSourceError animated:YES completion:^{

				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	      	[openCurrentImageSourceError dismissViewControllerAnimated:YES completion:nil];
				});
			}];

		} else {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:currentShownImageURL] options:@{} completionHandler:nil];
		}
	}

	-(void)twitter {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/JeffRescignano"] options:@{} completionHandler:nil];
	}
	-(void)paypal {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/JeffRescignano"] options:@{} completionHandler:nil];
	}
	-(void)github {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/JeffResc/Meteoroid"] options:@{} completionHandler:nil];
	}
	-(void)twitter2 {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/LacertosusDeus"] options:@{} completionHandler:nil];
	}
	-(void)paypal2 {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://lacertosusrepo.github.io/depictions/resources/donate.html"] options:@{} completionHandler:nil];
	}
	-(void)github2 {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/LacertosusRepo"] options:@{} completionHandler:nil];
	}
	-(void)nasaIOTD {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.nasa.gov/multimedia/imagegallery/iotd.html"] options:@{} completionHandler:nil];
	}
	-(void)nasaEO {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://earthobservatory.nasa.gov/topic/image-of-the-day"] options:@{} completionHandler:nil];
	}
	-(void)nasaAPOD {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://science.nasa.gov/astronomy-picture-of-the-day"] options:@{} completionHandler:nil];
	}
	-(void)spaceX {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.flickr.com/people/spacex/"] options:@{} completionHandler:nil];
	}
@end
