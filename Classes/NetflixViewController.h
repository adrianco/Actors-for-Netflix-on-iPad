//
//  WebkitViewController.h
//
//  Created by Adrian Cockcroft on 2/4/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetflixViewController : UIViewController <UIWebViewDelegate> {
	UIWebView   *netflixView;
	UIBarButtonItem *freeButton;
	NSString	*urlString;
}

@property (nonatomic, retain) IBOutlet UIWebView *netflixView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *freeButton;


- (id) initWithUrlString:(NSString *)aString;
- (IBAction)back;
- (IBAction)free;
- (void)webViewDidFinishLoad:(UIWebView *)webView;

@end

