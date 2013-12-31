# craftingrecipes

Recipes for crafting items with [inventory](https://github.com/deathcap/inventory) and [itempile](https://github.com/deathcap/itempile).

[![Build Status](https://travis-ci.org/deathcap/craftingrecipes.png)](https://travis-ci.org/deathcap/craftingrecipes)

Used by:

* [voxel-workbench](https://github.com/deathcap/voxel-workbench) 
* [voxel-inventory-dialog](https://github.com/deathcap/voxel-inventory-dialog)
* [voxel-pickaxe](https://github.com/deathcap/voxel-pickaxe)

## Recipe Classes

All recipe classes implement:

* `computeOutput(inventory)`: returns an ItemPile for the crafting result of the given inventory input ingredients, or undefined
* `matches(inventory)`: returns true if this recipe matches the given ingredients
* `craft(inventory)`: consumes input ingredients from inventory and returns ItemPile result, or undefined if doesn't match

The following recipe classes are implemented in this module:

* `AmorphousRecipe`: ingredients are accepted in any order
* `PositionalRecipe`: ingredients must match at certain positions

You can define your own recipe classes as long as they extend `Recipe` (see 
[voxel-pickaxe](https://github.com/deathcap/voxel-pickaxe)'s repair recipe for an example).

## Recipe Lists

`RecipeList` manages a list of recipes and can search an inventory against each of them.
This is the ordinary use case of this module. Register your recipes in `RecipeList` then
`result = craft(inventory)` to search and craft.

craftingrecipes can be loaded through [voxel-plugins](https://github.com/deathcap/voxel-plugins)
for a centralized recipe list shared amongst multiple plugins.

## Crafting Thesaurus

`CraftingThesaurus` provides a mapping from a convenient general name to a specific
item name of that category. This is used to allow different items, all of the same
general "type", to be used as crafting inputs. Amorphous and positional recipes automatically
support the thesaurus.

The thesaurus is useful when you have interchangeable items, for example, different species
of wood, all usable in the same recipes (or different kinds of dyes, also intended to be
interchangeable, etc.). The general name "wood.log" can be registered for "logOak",
"logBirch", and future potential items, then wood.log can be specified in a recipe definition
as ingredients, and when matching the recipe against this ingredient, any of the listed items can be used. 

For known registered names used by other plugins, see [the wiki](https://github.com/deathcap/craftingrecipes/wiki).

## Examples

See unit tests


## License

MIT

