//
//  ViewController.m
//  Empty iOS SDK Project
//
//  Created by Daniel Kennett on 2014-02-19.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <SPTTrackPlayerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverView;

@property (nonatomic, strong) SPTTrackPlayer *trackPlayer;

@end

@implementation ViewController

-(void)viewDidLoad {
    [super viewDidLoad];
	[self addObserver:self forKeyPath:@"trackPlayer.indexOfCurrentTrack" options:0 context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"trackPlayer.indexOfCurrentTrack"]) {
        [self updateUI];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Actions

-(IBAction)rewind:(id)sender {
	[self.trackPlayer skipToPreviousTrack:NO];
}

-(IBAction)playPause:(id)sender {
	if (self.trackPlayer.paused) {
		[self.trackPlayer resumePlayback];
	} else {
		[self.trackPlayer pausePlayback];
	}
}

-(IBAction)fastForward:(id)sender {
	[self.trackPlayer skipToNextTrack];
}

#pragma mark - Logic

-(void)updateUI {
	if (self.trackPlayer.indexOfCurrentTrack == NSNotFound) {
		self.titleLabel.text = @"Nothing Playing";
		self.albumLabel.text = @"";
		self.artistLabel.text = @"";
		self.coverView.image = nil;
	} else {
		NSInteger index = self.trackPlayer.indexOfCurrentTrack;
		SPTAlbum *album = (SPTAlbum *)self.trackPlayer.currentProvider;
		self.titleLabel.text = [album.tracks[index] name];
		self.albumLabel.text = album.name;
		self.artistLabel.text = album.artist.name;
		self.coverView.image = [UIImage imageNamed:@"coverart"];
	}
}

-(void)handleNewSession:(SPTSession *)session {

	if (self.trackPlayer == nil) {

		self.trackPlayer = [[SPTTrackPlayer alloc] initWithCompanyName:@"Spotify"
															   appName:@"SimplePlayer"];
		self.trackPlayer.delegate = self;
	}

	[self.trackPlayer enablePlaybackWithSession:session callback:^(NSError *error) {

		if (error != nil) {
			NSLog(@"*** Enabling playback got error: %@", error);
			return;
		}

		[SPTRequest requestItemAtURI:[NSURL URLWithString:@"spotify:album:4L1HDyfdGIkACuygktO7T7"]
						 withSession:nil
							callback:^(NSError *error, id object) {

								if (error != nil) {
									NSLog(@"*** Album lookup got error %@", error);
									return;
								}

								[self.trackPlayer playTrackProvider:(id <SPTTrackProvider>)object];

							}];
	}];

}

#pragma mark - Track Player Delegates

-(void)trackPlayer:(SPTTrackPlayer *)player didStartPlaybackOfTrackAtIndex:(NSInteger)index ofProvider:(id <SPTTrackProvider>)provider {
	NSLog(@"Started playback of track %@ of %@", @(index), provider.uri);
}

-(void)trackPlayer:(SPTTrackPlayer *)player didEndPlaybackOfTrackAtIndex:(NSInteger)index ofProvider:(id<SPTTrackProvider>)provider {
	NSLog(@"Ended playback of track %@ of %@", @(index), provider.uri);
}

-(void)trackPlayer:(SPTTrackPlayer *)player didEndPlaybackOfProvider:(id <SPTTrackProvider>)provider withReason:(SPTPlaybackEndReason)reason {
	NSLog(@"Ended playback of provider %@ with reason %@", provider.uri, @(reason));
}

-(void)trackPlayer:(SPTTrackPlayer *)player didEndPlaybackOfProvider:(id <SPTTrackProvider>)provider withError:(NSError *)error {
	NSLog(@"Ended playback of provider %@ with error %@", provider.uri, error);
}

-(void)trackPlayer:(SPTTrackPlayer *)player didDidReceiveMessageForEndUser:(NSString *)message {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message from Spotify"
														message:message
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
}

@end
