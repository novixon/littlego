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
#import "GtpResponse.h"
#import "../ApplicationDelegate.h"


@implementation GtpCommand

@synthesize command;
@synthesize client;
@synthesize response;

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
  self.client = [ApplicationDelegate sharedDelegate].gtpClient;
  self.response = [[GtpResponse alloc] init];

  return self;
}

- (void) dealloc
{
  self.command = nil;
  self.client = nil;  // not strictly necessary since we don't retain it
  self.response = nil;
  [super dealloc];
}

@end
