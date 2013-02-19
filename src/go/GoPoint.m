// -----------------------------------------------------------------------------
// Copyright 2011-2012 Patrick Näf (herzbube@herzbube.ch)
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
#import "GoPoint.h"
#import "GoBoard.h"
#import "GoVertex.h"


// -----------------------------------------------------------------------------
/// @brief Class extension with private methods for GoPoint.
// -----------------------------------------------------------------------------
@interface GoPoint()
/// @name Initialization and deallocation
//@{
- (id) initWithVertex:(GoVertex*)aVertex onBoard:(GoBoard*)aBoard;
- (void) dealloc;
//@}
/// @name NSCoding protocol
//@{
- (id) initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;
//@}
/// @name Other methods
//@{
- (NSString*) description;
//@}
/// @name Privately declared properties
//@{
@property(nonatomic, assign) bool isLeftValid;
@property(nonatomic, assign) bool isRightValid;
@property(nonatomic, assign) bool isAboveValid;
@property(nonatomic, assign) bool isBelowValid;
@property(nonatomic, assign) bool isNextValid;
@property(nonatomic, assign) bool isPreviousValid;
//@}
@end


@implementation GoPoint

@synthesize left=_left;
@synthesize right=_right;
@synthesize above=_above;
@synthesize below=_below;
@synthesize neighbours=_neighbours;
@synthesize next=_next;
@synthesize previous=_previous;


// -----------------------------------------------------------------------------
/// @brief Convenience constructor. Creates a GoPoint instance located at the
/// intersection identified by @a vertex.
///
/// Raises an @e NSInvalidArgumentException if either @a aVertex or @a aBoard
/// is nil.
// -----------------------------------------------------------------------------
+ (GoPoint*) pointAtVertex:(GoVertex*)vertex onBoard:(GoBoard*)board
{
  if (! vertex || ! board)
  {
    NSString* errorMessage = @"GoVertex or GoBoard argument is nil";
    DDLogError(@"%@: %@", self, errorMessage);
    NSException* exception = [NSException exceptionWithName:NSInvalidArgumentException
                                                     reason:errorMessage
                                                   userInfo:nil];
    @throw exception;
  }

  GoPoint* point = [[GoPoint alloc] initWithVertex:vertex onBoard:board];
  if (point)
  {
    point.vertex = vertex;
    [point autorelease];
  }
  return point;
}

// -----------------------------------------------------------------------------
/// @brief Initializes a GoPoint object. The GoPoint is located at the
/// intersection identified by @a vertex. The GoPoint has no stone, and is not
/// part of any GoBoardRegion.
///
/// @note This is the designated initializer of GoPoint.
// -----------------------------------------------------------------------------
- (id) initWithVertex:(GoVertex*)aVertex onBoard:(GoBoard*)aBoard
{
  // Call designated initializer of superclass (NSObject)
  self = [super init];
  if (! self)
    return nil;

  self.vertex = aVertex;
  self.board = aBoard;
  self.starPoint = false;
  self.stoneState = GoColorNone;
  _left = nil;
  _right = nil;
  _above = nil;
  _below = nil;
  _next = nil;
  _previous = nil;
  _neighbours = nil;
  _isLeftValid = false;
  _isRightValid = false;
  _isAboveValid = false;
  _isBelowValid = false;
  _isNextValid = false;
  _isPreviousValid = false;

  return self;
}

// -----------------------------------------------------------------------------
/// @brief NSCoding protocol method.
// -----------------------------------------------------------------------------
- (id) initWithCoder:(NSCoder*)decoder
{
  self = [super init];
  if (! self)
    return nil;

  if ([decoder decodeIntForKey:nscodingVersionKey] != nscodingVersion)
    return nil;
  self.vertex = [decoder decodeObjectForKey:goPointVertexKey];
  self.board = [decoder decodeObjectForKey:goPointBoardKey];
  _left = [decoder decodeObjectForKey:goPointLeftKey];
  _right = [decoder decodeObjectForKey:goPointRightKey];
  _above = [decoder decodeObjectForKey:goPointAboveKey];
  _below = [decoder decodeObjectForKey:goPointBelowKey];
  _neighbours = [[decoder decodeObjectForKey:goPointNeighboursKey] retain];
  _next = [decoder decodeObjectForKey:goPointNextKey];
  _previous = [decoder decodeObjectForKey:goPointPreviousKey];
  self.starPoint = [decoder decodeBoolForKey:goPointIsStarPointKey];
  self.stoneState = [decoder decodeIntForKey:goPointStoneStateKey];
  self.region = [decoder decodeObjectForKey:goPointRegionKey];
  self.isLeftValid = [decoder decodeBoolForKey:goPointIsLeftValidKey];
  self.isRightValid = [decoder decodeBoolForKey:goPointIsRightValidKey];
  self.isAboveValid = [decoder decodeBoolForKey:goPointIsAboveValidKey];
  self.isBelowValid = [decoder decodeBoolForKey:goPointIsBelowValidKey];
  self.isNextValid = [decoder decodeBoolForKey:goPointIsNextValidKey];
  self.isPreviousValid = [decoder decodeBoolForKey:goPointIsPreviousValidKey];

  return self;
}

// -----------------------------------------------------------------------------
/// @brief Deallocates memory allocated by this GoPoint object.
// -----------------------------------------------------------------------------
- (void) dealloc
{
  self.vertex = nil;
  self.board = nil;
  [_neighbours release];
  [super dealloc];
}

// -----------------------------------------------------------------------------
/// @brief Returns a description for this GoPoint object.
///
/// This method is invoked when GoPoint needs to be represented as a string,
/// i.e. by NSLog, or when the debugger command "po" is used on the object.
// -----------------------------------------------------------------------------
- (NSString*) description
{
  // Don't use self to access properties to avoid unnecessary overhead during
  // debugging
  return [NSString stringWithFormat:@"GoPoint(%p): vertex = %@, stone state = %d", self, _vertex.string, _stoneState];
}

// -----------------------------------------------------------------------------
/// @brief Returns the GoPoint object that is the direct neighbour of this
/// GoPoint object in #GoBoardDirectionLeft. Returns nil if this GoPoint object
/// is located at the left edge of the Go board.
// -----------------------------------------------------------------------------
- (GoPoint*) left
{
  if (! _isLeftValid)
  {
    _isLeftValid = true;
    _left = [self.board neighbourOf:self inDirection:GoBoardDirectionLeft];
  }
  return _left;
}

// -----------------------------------------------------------------------------
/// @brief Returns the GoPoint object that is the direct neighbour of this
/// GoPoint object in #GoBoardDirectionRight. Returns nil if this GoPoint object
/// is located at the right edge of the Go board.
// -----------------------------------------------------------------------------
- (GoPoint*) right
{
  if (! _isRightValid)
  {
    _right = [self.board neighbourOf:self inDirection:GoBoardDirectionRight];
    _isRightValid = true;
  }
  return _right;
}

// -----------------------------------------------------------------------------
/// @brief Returns the GoPoint object that is the direct neighbour of this
/// GoPoint object in #GoBoardDirectionUp. Returns nil if this GoPoint object
/// is located at the upper edge of the Go board.
// -----------------------------------------------------------------------------
- (GoPoint*) above
{
  if (! _isAboveValid)
  {
    _above = [self.board neighbourOf:self inDirection:GoBoardDirectionUp];
    _isAboveValid = true;
  }
  return _above;
}

// -----------------------------------------------------------------------------
/// @brief Returns the GoPoint object that is the direct neighbour of this
/// GoPoint object in #GoBoardDirectionDown. Returns nil if this GoPoint object
/// is located at the lower edge of the Go board.
// -----------------------------------------------------------------------------
- (GoPoint*) below
{
  if (! _isBelowValid)
  {
    _below = [self.board neighbourOf:self inDirection:GoBoardDirectionDown];
    _isBelowValid = true;
  }
  return _below;
}

// -----------------------------------------------------------------------------
/// @brief Returns a list of up to 4 GoPoint objects that are the direct
/// neighbours of this GoPoint object in #GoBoardDirectionLeft,
/// #GoBoardDirectionRight, #GoBoardDirectionUp and #GoBoardDirectionDown. The
/// returned list has no particular order.
// -----------------------------------------------------------------------------
- (NSArray*) neighbours
{
  if (! _neighbours)
  {
    _neighbours = [[NSMutableArray arrayWithCapacity:0] retain];
    if (self.left)
      [(NSMutableArray*)_neighbours addObject:self.left];
    if (self.right)
      [(NSMutableArray*)_neighbours addObject:self.right];
    if (self.above)
      [(NSMutableArray*)_neighbours addObject:self.above];
    if (self.below)
      [(NSMutableArray*)_neighbours addObject:self.below];
  }
  return [[_neighbours retain] autorelease];
}

// -----------------------------------------------------------------------------
/// @brief Returns the GoPoint object that is the direct neighbour of this
/// GoPoint object in #GoBoardDirectionNext. Returns nil if this GoPoint object
/// is the last GoPoint of the sequence.
// -----------------------------------------------------------------------------
- (GoPoint*) next
{
  if (! _isNextValid)
  {
    _next = [self.board neighbourOf:self inDirection:GoBoardDirectionNext];
    _isNextValid = true;
  }
  return _next;
}

// -----------------------------------------------------------------------------
/// @brief Returns the GoPoint object that is the direct neighbour of this
/// GoPoint object in #GoBoardDirectionPrevious. Returns nil if this GoPoint object
/// is the first GoPoint of the sequence.
// -----------------------------------------------------------------------------
- (GoPoint*) previous
{
  if (! _isPreviousValid)
  {
    _previous = [self.board neighbourOf:self inDirection:GoBoardDirectionPrevious];
    _isPreviousValid = true;
  }
  return _previous;
}

// -----------------------------------------------------------------------------
/// @brief Returns true if the intersection represented by this GoPoint is
/// occupied by a stone.
// -----------------------------------------------------------------------------
- (bool) hasStone
{
  return (GoColorNone != self.stoneState);
}

// -----------------------------------------------------------------------------
/// @brief Returns true if the intersection represented by this GoPoint is
/// occupied by a black stone. Otherwise returns false (i.e. also returns false
/// if the intersection is not occupied by a stone).
// -----------------------------------------------------------------------------
- (bool) blackStone
{
  return (GoColorBlack == self.stoneState);
}

// -----------------------------------------------------------------------------
/// @brief Returns the number of liberties that the intersection represented by
/// this GoPoint has. The way how liberties are counted depends on whether the
/// intersection is occupied by a stone.
///
/// If the intersection is occupied by a stone, this method returns the number
/// of liberties of the entire stone group. If the intersection is not occupied,
/// this method returns the number of liberties of just that one intersection.
// -----------------------------------------------------------------------------
- (int) liberties
{
  if ([self hasStone])
    return [self.region liberties];
  else
  {
    int liberties = 0;
    for (GoPoint* neighbour in self.neighbours)
    {
      if (! [neighbour hasStone])
        liberties++;
    }
    return liberties;
  }
}

// -----------------------------------------------------------------------------
/// @brief Returns true if @a point refers to the same intersection as this
/// GoPoint object.
// -----------------------------------------------------------------------------
- (bool) isEqualToPoint:(GoPoint*)point
{
  if (! point)
  {
    DDLogWarn(@"%@: GoPoint object is nil for isEqualToPoint", self);
    return false;
  }
  // Don't rely on instance identity, it's better to compare the vertex
  return [self.vertex isEqualToVertex:point.vertex];
}

// -----------------------------------------------------------------------------
/// @brief NSCoding protocol method.
// -----------------------------------------------------------------------------
- (void) encodeWithCoder:(NSCoder*)encoder
{
  [encoder encodeInt:nscodingVersion forKey:nscodingVersionKey];
  [encoder encodeObject:self.vertex forKey:goPointVertexKey];
  [encoder encodeObject:self.board forKey:goPointBoardKey];
  [encoder encodeObject:self.left forKey:goPointLeftKey];
  [encoder encodeObject:self.right forKey:goPointRightKey];
  [encoder encodeObject:self.above forKey:goPointAboveKey];
  [encoder encodeObject:self.below forKey:goPointBelowKey];
  [encoder encodeObject:self.neighbours forKey:goPointNeighboursKey];
  [encoder encodeObject:self.next forKey:goPointNextKey];
  [encoder encodeObject:self.previous forKey:goPointPreviousKey];
  [encoder encodeBool:self.isStarPoint forKey:goPointIsStarPointKey];
  [encoder encodeInt:self.stoneState forKey:goPointStoneStateKey];
  [encoder encodeObject:self.region forKey:goPointRegionKey];
  [encoder encodeBool:self.isLeftValid forKey:goPointIsLeftValidKey];
  [encoder encodeBool:self.isRightValid forKey:goPointIsRightValidKey];
  [encoder encodeBool:self.isAboveValid forKey:goPointIsAboveValidKey];
  [encoder encodeBool:self.isBelowValid forKey:goPointIsBelowValidKey];
  [encoder encodeBool:self.isNextValid forKey:goPointIsNextValidKey];
  [encoder encodeBool:self.isPreviousValid forKey:goPointIsPreviousValidKey];
}

@end
