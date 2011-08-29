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


// Forward declarations
@class UITableViewCell;
@class UITableView;


// -----------------------------------------------------------------------------
/// @brief Enumerates types of table view cells that can be created by
/// TableViewCellFactory.
// -----------------------------------------------------------------------------
enum TableViewCellType
{
  DefaultCellType,    ///< @brief Cell with style @e UITableViewCellStyleDefault
  Value1CellType,     ///< @brief Cell with style @e UITableViewCellStyleValue1
  SwitchCellType,     ///< @brief with a UISwitch in the accessory view
  TextFieldCellType,  ///< @brief The cell's entire content view is a UITextField
  SliderCellType      ///< @brief Similar to Value1CellType, but with a slider that allows to adjust the value
};

// -----------------------------------------------------------------------------
/// @brief Enumerates all possible tags for subviews in custom table view cells
/// created by TableViewCellFactory.
// -----------------------------------------------------------------------------
enum TableViewCellSubViewTag
{
  UnusedSubviewTag = 0,  ///< @brief Tag 0 must not be used, it is the default tag used for all framework-created views (e.g. the cell's content view)
  TextFieldCellTextFieldTag,
};

// -----------------------------------------------------------------------------
/// @brief The TableViewCellFactory class is a container for factory functions
/// that create table view cell objects that fit into a table view of grouped
/// style.
///
/// The section "UI elements design notes" in README.developer has notes about
/// the layout of some cell types.
// -----------------------------------------------------------------------------
@interface TableViewCellFactory : NSObject
{
}

+ (UITableViewCell*) cellWithType:(enum TableViewCellType)type tableView:(UITableView*)tableView;

@end
