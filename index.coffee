# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

class CraftingThesaurus 
  @map = {}

  @registerName: (lookupName, itemPile) ->
    CraftingThesaurus.map[lookupName] = [] if not CraftingThesaurus.map[lookupName]?
    CraftingThesaurus.map[lookupName].push(itemPile.item)

  @matchesName: (lookupName, itemPile) ->
    return false if not itemPile?
    return true if itemPile.item == lookupName
    return CraftingThesaurus.map[lookupName]?.indexOf(itemPile.item) != -1

class Recipe
  matches: (inventory) -> false
  craft: (inventory) -> undefined

  findIngredient: (inventory, ingredient, excludedSlots) ->
    for i in [0...inventory.size()]
      continue if excludedSlots.indexOf(i) != -1

      itemPile = inventory.get(i)
      continue if not itemPile?

      console.log 'testing itemPile',itemPile,i,' against ',ingredient
      if CraftingThesaurus.matchesName(ingredient, itemPile)
        console.log '  found ',itemPile,i
        return i

    return undefined

class AmorphousRecipe extends Recipe
  constructor: (@ingredients, @output) ->

  findMatchingSlots: (inventory) ->
    foundIndices = []
    for ingredient in @ingredients
      console.log 'check ingredient',ingredient

      # search in inventory
      # cannot reuse found item slots for multiple ingredients
      foundIndex = @findIngredient(inventory, ingredient, foundIndices)
      console.log 'found=',foundIndex
      return false if not foundIndex?
      foundIndices.push(foundIndex)

    console.log 'foundIndices',foundIndices
    return foundIndices
   
  matches: (inventory) ->
    return @findMatchingSlots(inventory) != false

  craft: (inventory) ->
    slots = @findMatchingSlots(inventory)
    return undefined if !slots

    for slot in slots
      inventory.takeAt slot, 1 # TODO: check return

    return @output.clone()

class PositionalRecipe extends Recipe


module.exports = {Recipe, AmorphousRecipe, PositionalRecipe, CraftingThesaurus}
