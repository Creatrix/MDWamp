# What is it MDWamp ?

MDWamp is a client side objective-C implementation of the WebSocket subprotocol [WAMP][wamp_link].  
It uses [SocketRocket][socket_rocket] as WebSocket Protocol implementation.

With this library and with a server [implementation of WAMP protocol][wamp_impl] you can bring Real-time notification not only for a web app (as WebSocket was created for) but also on your mobile App, just like an inner-app Apple Push Notifcation Service, avoiding the hassle of long polling request to the server for getting new things.

WAMP in its creator words is:

> WAMP is an open WebSocket subprotocol that provides two application messaging patterns in one unified protocol:
Remote Procedure Calls + Publish & Subscribe.   
> Using WAMP you can build distributed systems out of application components which are loosely coupled and communicate in (soft) real-time.

but what are RPC and PubSub? here's a [nice and neat explanation][faq] if you have doubts.



## Installation

### OSX
- By using [CocoaPods][cocoapods], just add to your Podfile

	pod 'MDWamp'

- Use MDWamp.framework  
Build the framework target of the project, just be sure to `git submodule init && git submodule update` to get the SocketRocket dependancy (see test part for more info)


# iOS
I'm [sick and tired of iOS shitting support for distributing libraries][staticlibpost] so just cocoapods support for ya:
Just add this to your Podfile

	pod "MDWamp" 



## API

MDWamp is made of a main class `MDWamp` that does all the work, it makes connection to the server and expose methods to publish an receive events to and from a topic, and to call Rempte Procedure.

To instantiate it you must specify a transport (since WAMP can support different transports) in accord to the server you're connecting to.   
Now WebSocket is the only supported transport (raw socket is on the way).  
Note that the object `MDWamp` must be a retained property or ARC will get rid of it ahead of time.

You start a connection initing an MDWamp object, and by setting some features like auto reconnect:
	
	// You can specify a particular protocol version to use like kMDWampVersion2JSON, kMDWampVersion2Msgpack or use default
	MDWampTransportWebSocket *websocket = [[MDWampTransportWebSocket alloc] initWithServer:[NSURL URLWithString:@"ws://localhost:8080/ws"] protocolVersions:@[kMDWampVersion2]];   
	
    _wamp = [[MDWamp alloc] initWithTransport:websocket realm:@"realm1" delegate:self];


when your done and you want to fire the connection:

	[wamp connect];

to disconnect:

	[wamp disconnect];

You can optionally implement two methods in the delegate you've setted when initing MDWamp:

	// Called when client has connected to the server
	- (void) mdwamp:(MDWamp*)wamp sessionEstablished:(NSDictionary*)info;
	
	// Called when client disconnect from the server
	- (void) mdwamp:(MDWamp *)wamp closedSession:(NSInteger)code reason:(NSString*)reason details:(NSDictionary *)details;


You can also provide similar callback instead of using the delegate:

	@property (nonatomic, copy) void (^onSessionEstablished)(MDWamp *client, NSDictionary *info);
	@property (nonatomic, copy) void (^onSessionClosed)(MDWamp *client, NSInteger code, NSString *reason, NSDictionary *details);

The Header files of `MDWamp` class and of the Delegates are all well commented so the API is trivial, anyway here are some common usage examples

### Call a remote procedure:
	
	[wamp call:@"com.hello.hello" args:nil kwArgs:nil complete:^(MDWampResult *result, NSError *error) {
        if (error== nil) {
	        // do something with result object
	    } else {
	        // handle the error
	    }
    }];
	
### Publish to a topic] this json object `{"user" : ["foo", "bar"]}`:

	[_wamp publishTo:@"com.topic.hello" args:nil kw:@{@"user":@[@"foo", @"bar"]} options:@{@"acknowledge":@YES, @"exclude_me":@NO} result:^(NSError *error) {
		
		// if acknowledge is TRUE this callback will be called to notify the successful publishing
        NSLog(@"published? %@", (error==nil)?@"YES":@"NO");
    }];

### Subscribe to a Topic and handle received events:

	[wamp subscribe:@"com.topic.hello" onEvent:^(MDWampEvent *payload) {
        
        // do something with the payload of the event
        NSLog(@"received an event %@", payload.arguments);
        
    } result:^(NSError *error) {
        NSLog(@"subscribe ok? %@", (error==nil)?@"YES":@"NO");
    }];


## Tests

If you want to run the tests you have to installdependancies by using submodules so:

- clone the repository: `git clone git@github.com:mogui/MDWamp.git`
- `cd MDWamp`
- run a `git submodule init && git submodule update` inside the MDWamp cloned directory to init the SocketRocket and msgpack-objectivec dependancy.

Everything should build straight away

You can run Unit Test on `MDWamp` target without any other dependancy, BUT the tests aginst MDWampTransportWebSocket won't be run.

If you want to run the full test suite (with also code coverage) you want to run tests on `MDWamp+crossbar.io+covarege` target.

To do that you need to install an instance of crossbar.io and start it, leave all the things with default settings it will be ok

	pip install crossbar[msgpack]
	crossbar init
	crossbar start

Enjoy :)


## Changes

### 2.0

- Addopted WAMP v2 [basic protocol](https://github.com/tavendo/WAMP/blob/master/spec/basic.md)
- new library intreface, due to protocol changes
- decoupled architecture to give flexibility over new transport and serialization
- dropped iOS 5 compatibility now iOS >= 6.0 is required
- not yet supported backword compatibility with WAMP v1

### 1.1.0

- Added OSX framework target
- dropped iOS 4 compatibility now iOS >= 5.0 is required
- added block callback for connection, rpc and pub/sub messages
- removed RPC and Event delegates (now they only works with blocks)
- added unit test

## Roadmap

- make an iOS App Target in the prject to show all the features
- implement raw socket transport
- implement the [advanced protocol](https://github.com/tavendo/WAMP/blob/master/spec/advanced.md) spec
-  make the library also a Server Library integrating with GCDWebServer






##Authors & contributors
- [mogui](https://github.com/mogui/)
- [cvanderschuere](https://github.com/cvanderschuere)
- [JohnFricker](https://github.com/JohnFricker)

## Copyright
Copyright © 2012 Niko Usai. See LICENSE for details.   
WAMP is trademark of [Tavendo GmbH][tavendo].

[wamp_link]: http://wamp.ws/
[wamp_impl]: http://wamp.ws/implementations
[cocoapods]: http://cocoapods.org/
[luke]: https://github.com/lukeredpath
[ios_fake_framework_link]: https://github.com/kstenerud/iOS-Universal-Framework
[lib_pusher]: https://github.com/lukeredpath/libPusher
[socket_rocket]: https://github.com/square/SocketRocket
[downpage]: http://github.com/mogui/MDWamp/downloads]
[faq]: http://wamp.ws/faq#rpc
[tavendo]: http://www.tavendo.de/
[staticlibpost]: http://blog.mogui.it/iOS-3rd-packaging.html
