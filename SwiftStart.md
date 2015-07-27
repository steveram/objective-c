#PubNub iOS SDK 4.0.3
#Swift Guide

##How to Get It: Cocoapods
CocoaPods is a dependency manager for Objective-C projects and this is by far the easiest and quickest way to get started with PubNub iOS SDK!

Be sure you are running CocoaPods 0.26.2 or above! You can install the latest cocopods gem (If you don't have pods installed yet you can check CocoaPods installation section for installation guide):
	
	gem install cocoapods
	
If you've already installed you can upgrade to the latest cocoapods gem using:
	
	gem update cocoapods
	
PubNub SDK itself has dependencies on AFNetworking and CocoaLumberjack. These libraries will be added to your project as well.

##How to Get It: Gits
Add the PubNub iOS SDK folder to your project.

##How to Get It: Source
https://github.com/pubnub/objective-c/

---
Also Available In The PubNub iOS Family:
Objective-C

---
##Hello World
To include PubNub iOS SDK in your project you need to use CocoaPods 
Install cocoapods gem by following the procedure defined under How to Get It.

To add the PubNub iOS SDK to your project with CocoaPods, there are three basic tasks to complete which are covered below:

1. Create new Xcode project.
2. Create Podfile in new Xcode project root folder
		
		touch Podfile
3.	Your Podfile should be in the root of the directory and look something like this:

			# It's good practice to include the Pod source in your Podfile
			source 'https://github.com/CocoaPods/Specs.git'
			
			# specify platform and target OS version
			platform :ios, '7.0'
			
			# this would be the relative path of your app, whatever that may be
			xcodeproj 'SimplePubSub/SimplePubSub.xcodeproj'
			
			# this is the relative location of your workspace, I prefer to explicity 
			# indicate this, though it is not always required. Feel free to use whatever
			# name for your workspace that you would like.
			workspace 'Examples.xcworkspace'
			
			# here we include the wonderful new PubNub pod
			pod 'PubNub', '~> 4.0'

If you have any other pods you’d like to include, they should be added to this Podfile. If you have other targets you’d like to add, like a test target, then you can add them to this Podfile. Cocoapods has great documentation for this on their site.


4. Install your pods by running “pod install” via the command line from the directory that contains your Podfile. Keep in mind, that after installing your Pods you should only be working within the workspace specified in your Podfile.

###How To Add Objective-C Bridging-Header

Now to add the bridging header

Great! You now have a Swift project with the PubNub SDK installed. So how do you access the PubNub SDK? With a [Swift Bridging Header](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html) of course! In order to install this, Apple has provided us with some handy shortcuts.

Create a new File (File -> New -> File) of type Objective-C File. Call this whatever you like because we will end up deleting this file. Here I have just called it willDelete.

When you see “Would you like to configure an Objective-C bridging header?” select Yes. 

There are now two small steps remaining. The first is to delete that unnecessary Objective-C file we just added (it’s easier to let Apple configure the header for us using this method than actually tweaking the project settings ourselves). So delete that file (I called mine willDelete.m)

Click on the File: YourProject-Bridging-Header.h. Underneath the commented code we need to add an #import to our project to use the PubNub iOS SDK. To do this we simply add the following lines into this file:

	        #import <PubNub/PubNub.h>

###Complete Application Delegate Configuration
Add the PNObjectEventListener protocol to AppDelegate
  
      class AppDelegate: UIResponder, UIApplicationDelegate, PNObjectEventListener {
        func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
          ...
        }
       ...
      }
      
###Initialize the PN Instance, Subscribe and Publish a Message
      
      let client : PubNub
      let config : PNConfiguration
      
      override init(){
        config = PNConfiguration(publishKey: "Your_Pub_Key", subscribeKey: "Your_Sub_Key")
        client = PubNub.clientWithConfiguration(config)
        super.init()
        client?.addListener(self)
      }
      
      func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
          client?.subscribeToChannels(["my_channel"], withPresence: true)
      }
       
       
      func client(client: PubNub!, didReceiveMessage message: PNMessageResult!, withStatus status: PNErrorStatus!) {
          println("Received message: \(message.data.message) on channel \(message.data.subscribedChannel) at \(message.data.timetoken)")
      }
        
      func client(client: PubNub!, didReceiveStatus status: PNSubscribeStatus!) {
        if(status.category == PNStatusCategory.PNUnexpectedDisconnectCategory){
            // This event happens when radio / connectivity is lost
        }
        else if(status.category == PNStatusCategory.PNConnectedCategory){
            // Connect event. You can do stuff like publish, and know you'll get it.
            // Or just use the connected event to confirm you are subscribed for
            // UI / internal notifications, etc
            
            self.client?.publish("Hello from the PubNub Swift SDK", toChannel: "my_channel", compressed: false, withCompletion: { (status) -> Void in
                if let Status = status{
                    // Message successfully published to specified channel.
                }
                else{
                    // Handle message publish error. Check 'category' property to find out possible issue
                    // because of which request did fail.
                    //
                    // Request can be resent using: [status retry];
                }
            })
        }
        else if(status.category == PNStatusCategory.PNReconnectedCategory){
            // Happens as part of our regular operation. This event happens when
            // radio / connectivity is lost, then regained.
        }
        else if(status.category == PNStatusCategory.PNDecryptionErrorCategory){
            // Handle messsage decryption error. Probably client configured to
            // encrypt messages and on live data feed it received plain text.
        }
      }
      
##Copy and paste examples:
###INIT
Instantiate a new PubNub instance. Only the subscribeKey is mandatory. Also include publishKey if you intend to publish from this instance.

	let client : PubNub
	let config : PNConfiguration
	config = PNConfiguration(publishKey: "Your_Pub_Key", subscribeKey: "Your_Sub_Key")
  	client = PubNub.clientWithConfiguration(config)
  	
 ***PubNub instance should be placed as a property in a long-life object(otherwise PubNub instance will be automatically removed as autoreleased object). ***
 
 Not sure what to put here *****
 
###Time
Call timeWithCompletion to verify the client connectivity to the origin:
       
       self.client?.timeWithCompletion({ (result, status) -> Void in
          // Check whether request successfully completed or not.
          if let Status = status{
              // Handle downloaded server time token using: result.data.timetoken
          }
          // Request processing failed.
          else{
              // Handle tmie token download error. Check 'category' property to find
              // out possible issue because of which request did fail.
              //
              // Request can be resent using: [status retry];
          }
      })
      
###Subscribe
Subscribe (listen on) a channel (it's async!):
     
      self.client?.addListener(self)
      self.client?.subscribeToChannels(["my_channel1","my_channel2"], withPresence: false)
      func client(client: PubNub!, didReceiveMessage message: PNMessageResult!, withStatus status: PNErrorStatus!) {
          println("Received message: \(message.data.message) on channel \(message.data.subscribedChannel) at \(message.data.timetoken)")
      }
      
      func client(client: PubNub!, didReceiveStatus status: PNSubscribeStatus!) {
          if(status.category == PNStatusCategory.PNUnexpectedDisconnectCategory){
              // This event happens when radio / connectivity is lost
          }
          else if(status.category == PNStatusCategory.PNConnectedCategory){
              // Connect event. You can do stuff like publish, and know you'll get it.
              // Or just use the connected event to confirm you are subscribed for
              // UI / internal notifications, etc
              
              self.client?.publish("Hello from the PubNub Swift SDK", toChannel: "my_channel", compressed: false, withCompletion: { (status) -> Void in
                  if let Status = status{
                      // Message successfully published to specified channel.
                  }
                  else{
                      // Handle message publish error. Check 'category' property to find out possible issue
                      // because of which request did fail.
                      //
                      // Request can be resent using: [status retry];
                  }
              })
          }
          else if(status.category == PNStatusCategory.PNReconnectedCategory){
              // Happens as part of our regular operation. This event happens when
              // radio / connectivity is lost, then regained.
          }
          else if(status.category == PNStatusCategory.PNDecryptionErrorCategory){
              // Handle messsage decryption error. Probably client configured to
              // encrypt messages and on live data feed it received plain text.
          }
      }
      
###Publish
Publish a message to a channel:
      
      self.client?.publish("Hello from the PubNub Swift SDK", toChannel: "my_channel", compressed: false, withCompletion: { (status) -> Void in
        if let Status = status{
            // Message successfully published to specified channel.
        }
        else{
            // Handle message publish error. Check 'category' property to find out possible issue
            // because of which request did fail.
            //
            // Request can be resent using: [status retry];
        }
      })
      
###Here Now
Get occupancy of who's here now on the channel by UUID:
     
      self.client?.hereNowWithCompletion({ (result, status) -> Void in
        // Check whether request successfully completed or not.
        if let Result = result{
          println("^^^^ Loaded Global hereNow data: channels: \(result.data.channels), total channels: \(result.data.totalChannels), total occupancy: \(result.data.totalOccupancy)")
          //  Handle downloaded presence information using:
          //  result.data.uuids - list of uuids.
          //  result.data.occupancy - total number of active subscribers.
        }
        else{
          // Handle presence audit error. Check 'category' property to find
          // out possible issue because of which request did fail.
          //
          // Request can be resent using: [status retry];
        }
      })
      
###Presence
Subscribe to real-time Presence events, such as join, leave, and timeout, by UUID. Setting the presence attribute to a callback will subscribe to presents events on my_channel:
***Requires that the Presence add-on is enabled for your key. How do I enable add-on features for my keys? - see http://www.pubnub.com/knowledge-base/discussion/644/how-do-i-enable-add-on-features-for-my-keys ***
      
      self.client?.addListener(self)
      client?.subscribeToPresenceChannels(["my_channel"])
      
      func client(client: PubNub!, didReceivePresenceEvent event: PNPresenceEventResult!) {
      // Handle presence event event.data.presenceEvent (one of: join, leave, timeout, 
      // state-change).
              if (event.data.actualChannel) {
              // Presence event has been received on channel group stored in
              // event.data.subscribedChannel
          }
          else {
       
              // Presence event has been received on channel stored in
              // event.data.subscribedChannel
          }
          println("Did receive presence event: \(event.data.presenceEvent)");
      }
      func client(client: PubNub!, didReceiveStatus status: PNSubscribeStatus!) {
        if(status.category == PNStatusCategory.PNUnexpectedDisconnectCategory){
          // This event happens when radio / connectivity is lost
        }
        else if(status.category == PNStatusCategory.PNConnectedCategory){
          // Connect event. You can do stuff like publish, and know you'll get it.
          // Or just use the connected event to confirm you are subscribed for
          // UI / internal notifications, etc
          
          self.client?.publish("Hello from the PubNub Swift SDK", toChannel: "my_channel", compressed: false, withCompletion: { (status) -> Void in
              if let Status = status{
                  // Message successfully published to specified channel.
              }
              else{
                  // Handle message publish error. Check 'category' property to find out possible issue
                  // because of which request did fail.
                  //
                  // Request can be resent using: [status retry];
              }
          })
        }
        else if(status.category == PNStatusCategory.PNReconnectedCategory){
          // Happens as part of our regular operation. This event happens when
          // radio / connectivity is lost, then regained.
        }
        else if(status.category == PNStatusCategory.PNDecryptionErrorCategory){
          // Handle messsage decryption error. Probably client configured to
          // encrypt messages and on live data feed it received plain text.
        }
      }

###History
Retrieve published messages from archival storage:

***Requires that the Storage and Playback add-on is enabled for your key. How do I enable add-on features for my keys? - see http://www.pubnub.com/knowledge-base/discussion/644/how-do-i-enable-add-on-features-for-my-keys***
      
      client?.historyForChannel("demo", start: nil, end: nil, includeTimeToken: true, withCompletion: { (PNHistoryResult result, PNErrorStatus status) -> Void in
        if let Status = status{
         // Handle downloaded history using: 
         //   result.data.start - oldest message time stamp in response
         //   result.data.end - newest message time stamp in response
         //   result.data.messages - list of messages
        }
        // Request processing failed.
       else {
         // Handle message history download error. Check 'category' property to find
         // out possible issue because of which request did fail.
         //
         // Request can be resent using: [status retry];
        }
      })
      
###Unsubscribe
Stop subscribing (listening) to a channel.
      
      client?.addListener(self)
      self.client?.unsubscribeFromChannels(["my_channel1","my_channel2"], withPresence: false)
      func client(client: PubNub!, didReceiveStatus status: PNSubscribeStatus!) {
        if(status.category == PNStatusCategory.PNUnexpectedDisconnectCategory){
          // This event happens when radio / connectivity is lost
        }
        else if(status.category == PNStatusCategory.PNConnectedCategory){
          // Connect event. You can do stuff like publish, and know you'll get it.
          // Or just use the connected event to confirm you are subscribed for
          // UI / internal notifications, etc
          
          self.client?.publish("Hello from the PubNub Swift SDK", toChannel: "my_channel", compressed: false, withCompletion: { (status) -> Void in
              if let Status = status{
                  // Message successfully published to specified channel.
              }
              else{
                  // Handle message publish error. Check 'category' property to find out possible issue
                  // because of which request did fail.
                  //
                  // Request can be resent using: [status retry];
              }
          })
        }
        else if(status.category == PNStatusCategory.PNReconnectedCategory){
          // Happens as part of our regular operation. This event happens when
          // radio / connectivity is lost, then regained.
        }
        else if(status.category == PNStatusCategory.PNDecryptionErrorCategory){
          // Handle messsage decryption error. Probably client configured to
          // encrypt messages and on live data feed it received plain text.
        }
      }
