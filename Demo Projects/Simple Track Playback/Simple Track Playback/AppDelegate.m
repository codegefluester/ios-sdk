//
//  AppDelegate.m
//  Empty iOS SDK Project
//
//  Created by Daniel Kennett on 2014-02-19.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import "AppDelegate.h"
#import <Spotify/Spotify.h>
#import "ViewController.h"

//#error Please fill in your application's details here and remove this error to run the sample.
static NSString * const kClientId = @"spotify-ios-sdk-beta";
static NSString * const kCallbackURL = @"spotify-ios-sdk-beta://callback";

static NSString * const kSessionUserDefaultsKey = @"SpotifySession";

@implementation AppDelegate

-(void)enableAudioPlaybackWithSession:(SPTSession *)session {
	ViewController *viewController = (ViewController *)self.window.rootViewController;
	[viewController handleNewSession:session];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	id plistRep = [[NSUserDefaults standardUserDefaults] valueForKey:kSessionUserDefaultsKey];
	SPTSession *session = [[SPTSession alloc] initWithPropertyListRepresentation:plistRep];

	if (session.credential.length > 0) {
		[self enableAudioPlaybackWithSession:session];
	} else {
		SPTAuth *auth = [SPTAuth defaultInstance];
		NSURL *loginURL = [auth loginURLForClientId:kClientId
								declaredRedirectURL:[NSURL URLWithString:kCallbackURL]
											 scopes:@[@"login"]];

		double delayInSeconds = 0.1;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			// If you open a URL during application:didFinishLaunchingWithOptions:, you
			// seem to get into a weird state.
			[[UIApplication sharedApplication] openURL:loginURL];
		});
	}

    return YES;
}
							
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

	SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
		// This is the callback that'll be triggered when auth is completed (or fails).

		if (error != nil) {
			NSLog(@"*** Auth error: %@", error);
			return;
		}

		[[NSUserDefaults standardUserDefaults] setValue:[session propertyListRepresentation]
												 forKey:kSessionUserDefaultsKey];
		[self enableAudioPlaybackWithSession:session];
	};

	/*
	 STEP 2: Handle the callback from the authentication service. -[SPAuth -canHandleURL:withDeclaredRedirectURL:]
	 helps us filter out URLs that aren't authentication URLs (i.e., URLs you use elsewhere in your application).

	 Make the token swap endpoint URL matches your auth service URL.
	 */

	if ([[SPTAuth defaultInstance] canHandleURL:url withDeclaredRedirectURL:[NSURL URLWithString:kCallbackURL]]) {
		[[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url
											tokenSwapServiceEndpointAtURL:[NSURL URLWithString:@"http://usa.ikennd.ac:1234/swap"]
																 callback:authCallback];
		return YES;
	}

	return NO;
}

@end
