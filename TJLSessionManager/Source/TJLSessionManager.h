//
//  TJLSessionManager.h
//  TJLSessionManager
//
//  Created by Terry Lewis II on 12/7/13.
//  Copyright (c) 2013 Terry Lewis. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MultipeerConnectivity;
@interface TJLSessionManager : NSObject
/**
 * Creates a session manager and sets the display name that will be show
 * to other users when browsing or advertising.
 * @param displayName the name that will be show when browsing or advertising.
 * @return A instance of the class that is ready to use.
 */
- (instancetype)initWithDisplayName:(NSString *)displayName;

/**
 * Creates a session manager and sets the display name that will be show
 * to other users when browsing or advertising.
 * @param displayName the name that will be show when browsing or advertising.
 * @param info A dictionary of discovery info for use with service advertisers.
 * @return A instance of the class that is ready to use.
 */
- (instancetype)initWithDisplayName:(NSString *)displayName discoveryInfo:(NSDictionary *)info;

/**
 * Begins browsing for programmatic discovery. You must provide your own
 * discovery UI when browsing this way.
 */
- (void)browseForProgrammaticDiscovery;

/**
 * Advertises for discovery by the built in MCBrowserViewController.
 */
- (void)advertiseForBrowserViewController;

/**
 * Advertises for programmatic discovery.
 */
- (void)advertiseForProgrammaticDiscovery;

/**
 * Called when you receive an invitation from a peer to connect.
 * @param invite A block that is called whenever a peer tries to connect. Contains
 * the peer The peer who wishes to connect and context data the peer sent along with the invitation. 
 * Context data may be nil.
 */
- (void)didReceiveInvitationFromPeer:(void(^)(MCPeerID *peer, NSData *context))invite;

/**
 * Sends data to all connected peers. Uses 'MCSessionSendDataReliable' mode.
 * @param data the data that you wish to send to all of the connected peers.
 * @return An NSError object that is nil if no error occured on sending,
 * non nil otherwise.
 */
- (NSError *)sendDataToAllPeers:(NSData *)data;

/**
 * Sends data to only the peers that you specify. Uses 'MCSessionSendDataReliable' mode.
 * @param data The data you wish to send.
 * @param peers The peers you wish to send the data to. Useful if you
 * want to send data to only certain peers that are connected.
 * @return An NSError object that is nil if no error occured on sending,
 * non nil otherwise.
 */
- (NSError *)sendData:(NSData *)data toPeers:(NSArray *)peers;

/**
 * Receives all data that is sent to you for this session.
 * @param mainQueue Whether or not `dataBlock` should be called on the main queue or not.
 * @param dataBlock a block with the received data and peer that sent the data.
 */
- (void)receiveDataOnMainQueue:(BOOL)mainQueue block:(void (^)(NSData *data, MCPeerID *peer))dataBlock;

/**
 * Sends the resource with the given name at the given URL to the peer.
 * It is only possible to send a resource to one peer at a time.
 * @param name The name of the resource.
 * @param url The URL of the resource. Could be local, or could be on the web.
 * If local, must be inside your sandbox, so you can't send ALAssests by sending
 * their URL with this method, as they are not inside your sandbox.
 * @param peer The peer to send the resource to. Can only send resources to
 * one peer at a time.
 * @param complete Called when sending is complete or an error occurs.
 * If there was no error, then the error param is nil, otherwise it will be non-nil.
 * @return A NSProgress object so you can observe the progress of the sending operation.
 */
- (NSProgress *)sendResourceWithName:(NSString *)name atURL:(NSURL *)url toPeer:(MCPeerID *)peer complete:(void (^)(NSError *error))compelete;

/**
 * Called when the resource is done being received.
 * @param mainQueue Whether or not `block` should be called on the main queue or not.
 * @param block Block will be called when the resource in done being received.
 * The resource can be loaded from the url, and the error will be nil unless there
 * was a problem receiving the resource.
 */
- (void)receiveFinalResourceOnMainQueue:(BOOL)mainQueue complete:(void (^)(NSString *name, MCPeerID *peer, NSURL *url, NSError *error))block;

/**
 * Called when a resource has begun to be recieved.
 * @param mainQueue Whether or not `block` should be called on the main queue or not.
 * @param block Block is called once the resource has begun to be received.
 * `progress` cna be used to observe the elapsed time if the resource transfer.
 */
- (void)startReceivingResourceOnMainQueue:(BOOL)mainQueue block:(void(^)(NSString *name, MCPeerID *peer, NSProgress *progress))block;

/**
 * Notifies you of the connection status of the particular peer
 * that is attemping to connect, or is connected.
 * @param mainQueue Whether or not `status` should be called on the main queue or not.
 * @param status A block with the peer that is attempting to connect
 * as well as the connection status.
 */
- (void)peerConnectionStatusOnMainQueue:(BOOL)mainQueue block:(void (^)(MCPeerID *peer, MCSessionState state))status;

/**
 * Presents the built in 'MCBrowserViewController' in the passed in view controller.
 * Calls the appropriate block upon successful or failed connection.
 * @param controller The view controller that will present the 'MCBrowserViewController'.
 * @param connected A block that will be called upon successful connection.
 * @param canceled A block that will be called if the browser is canceled.
 */
- (void)browserWithControllerInViewController:(UIViewController *)controller connected:(void (^)(void))connected canceled:(void (^)(void))canceled;

- (void)didFindPeerWithInfo:(void(^)(MCPeerID *peer, NSDictionary *info))found;

/**
 * Call this when a peer has asked to connect. Pass YES if you want to connect,
 * pass NO if you don't want to connect.
 * @param connect Whether or not you want to connect to the peer asking to connect.
 * YES will accept the connection, NO will decline.
 */
- (void)connectToPeer:(BOOL)connect;
/**
 * Invites the peer to connect to your session. Calls the 'connected'
 * block when the connection is successful.
 * @param connected A block that is called when the connection is successful.
 */
- (void)invitePeerToConnect:(MCPeerID *)peer connected:(void(^)(void))connected;

/**
 * A NSArray of all the currently connected peers
 */
@property(strong, nonatomic, readonly) NSArray *connectedPeers;

/**
 * The 'MCSession' object.
 */
@property(strong, nonatomic, readonly) MCSession *session;

/**
 * A BOOL that indicates if you are connected to at least one peer.
 * YES if you are connected to at least one peer, NO otherwise.
 */
@property(nonatomic, readonly, getter = isConnected) BOOL connected;

/**
 * A dictionary of discovery info for use with service advertisers.
 */
@property(strong, nonatomic) NSDictionary *discoveryInfo;

/**
 * The first peer that connected to the session.
 */
@property(strong, nonatomic, readonly)MCPeerID *firstPeer;
@end
