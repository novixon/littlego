// -----------------------------------------------------------------------------
// Copyright 2011 Patrick Näf (herzbube@herzbube.ch)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// -----------------------------------------------------------------------------


// Project includes
#import "GtpCommand.h"
#import "GtpClient.h"
#import "../ApplicationDelegate.h"


@interface GtpCommand()
- (NSString*) description;
@end


@implementation GtpCommand

@synthesize command;

+ (GtpCommand*) command:(NSString*)command
{
  GtpCommand* cmd = [[GtpCommand alloc] init];
  if (cmd)
  {
    cmd.command = command;
    [cmd autorelease];
  }
  return cmd;
}

- (GtpCommand*) init
{
  // Call designated initializer of superclass (NSObject)
  self = [super init];
  if (! self)
    return nil;

  self.command = nil;

  return self;
}

- (void) dealloc
{
  self.command = nil;
  [super dealloc];
}

- (NSString*) description
{
  return [NSString stringWithFormat:@"GtpCommand(%p): %@", self, self.command];
}

// Pure convenience method so that clients do not need to know GtpClient
// (and ApplicationDelegate, which is required to obtain the GtpClient
// instance).
- (void) submit
{
  NSLog(@"Submitting %@...", self);
  GtpClient* client = [ApplicationDelegate sharedDelegate].gtpClient;
  [client submit:self];
}

@end
