//
//  InBandByteStreams.m
//  FileTransfer
//
//  Created by Admin on 12/7/12.
//
//

#import "InBandByteStreams.h"
#import "NSXMLElement+XMPP.h"
#import <RestKit/NSData+Base64.h>
#import "MBProgressHUD.h"

#define BUFFER_SIZE 4000
#define BLOK_ZIE 4096

@interface InBandByteStreams ()
- (void)partDataInIqRequest:(XMPPIQ *)iq;
- (NSData *)dataReceived;
@end

@implementation InBandByteStreams
- (BOOL)activate:(XMPPStream *)aXmppStream
{
	if ([super activate:aXmppStream])
	{
        responseTracker = [[XMPPIDTracker alloc] initWithDispatchQueue:moduleQueue];
		return YES;
	}
	
	return NO;
}

- (void)deactivate
{
	dispatch_block_t block = ^{ @autoreleasepool {
		[responseTracker removeAllIDs];
		responseTracker = nil;
		
	}};
	
	if (dispatch_get_current_queue() == moduleQueue)
		block();
	else
		dispatch_sync(moduleQueue, block);
	[super deactivate];
}

- (id)initWithXMPPStream:(XMPPStream *)stream jid:(XMPPJID *)aJid {
    self = [self initWithDispatchQueue:dispatch_get_main_queue()];
    if (self) {
        [self activate:stream];
        [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        jid = aJid;
        dataDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;    
}

- (id)initWithRequestId:(XMPPIQ *)iq xmppStream:(XMPPStream *)stream {
    self = [self initWithDispatchQueue:dispatch_get_main_queue()];
    if (self) {
        [self activate:stream];
        [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [self partDataInIqRequest:iq];
        dataDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)sendFileAtPath:(NSString *)path {
    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:path];
    [inputStream open];
    Byte buffer[BUFFER_SIZE];
    while ([inputStream hasBytesAvailable]) {
        int bytesRead = [inputStream read:buffer maxLength:BUFFER_SIZE];
        NSData *myData = [NSData dataWithBytes:buffer length:bytesRead];
        NSString *base64DataString = [myData base64EncodedString];
        [self sendData:base64DataString withSeq:currentSeq++];
    }
}

- (void)sendFileData:(NSData *)data {
    MBProgressHUD *hub = [[MBProgressHUD alloc] initWithView:[[[UIApplication sharedApplication] windows] lastObject]];
    [hub showAnimated:YES whileExecutingBlock:^{
        NSUInteger length = [data length];
        NSUInteger offset = 0;
        [multicastDelegate inBandByStreams:self didStartSendFile:nil];
        do {
            NSUInteger thisChunckSize = length - offset > BLOK_ZIE ? BLOK_ZIE : length - offset;
            NSData *chuck = [NSData dataWithBytesNoCopy:(char *)[data bytes] + offset length:thisChunckSize freeWhenDone:NO];
            NSString *base64DataString = [chuck base64EncodedString];
            [self sendData:base64DataString withSeq:currentSeq++];
            offset += thisChunckSize;
            
        } while (offset < length);
        [self sendCloseStream];
        [multicastDelegate inBandByteStreams:self didFinishSendFile:nil];
    }];
    
}
//<iq from='romeo@montague.net/orchard'
//id='jn3h8g65'
//to='juliet@capulet.com/balcony'
//type='set'>
//<open xmlns='http://jabber.org/protocol/ibb'
//block-size='4096'
//sid='i781hf64'
//stanza='iq'/>
//</iq>
- (void)sendRequestInitiatorSession {
    dispatch_block_t block = ^{ @autoreleasepool {
        
		uuid = [xmppStream generateUUID];
        sid = [xmppStream generateUUID];
        
        //Create iq element
        NSXMLElement *iqElement = [NSXMLElement elementWithName:@"iq"];
        [iqElement addAttributeWithName:@"to" stringValue:jid.full];
        [iqElement addAttributeWithName:@"type" stringValue:@"set"];
        [iqElement addAttributeWithName:@"id" stringValue:uuid];
        
        //Create open element
        NSXMLElement *openElement = [NSXMLElement elementWithName:@"open" xmlns:@"http://jabber.org/protocol/ibb"];
        [openElement addAttributeWithName:@"sid" stringValue:sid];
        [openElement addAttributeWithName:@"stanza" stringValue:@"iq"];
        [openElement addAttributeWithName:@"block-size" stringValue:[NSString stringWithFormat:@"%d", BLOK_ZIE]];
        
        //Add child element
        [iqElement addChild:openElement];
        
        
		[xmppStream sendElement:iqElement];
//                [responseTracker addID:uuid
//        		                target:self
//        		              selector:@selector(handleRequestSessionResponse:withInfo:)
//        		               timeout:60.0];
		
	}};
	
	if (dispatch_get_current_queue() == moduleQueue)
		block();
	else
		dispatch_async(moduleQueue, block);

}

//<iq from='juliet@capulet.com/balcony'
//id='jn3h8g65'
//to='romeo@montague.net/orchard'
//type='result'/>
- (void)responseAcceptSession {
    dispatch_block_t block = ^{ @autoreleasepool {
        NSXMLElement *iqElement = [NSXMLElement elementWithName:@"iq"];
        [iqElement addAttributeWithName:@"to" stringValue:jid.full];
        [iqElement addAttributeWithName:@"type" stringValue:@"result"];
        [iqElement addAttributeWithName:@"id" stringValue:uuid];
		[xmppStream sendElement:iqElement];
	}};
	
	if (dispatch_get_current_queue() == moduleQueue)
		block();
	else
		dispatch_async(moduleQueue, block);
}

//<iq from='romeo@montague.net/orchard'
//id='us71g45j'
//to='juliet@capulet.com/balcony'
//type='set'>
//<close xmlns='http://jabber.org/protocol/ibb' sid='i781hf64'/>
//</iq>
- (void)sendCloseStream {
    dispatch_block_t block = ^{ @autoreleasepool {
        NSString *iqID = [xmppStream generateUUID];
        
        NSXMLElement *iqElement = [NSXMLElement elementWithName:@"iq"];
        [iqElement addAttributeWithName:@"to" stringValue:jid.full];
        [iqElement addAttributeWithName:@"type" stringValue:@"set"];
        [iqElement addAttributeWithName:@"id" stringValue:iqID];
        
        //Create close element
        NSXMLElement *closeElement = [NSXMLElement elementWithName:@"close" xmlns:@"http://jabber.org/protocol/ibb"];
        [closeElement addAttributeWithName:@"sid" stringValue:sid];
        
        //Add child element
        [iqElement addChild:closeElement];
		[xmppStream sendElement:iqElement];
	}};
	
	if (dispatch_get_current_queue() == moduleQueue)
		block();
	else
		dispatch_async(moduleQueue, block);    
}

#pragma mark - XMPPStream delegate
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
    NSXMLElement *dataElement = [iq elementForName:@"data"];
    if (dataElement) {
        NSString *sidString = [dataElement attributeStringValueForName:@"sid"];
        if ([sidString isEqualToString:sid]) {
            //Receive data
            NSString *seq = [dataElement attributeStringValueForName:@"seq"];
            if ([seq integerValue] == 0) {
                [multicastDelegate inBandByteStreams:self didStartReceiveFile:nil];
            }
            
            NSString *data = [dataElement stringValue];
            [dataDictionary setValue:data forKey:seq];
        }
    }
    
    else if ([self isReponseAcceptSession:iq]) {
        [multicastDelegate didReceiveResponseSessionAcceptByteStream:self];
    }
    
    else if ([self closeStreamElement:iq]) {
        NSData *data = [self dataReceived];
        [multicastDelegate inBandByteStreams:self didFinishReceiveFile:data];
    }
    return NO;
}

#pragma mark - Private
- (void)sendData:(NSString *)dataString withSeq:(int)seq {
    dispatch_block_t block = ^{ @autoreleasepool {
        
		NSString *iqID = [xmppStream generateUUID];
        
        //Create iq element
        NSXMLElement *iqElement = [NSXMLElement elementWithName:@"iq"];
        [iqElement addAttributeWithName:@"to" stringValue:jid.full];
        [iqElement addAttributeWithName:@"type" stringValue:@"set"];
        [iqElement addAttributeWithName:@"id" stringValue:iqID];
        
        //create data element
        NSXMLElement *dataElement = [NSXMLElement elementWithName:@"data" xmlns:@"http://jabber.org/protocol/ibb"];
        [dataElement addAttributeWithName:@"seq" stringValue:[NSString stringWithFormat:@"%d", seq]];
        [dataElement addAttributeWithName:@"sid" stringValue:sid];
        [dataElement setStringValue:dataString];
        //Add child element
        [iqElement addChild:dataElement];
        
		[xmppStream sendElement:iqElement];
//        [responseTracker addID:iqID
//		                target:self
//		              selector:@selector(handleRequestFileResponse:withInfo:)
//		               timeout:60.0];
		
	}};
	
	if (dispatch_get_current_queue() == moduleQueue)
		block();
	else
		dispatch_async(moduleQueue, block);
}


- (void)partDataInIqRequest:(XMPPIQ *)iq {
    uuid = [iq elementID];
    NSString *jidString = [iq attributeStringValueForName:@"from"];
    jid = [XMPPJID jidWithString:jidString];
    
    NSXMLElement *openElement = [iq elementForName:@"open"];
    blockSize = [openElement attributeInt32ValueForName:@"block-size"];
    sid = [openElement attributeStringValueForName:@"sid"];
    stanza = [openElement attributeStringValueForName:@"stanza"];
}

- (BOOL)closeStreamElement:(XMPPIQ *)iq {
    NSXMLElement *closeElement = [iq elementForName:@"close" xmlns:@"http://jabber.org/protocol/ibb"];
    if (closeElement) {
        NSString *sidString = [closeElement attributeStringValueForName:@"sid"];
        if ([sid isEqualToString:sidString]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isDataMessage:(XMPPIQ *)iq {
    NSXMLElement *dataElement = [iq elementForName:@"data"];
    if (dataElement) {
        NSString *sidString = [dataElement attributeStringValueForName:@"sid"];
        if ([sidString isEqualToString:sid]) {
            //Receive data
            NSString *seq = [dataElement attributeStringValueForName:@"seq"];
            NSString *data = [dataElement stringValue];
            [dataDictionary setValue:data forKey:seq];
        }
    }
    return NO;
}

- (BOOL)isReponseAcceptSession:(XMPPIQ *)iq {
    NSString *idString = [iq elementID];
    NSString *type = [iq attributeStringValueForName:@"type"];
    if ([type isEqualToString:@"result"]) {
        if ([idString isEqualToString:uuid]) {
            return YES;
        }
    }
    return NO;
}

- (NSData *)dataReceived {
    NSMutableData *mutableData = [[NSMutableData alloc] init];
    NSArray *keys = [dataDictionary allKeys];
    for (int i=0; i<keys.count; i++) {
        NSString *keyString = [NSString stringWithFormat:@"%d", i];
        NSData *data = [NSData dataFromBase64String:[dataDictionary objectForKey:keyString]];        
        [mutableData appendData:data];
    }
    return mutableData;
}

//handle reponse
- (void)handleRequestSessionResponse:(XMPPIQ *)iq withInfo:(id <XMPPTrackingInfo>)info
{
	if ([[iq type] isEqualToString:@"result"])
	{
        [multicastDelegate didReceiveResponseSessionAcceptByteStream:self];
	}
    else {
        [multicastDelegate didReceiveResponseSessionCancelByteStream:self];
    }
}
@end
