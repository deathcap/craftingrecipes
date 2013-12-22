# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

class CraftingThesaurus 
  @map = {}

  @registerName: (lookupName, itemPile) ->
    CraftingThesaurus.map[lookupName] = [] if not CraftingThesaurus.map[lookupName]?
    CraftingThesaurus.map[lookupName].push(itemPile.item)

  @matchesName: (lookupName, itemPile) ->
    return false if not itemPile?
    return true if itemPile.item == lookupName
    
    a = CraftingThesaurus.map[lookupName]
    return false if not a?
    return a.indexOf(itemPile.item) != -1

class Recipe
  computeOutput: (inventory) -> undefined
  matches: (inventory) -> @computeOutput(inventory) != undefined
  craft: (inventory) -> undefined

  findIngredient: (inventory, ingredient, excludedSlots) ->
    for i in [0...inventory.size()]
      continue if excludedSlots.indexOf(i) != -1

      itemPile = inventory.get(i)
      continue if not itemPile?

      if CraftingThesaurus.matchesName(ingredient, itemPile)
        console.log 'findIngredient match:',ingredient,itemPile+''
        return i

    return undefined

class AmorphousRecipe extends Recipe
  constructor: (@ingredients, @output) ->

  findMatchingSlots: (inventory) ->
    foundIndices = []
    for ingredient in @ingredients

      # search in inventory
      # cannot reuse found item slots for multiple ingredients
      foundIndex = @findIngredient(inventory, ingredient, foundIndices)
      console.log 'check ingredient=',ingredient,'foundIndex=',foundIndex
      return false if not foundIndex?
      foundIndices.push(foundIndex)

    console.log 'foundIndices',foundIndices
    return foundIndices
   
  computeOutput: (inventory) ->
    return @output.clone() if @findMatchingSlots(inventory) != false
    undefined

  craft: (inventory) ->
    slots = @findMatchingSlots(inventory)
    return undefined if !slots

    for slot in slots
      inventory.takeAt slot, 1 # TODO: check return

    return @output.clone()


class PositionalRecipe extends Recipe
  constructor: (@pattern, @ingredients, @output) ->
    @recipeWidth = @computeWidth()

  computeWidth: () ->
    maxWidth = 0
    for line in @pattern
      maxWidth = Math.max(maxWidth, line.length)
    return maxWidth

  findMatchingSlots: (inventory, inventoryWidth) ->
    # TODO

class RecipeLocator
  @recipes = []

  @register: (recipe) ->
    RecipeLocator.recipes.push(recipe)

  @find: (inventory) ->
    for recipe in RecipeLocator.recipes
      return recipe if recipe.computeOutput(inventory) != undefined
    return undefined

  @craft: (inventory) ->
    for recipe in RecipeLocator.recipes
      output = recipe.craft(inventory)
      return output if output
    return undefined

module.exports = {Recipe, AmorphousRecipe, PositionalRecipe, CraftingThesaurus, RecipeLocator}
