//
//  XMPPStream+SendElement.h
//  FileTransfer
//
//  Created by Admin on 11/19/12.
//
//

#import "XMPPStream.h"

@interface XMPPStream (SendElement)
- (void)sendOrginElement:(DDXMLElement *)element;
@end
