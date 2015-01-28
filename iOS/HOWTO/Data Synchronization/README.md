## PubNub Data Sync Demo for IOS

### Description of Demo

**This demo app and document are a work in progress. Please contact us at support@pubnub.com with any questions not answered in this document or demo app.**

The following application is a demo implementation of Data Sync on iOS. To follow along with the JavaScript Data Sync browser, connect with the same settings to: http://pubnub.github.io/pubnub-datasync-browser/

All method descriptions are available within [PubNub+DataSynchronization.h](https://github.com/pubnub/objective-c/blob/ds-beta/PubNub/PubNub/PubNub/Core/PubNub%2BDataSynchronization.h)

This app is a quick demo implementation which shows the use how to sync to a remote object, and have the updates on the
remote object update the local UI.

In addition, the user can mutate the object from the iOS app itself.

### Demonstration of PNDelegate Usage

The following delegates are implemented in ViewController.m:

```
pubnubClient:didConnectToOrigin:
pubnubClient:connectionDidFailWithError:
pubnubClient:didDisconnectFromOrigin:withError:
pubnubClient:didDisconnectFromOrigin:
pubnubClient:didStartObjectSynchronization:withDataAtLocations:
pubnubClient:objectSynchronization:startDidFailWithError:
pubnubClient:objectSynchronization:stopDidFailWithError:
pubnubClient:remoteObject:fetchDidFailWithError:
pubnubClient:remoteObject:dataPushDidFailWithError:
pubnubClient:remoteObject:dataReplaceDidFailWithError:
pubnubClient:remoteObject:dataRemoveDidFailWithError:
```

### Demonstration of DSDataModification Delegate Usage

The following DS-specific delegates are implemented in ViewController.m:

```
observer
mergeDataAtLocation:withData:
pushData:toLocation:withSortingKey:
replaceDataAtLocation:withData:
removeDataAtLocation:
```


