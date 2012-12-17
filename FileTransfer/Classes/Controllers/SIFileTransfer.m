//
//  SIFileTransfer.m
//  FileTransfer
//
//  Created by Admin on 12/6/12.
//
//

#import "SIFileTransfer.h"
#import "XMPPJID.h"
#import "XMPPStream.h"
#import "XMPPIQ.h"
#import "NSXMLElement+XMPP.h"

@interface SIFileTransfer ()
- (void)partDataFromRequest:(XMPPIQ *)iq;
@end

@implementation SIFileTransfer

- (BOOL)activate:(XMPPStream *)aXmppStream
{
	if ([super activate:aXmppStream])
	{
        //responseTracker = [[XMPPIDTracker alloc] initWithDispatchQueue:moduleQueue];
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

- (dispatch_queue_t)moduleQueue
{
	return moduleQueue;
}


- (id)initWithXMPPStream:(XMPPStream *)stream jid:(XMPPJID *)aJid {
    self = [super initWithDispatchQueue:dispatch_get_current_queue()];
    if (self) {
        jid = aJid;
        [self activate:stream];
    }
    return self;
}

- (id)initWithRequestId:(XMPPIQ *)iq xmppStream:(XMPPStream *)stream {
    self = [super initWithDispatchQueue:dispatch_get_current_queue()];
    if (self) {
        [self activate:stream];
        [self partDataFromRequest:iq];
    }
    return self;
}


//<iq type='set' id='offer1' to='receiver@jabber.org/resource'>
//<si xmlns='http://jabber.org/protocol/si'
//id='a0'
//mime-type='text/plain'
//profile='http://jabber.org/protocol/si/profile/file-transfer'>
//<file xmlns='http://jabber.org/protocol/si/profile/file-transfer'
//name='test.txt'
//size='1022'/>
//<feature xmlns='http://jabber.org/protocol/feature-neg'>
//<x xmlns='jabber:x:data' type='form'>
//<field var='stream-method' type='list-single'>
//<option><value>http://jabber.org/protocol/bytestreams</value></option>
//<option><value>http://jabber.org/protocol/ibb</value></option>
//</field>
//</x>
//</feature>
//</si>
//</iq>
- (void)sendRequestWithFileName:(NSString *)name
                       fileSize:(unsigned long)size
                       mineType:(NSString *)type {
    fileName = name;
    fileSize = size;
    mineType = type;
    
    dispatch_block_t block = ^{ @autoreleasepool {

		uuid = [xmppStream generateUUID];
        
        NSXMLElement *iqElement = [NSXMLElement elementWithName:@"iq"];
        [iqElement addAttributeWithName:@"type" stringValue:@"set"];
        [iqElement addAttributeWithName:@"id" stringValue:uuid];
        [iqElement addAttributeWithName:@"to" stringValue:jid.full];
        
        NSXMLElement *siElement = [NSXMLElement elementWithName:@"si" xmlns:@"http://jabber.org/protocol/si"];
        [siElement addAttributeWithName:@"id" stringValue:@"a0"];
        [siElement addAttributeWithName:@"mine-type" stringValue:mineType];
        [siElement addAttributeWithName:@"profile" stringValue:@"http://jabber.org/protocol/si/profile/file-transfer"];
        
        NSXMLElement *fileElement = [NSXMLElement elementWithName:@"file" xmlns:@"http://jabber.org/protocol/si/profile/file-transfer"];
        [fileElement addAttributeWithName:@"name" stringValue:fileName];
        [fileElement addAttributeWithName:@"size" stringValue:[NSString stringWithFormat:@"%u", fileSize]];
        
        NSXMLElement *featureElement = [NSXMLElement elementWithName:@"feature" xmlns:@"http://jabber.org/protocol/feature-neg"];
        
        NSXMLElement *xElement = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data' type='form"];
        [xElement addAttributeWithName:@"type" stringValue:@"form"];
        
        NSXMLElement *fieldElement = [NSXMLElement elementWithName:@"field"];
        [fieldElement addAttributeWithName:@"var" stringValue:@"stream-method"];
        [fieldElement addAttributeWithName:@"type" stringValue:@"list-single"];
        
        NSXMLElement *optionElement = [NSXMLElement elementWithName:@"option"];
        
        NSXMLElement *valueElement = [NSXMLElement elementWithName:@"value" stringValue:@"http://jabber.org/protocol/ibb"];
        
        //Add child elements
        [optionElement addChild:valueElement];
        [fieldElement addChild:optionElement];
        [xElement addChild:fieldElement];
        [featureElement addChild:xElement];
        [siElement addChild:fileElement];
        [siElement addChild:featureElement];
        [iqElement addChild:siElement];
				
		[xmppStream sendElement:iqElement];
		
//		[responseTracker addID:uuid
//		                target:self
//		              selector:@selector(handleRequestFileResponse:withInfo:)
//		               timeout:60.0];
		
	}};
	
	if (dispatch_get_current_queue() == moduleQueue)
		block();
	else
		dispatch_async(moduleQueue, block);
    
}


//<iq type='result' to='sender@jabber.org/resource' id='offer1'>
//<si xmlns='http://jabber.org/protocol/si'>
//<feature xmlns='http://jabber.org/protocol/feature-neg'>
//<x xmlns='jabber:x:data' type='submit'>
//<field var='stream-method'>
//<value>http://jabber.org/protocol/bytestreams</value>
//</field>
//</x>
//</feature>
//</si>
//</iq>

- (void)sendResponseResult {
    
    //Create iq element
    NSXMLElement *iqElement = [NSXMLElement elementWithName:@"iq"];
    [iqElement addAttributeWithName:@"to" stringValue:jid.full];
    [iqElement addAttributeWithName:@"type" stringValue:@"result"];
    [iqElement addAttributeWithName:@"id" stringValue:uuid];
    
    //Create si element
    NSXMLElement *siElement = [NSXMLElement elementWithName:@"si" xmlns:@"http://jabber.org/protocol/si"];

    //Create feature element
    NSXMLElement *featureElement = [NSXMLElement elementWithName:@"feature" xmlns:@"http://jabber.org/protocol/feature-neg"];
    
    //Create x element
    NSXMLElement *xElement = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    [xElement addAttributeWithName:@"type" stringValue:@"submit"];
    
    //Create field element
    NSXMLElement *fieldElement = [NSXMLElement elementWithName:@"field"];
    [fieldElement addAttributeWithName:@"var" stringValue:@"stream-method"];
    
    //Create value element
    NSXMLElement *valueElement = [NSXMLElement elementWithName:@"value" stringValue:@"http://jabber.org/protocol/ibb"];
    
    //Add child elements
    [fieldElement addChild:valueElement];
    [xElement addChild:fieldElement];
    [featureElement addChild:xElement];
    [siElement addChild:featureElement];
    [iqElement addChild:siElement];
    
    dispatch_block_t block = ^{ @autoreleasepool {
		[xmppStream sendElement:iqElement];
		
	}};
	
	if (dispatch_get_current_queue() == moduleQueue)
		block();
	else
		dispatch_async(moduleQueue, block);
}

- (NSString *)fileName {
    return fileName;
}

- (NSInteger)fileSize {
    return fileSize;
}
#pragma mark - XMPPStream delegate
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	NSString *type = [iq type];
    NSXMLElement *siElement = [iq elementForName:@"si" xmlns:@"http://jabber.org/protocol/si"];
    
    if (siElement) {
        if ([type isEqualToString:@"result"]){
            [multicastDelegate siFileTransfer:self didReceiveFileTransferReponse:iq];
        }
    }
	return NO;
}


- (void)handleRequestFileResponse:(XMPPIQ *)iq withInfo:(id <XMPPTrackingInfo>)info
{
	if ([[iq type] isEqualToString:@"result"])
	{		
		[multicastDelegate siFileTransfer:self didReceiveFileTransferReponse:iq];
	}
}

#pragma mark - Private method
- (void)partDataFromRequest:(XMPPIQ *)iq {
    NSString *jidStr = [iq attributeStringValueForName:@"from"];
    jid = [XMPPJID jidWithString:jidStr];
    uuid = [iq attributeStringValueForName:@"id"];
    
    NSXMLElement *siElement = [iq elementForName:@"si"];
    mineType = [siElement attributeStringValueForName:@"mine-type"];
    
    NSXMLElement *fileElement = [siElement elementForName:@"file"];
    fileName = [fileElement attributeStringValueForName:@"name"];
    fileSize = [fileElement attributeUnsignedIntegerValueForName:@"size"];
}

@end
