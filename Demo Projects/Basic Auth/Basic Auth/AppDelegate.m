//
//  AppDelegate.m
//  Basic Auth
//
//  Created by Daniel Kennett on 02/08/2012.

/*
 This project is a simple project that does nothing but authenticate a user against the Spotify
 OAuth authentication service.
 */

#import "AppDelegate.h"
#import <Spotify/Spotify.h>

#error Please fill in your application's details here and remove this error to run the sample.
static NSString * const kClientId = @"";
static NSString * const kCallbackURL = @"";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	return YES;
}

- (IBAction)logIn:(id)sender {

	/*
	 STEP 1: Get a login URL from SPAuth and open it in Safari. Note that you must open
	 this URL using -[UIApplication openURL:].
	 */

	NSURL *loginPageURL = [[SPTAuth defaultInstance] loginURLForClientId:kClientId
													 declaredRedirectURL:[NSURL URLWithString:kCallbackURL]
																  scopes:@[@"login"]];

	[[UIApplication sharedApplication] openURL:loginPageURL];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

	SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
		// This is the callback that'll be triggered when auth is completed (or fails).

		if (error != nil) {
			NSLog(@"Error: %@", error);
			return;
		}

		UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Logged In from Safari"
													   message:[NSString stringWithFormat:@"Logged in as user %@", session.canonicalUsername]
													  delegate:nil
											 cancelButtonTitle:@"OK"
											 otherButtonTitles:nil];
		[view show];

		[self performTestCallWithSession:session];
	};

	/*
	 STEP 2: Handle the callback from the authentication service. -[SPAuth -canHandleURL:withDeclaredRedirectURL:]
	 helps us filter out URLs that aren't authentication URLs (i.e., URLs you use elsewhere in your application).
	 
	 Make the token swap endpoint URL matches your auth service URL.
	 */

	if ([[SPTAuth defaultInstance] canHandleURL:url withDeclaredRedirectURL:[NSURL URLWithString:kCallbackURL]]) {
		[[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url
											tokenSwapServiceEndpointAtURL:[NSURL URLWithString:@"http://localhost:1234/swap"]
																 callback:authCallback];
		return YES;
	}

	return NO;
}

-(void)performTestCallWithSession:(SPTSession *)session {

	/*
	 STEP 3: Execute a simple authenticated API call using our new credentials.
	 */
	[SPTRequest playlistsForUser:session.canonicalUsername withSession:session callback:^(NSError *error, SPTPlaylistList *playlists) {
		if (error)
			NSLog(@"%@", error);
		else
			NSLog(@"%@", playlists);
	}];
}

@end
