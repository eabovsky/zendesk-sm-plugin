//
//  SMMessagesViewController.m
//  Remember The Date
//
//  Created by Mylene Bayan on 22/08/2016.
//  Copyright © 2016 Stratpoint. All rights reserved.
//

#import "SMMessagesViewController.h"

#import <ZendeskSDK/ZendeskSDK.h>
#import <ZDCChat/ZDCChat.h>

#import "JSQMessages.h"

#import "ScreenMeetManager.h"

@interface SMMessagesViewController ()

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableDictionary *eventIds;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@end

@implementation SMMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGSize avatarSize = CGSizeMake(28.0, 28.0);
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = avatarSize;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = avatarSize;
    self.collectionView.collectionViewLayout.messageBubbleFont = [UIFont systemFontOfSize:14.0 weight:UIFontWeightLight];
    self.collectionView.collectionViewLayout.messageBubbleTextViewTextContainerInsets = UIEdgeInsetsMake(5.0, 7.0, 5.0, 3.0);
    
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.20f]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.20f]];
    
    self.messages = [NSMutableArray new];
    self.eventIds = [NSMutableDictionary new];
    
    self.senderId          = @"screenmeet_customer_sender_id";
    self.senderDisplayName = @"Visitor";
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[ZDCChat instance].session connect];
    [[ZDCChat instance].session.dataSource addObserver:self forChatLogEvents:@selector(chatEvent:)];
    [ScreenMeetManager sharedManager].chatWidget.isLive = YES;
    
    [self verifyEvents];
    
    self.navigationItem.leftBarButtonItem = [ScreenMeetManager createCloseButtonItemWithTarget:self forSelector:@selector(closeButtonWasPressed:)];
    
    [self processRightBarButtonItems];
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Override
- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    NSLog(@"Session status: %lul", (unsigned long)[[ZDCChat instance].session status]);
    
    [self sendMessage:text];
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    cell.avatarImageView.hidden = [self isFirstMessage:indexPath] ? NO : YES;
    
    cell.textView.textColor              = [UIColor blackColor];
    cell.textView.linkTextAttributes = @{NSForegroundColorAttributeName : cell.textView.textColor,
                                         NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    return cell;
}

#pragma mark - JSQMessages CollectionView DataSource
-(id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.messages[indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = self.messages[indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = self.messages[indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        
        // get and return user's avatar
        
    } else {
        ZDCChatAgent *agent = [[ZDCChat instance].session.dataSource agentForNickname:message.senderId];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:agent.avatarURL]];
        if (imageData) {
            return [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:imageData]
                                                       diameter:28.0];
        }
    }
    
    return [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"avatar_placeholder"]
                                                               diameter:28.0];;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self isFirstMessage:indexPath] ? kJSQMessagesCollectionViewCellLabelHeightDefault : 0.0;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isFirstMessage:indexPath]) {
        JSQMessage *message = self.messages[indexPath.item];
        return [[NSAttributedString alloc] initWithString:message.senderDisplayName
                                               attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    }
    
    return nil;
}

- (NSURL *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageUrlForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isFirstMessage:indexPath]) {
        JSQMessage *message = self.messages[indexPath.item];
        if (![message.senderId isEqualToString:self.senderId]) {
            ZDCChatAgent *agent = [[ZDCChat instance].session.dataSource agentForNickname:message.senderId];
            return [NSURL URLWithString:agent.avatarURL];
        }
    }
    
    return nil;
}

#pragma mark - UITextView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if (![textView.text isEqualToString:@""]) {
            [self sendMessage:textView.text];
        }
        return NO;
    }
    return YES;
}

#pragma mark - ZDCChat Events
- (void)verifyEvents
{
    NSMutableArray *chatLog = [[ZDCChat instance].session.dataSource livechatLog];
    
    for (ZDCChatEvent *chatEvent in chatLog) {
        self.eventIds[chatEvent.eventId] = @1;
    }
}

- (void)chatEvent:(id)event
{
    
    ZDCChatEvent *chatEvent = [[ZDCChat instance].session.dataSource lastChatMessage];
    
    // only show messages for events verified by the server
    // we can also add here timestamp filters
    if (chatEvent.verified && ![self.eventIds[chatEvent.eventId] boolValue]) {
        
        self.eventIds[chatEvent.eventId] = @1;
        
        NSString *senderId = @"";
        
        if (chatEvent.type == ZDCChatEventTypeAgentMessage) {
#warning TODO: Extend JSQMessage and add other needed info (agentId, avatarImage, etc.).
            senderId          = chatEvent.nickname;
        } else {
            senderId          = self.senderId;
        }
        
        // Check message
        NSString *text = @"";
        
        if ([[chatEvent.message lowercaseString] containsString:@"requestscreenshare"]) {
            text     = @"requested a screen share...";
            
            long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
            long long diff         = milliseconds - [chatEvent.timestamp longLongValue];
            long long threshold    = 5000;
            
            if (diff <= threshold) {
                [self showRequestAlertforMessage:chatEvent];
            }
            
        } else if ([[chatEvent.message lowercaseString] containsString:@"stopscreenshare"]) {
            text     = @"stopped the screen sharing...";
            [self stopStreamButtonWasPressed:nil];
        } else {
            text     = chatEvent.message;
        }
        
        JSQMessage *message = [JSQMessage messageWithSenderId:senderId
                                                  displayName:chatEvent.displayName
                                                         text:text];
        
        [self.messages addObject:message];
        
        [self finishReceivingMessage];
        
        if (self.isViewLoaded && self.view.window) {
            // do nothing
        } else {
            [[ScreenMeetManager sharedManager].chatWidget addStackableToastMessage:[NSString stringWithFormat:@"%@: %@", chatEvent.displayName, message.text]];
        }
    }
}

- (void)showRequestAlertforMessage:(ZDCChatEvent *)event
{
    UIAlertController *requestAlert = [UIAlertController alertControllerWithTitle:@"Screen Share" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                       [requestAlert dismissViewControllerAnimated:NO completion:nil];
                                   }];
    
    UIAlertAction *shareAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Share", @"Share action")
                                  style:UIAlertActionStyleDestructive
                                  handler:^(UIAlertAction *action)
                                  {
                                      NSLog(@"Share action");
                                      
                                      // extract token from the message
                                      // to do: add checks if valid message format
                                      
                                      NSString *token = [[event.message componentsSeparatedByString:@"|"] lastObject];
                                      
                                      [[ScreenMeetManager sharedManager] showHUDWithTitle:@"authenticating..."];
                                      
                                      // Authenticate with token
                                      [[ScreenMeetManager sharedManager] loginWithToken:token callback:^(enum CallStatus status) {
                                          if (status == CallStatusSUCCESS) {
                                              [self.inputToolbar.contentView.textView resignFirstResponder];
                                              NSLog(@"login with token was successful...");
                                              NSLog(@"will now start screen sharing...");
                                              
                                              [[ScreenMeetManager sharedManager] showHUDWithTitle:@"starting stream..."];
                                              
                                              
                                              [[ScreenMeet sharedInstance] startStream:^(enum CallStatus status) {
                                                  if (status == CallStatusSUCCESS) {
                                                      NSLog(@"screen sharing now started...");
                                                      // trigger UI and states for screen sharing
                                                      
                                                      [[ScreenMeetManager sharedManager] hideHUD];
                                                      [[ScreenMeetManager sharedManager].chatWidget showStreamingUI];
                                                      
                                                      [self sendMessage:@"Screen shared."];
                                                      
                                                      [self processRightBarButtonItems];
                                                      
                                                      [[[UIAlertView alloc] initWithTitle:@"" message:@"Screen share started" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                                                  } else {
                                                      [self handleScreenShareError:status];
                                                  }
                                              }];
                                          } else {
                                              [self handleScreenShareError:status];
                                          }
                                      }];
                                  }];
    
    [requestAlert addAction:cancelAction];
    [requestAlert addAction:shareAction];
    
    if (self.isViewLoaded && self.view.window) {
        [self presentViewController:requestAlert animated:YES completion:nil];
    } else {
        [ScreenMeetManager presentViewControllerFromWindowRootViewController:requestAlert animated:YES completion:^{
            
        }];
    }
}

- (void)handleScreenShareError:(CallStatus)status
{
    // can add different error handling here
    [[ScreenMeetManager sharedManager] showDefaultError];
    [[ScreenMeetManager sharedManager] hideHUD];
    
    // send screen share error message
    [self sendMessage:@"There was a problem with sharing my screen."];
}

- (void)sendMessage:(NSString *)text {
    [[ZDCChat instance].session sendChatMessage:text];
    
    [self finishSendingMessage];
}

#pragma mark - Private Methods

- (void)closeButtonWasPressed:(UIBarButtonItem *)barButtonItem
{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[ScreenMeetManager sharedManager] initializeChatWidget];
        [[ScreenMeetManager sharedManager].chatWidget showWidget];
    }];
}

- (void)endChatButtonWasPressed:(UIBarButtonItem *)barButtonItem
{
    NSDictionary *agents = [ZDCChat instance].session.dataSource.agents;
    
    NSString *message = @"Are you sure you wish to end this chat session";
    NSString *postfix = @"";
    
    if (agents.count > 0) {
        postfix = @" with ";
        for (NSString *aKey in [agents allKeys]) {
            ZDCChatAgent *anAgent = agents[aKey];
            postfix = [postfix stringByAppendingFormat:@"%@, ", anAgent.displayName];
        }
        
        if ([postfix length] > 0) {
            postfix = [postfix substringToIndex:[postfix length] - 2];
        } else {
            //no characters to delete... attempting to do so will result in a crash
        }
    }
    
    UIAlertController *endChatAlert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@%@?", message, postfix] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                       [endChatAlert dismissViewControllerAnimated:NO completion:nil];
                                   }];
    
    UIAlertAction *shareAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"End Chat", @"Share action")
                                  style:UIAlertActionStyleDestructive
                                  handler:^(UIAlertAction *action)
                                  {
                                      NSLog(@"End Chat action");
                                      
                                      [self dismissViewControllerAnimated:YES completion:^{
                                          [[ScreenMeetManager sharedManager] stopStream];
                                          [[ZDCChat instance].session endChat];
                                          
                                          [ScreenMeetManager sharedManager].chatWidget.isLive = NO;
                                          [[ScreenMeetManager sharedManager].chatWidget endChat];
                                          
                                          [self.eventIds removeAllObjects];
                                          [self.messages removeAllObjects];
                                          [self.collectionView reloadData];
                                      }];
                                      
                                  }];
    
    [endChatAlert addAction:cancelAction];
    [endChatAlert addAction:shareAction];
    
    [self presentViewController:endChatAlert animated:YES completion:nil];
}

- (void)stopStreamButtonWasPressed:(UIBarButtonItem *)barButtonItem
{
    [[ScreenMeetManager sharedManager] stopStream];
    [[ScreenMeetManager sharedManager].chatWidget updateUI];
    
    [self sendMessage:@"Screen sharing stoppped."];
    
    [self processRightBarButtonItems];
}

- (void)processRightBarButtonItems
{
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItems = nil;
    
    if ([[ScreenMeetManager sharedManager] isStreaming]) {
        UIBarButtonItem *stopStream = [[UIBarButtonItem alloc] initWithTitle:@"Stop Sharing Screen" style:UIBarButtonItemStyleDone target:self action:@selector(stopStreamButtonWasPressed:)];
        UIBarButtonItem *endChat = [[UIBarButtonItem alloc] initWithTitle:@"End Chat" style:UIBarButtonItemStyleDone target:self action:@selector(endChatButtonWasPressed:)];
        
        self.navigationItem.rightBarButtonItems = @[endChat, stopStream];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"End Chat" style:UIBarButtonItemStyleDone target:self action:@selector(endChatButtonWasPressed:)];
    }
}

- (BOOL)isFirstMessage:(NSIndexPath *)indexPath {
    JSQMessage *currentMessage = self.messages[indexPath.item];
    if (indexPath.item - 1 > 0) {
        JSQMessage *prevMessage = self.messages[indexPath.item - 1];
        if ([currentMessage.senderId isEqualToString:prevMessage.senderId]) {
            return NO;
        }
    }
    return YES;
}


@end
