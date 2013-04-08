// -----------------------------------------------------------------------------
// Copyright 2013 Patrick Näf (herzbube@herzbube.ch)
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
#import "SetupApplicationCommand.h"
#import "HandleDocumentInteraction.h"
#import "LoadOpeningBookCommand.h"
#import "backup/RestoreGameCommand.h"
#import "diagnostics/RestoreBugReportApplicationState.h"
#import "../main/ApplicationDelegate.h"


// -----------------------------------------------------------------------------
/// @brief Class extension with private methods for SetupApplicationCommand.
// -----------------------------------------------------------------------------
@interface SetupApplicationCommand()
@property(nonatomic, assign) int totalSteps;
@property(nonatomic, assign) float stepIncrease;
@property(nonatomic, assign) float progress;
@end


@implementation SetupApplicationCommand

@synthesize asynchronousCommandDelegate;


// -----------------------------------------------------------------------------
/// @brief Initializes a SetupApplicationCommand object.
///
/// @note This is the designated initializer of SetupApplicationCommand.
// -----------------------------------------------------------------------------
- (id) init
{
  // Call designated initializer of superclass (CommandBase)
  self = [super init];
  if (! self)
    return nil;
  self.totalSteps = 11;
  self.stepIncrease = 1.0 / self.totalSteps;
  self.progress = 0.0;
  return self;
}

// -----------------------------------------------------------------------------
/// @brief Deallocates memory allocated by this SetupApplicationCommand object.
// -----------------------------------------------------------------------------
- (void) dealloc
{
  [super dealloc];
}

// -----------------------------------------------------------------------------
/// @brief Executes this command. See the class documentation for details.
// -----------------------------------------------------------------------------
- (bool) doIt
{
  @try
  {
    [self performSelector:@selector(postLongRunningNotificationOnMainThread:)
                 onThread:[NSThread mainThread]
               withObject:longRunningActionStarts
            waitUntilDone:YES];

    [[[[LoadOpeningBookCommand alloc] init] autorelease] submit];

    // At this point the progress in self.asynchronousCommandDelegate is at 100%.
    // From now on, other commands will take over and manage the progress, with
    // an initial resetting to 0% and display of a different message.

    ApplicationDelegate* delegate = [ApplicationDelegate sharedDelegate];
    if (ApplicationLaunchModeDiagnostics == delegate.applicationLaunchMode)
    {
      RestoreBugReportApplicationState* command = [[[RestoreBugReportApplicationState alloc] init] autorelease];
      bool success = [command submit];
      if (! success)
      {
        NSString* errorMessage = [NSString stringWithFormat:@"Failed to restore in-memory objects while launching in mode ApplicationLaunchModeDiagnostics"];
        DDLogError(@"%@: %@", [self shortDescription], errorMessage);
        NSException* exception = [NSException exceptionWithName:NSGenericException
                                                         reason:errorMessage
                                                       userInfo:nil];
        @throw exception;
      }
    }
    else
    {
      // Important: We must execute this command in the context of a thread that
      // survives the entire command execution - see the class documentation of
      // RestoreGameCommand for the reason why.
      [[[[RestoreGameCommand alloc] init] autorelease] submit];
      if (delegate.documentInteractionURL)
      {
        // Control returns before the .sgf file is actually loaded
        [[[[HandleDocumentInteraction alloc] init] autorelease] submit];
      }
    }
  }
  @finally
  {
    [self performSelector:@selector(postLongRunningNotificationOnMainThread:)
                 onThread:[NSThread mainThread]
               withObject:longRunningActionEnds
            waitUntilDone:YES];
  }

  return true;
}

// -----------------------------------------------------------------------------
/// @brief Private helper for doIt(). Is invoked in the context of the main
/// thread.
// -----------------------------------------------------------------------------
- (void) postLongRunningNotificationOnMainThread:(NSString*)notificationName
{
  [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

@end
