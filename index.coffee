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

class AmorphousRecipe extends Recipe
  constructor: (@ingredients, @output) ->

  # if itemPile is in pendingIngredients, remove it
  removeIngredient: (itemPile, pendingIngredients) ->
    for testIngredient, i in pendingIngredients
      if CraftingThesaurus.matchesName(testIngredient, itemPile)
        pendingIngredients.splice(i, 1)
        return true
    return false


  findMatchingSlots: (inventory) ->
    pendingIngredients = @ingredients[..]
    foundIndices = []

    for i in [0...inventory.size()]
      itemPile = inventory.get(i)
      continue if not itemPile?

      if not @removeIngredient(itemPile, pendingIngredients)
        # found something we didn't want
        return undefined

      foundIndices.push(i)

    if pendingIngredients.length != 0
      # didn't find everything
      return undefined

    return foundIndices
   
  computeOutput: (inventory) ->
    return @output.clone() if @findMatchingSlots(inventory) != undefined
    undefined

  craft: (inventory) ->
    slots = @findMatchingSlots(inventory)
    return undefined if !slots

    for slot in slots
      inventory.takeAt slot, 1 # TODO: check return

    return @output.clone()


class PositionalRecipe extends Recipe
  # TODO: accept patternStrArray, ingredientMap (['AB''], {A:.., B:..})
  constructor: (@ingredientMatrix, @output) ->

  findMatchingSlots: (inventory) ->
    # inventory input ingredients must match @ingredientMatrix at same positions
    foundIndices = []
    for row, i in @ingredientMatrix
      for expectedName, j in row
        index = j + i * inventory.width
        actualPile = inventory.get(index)

        if not CraftingThesaurus.matchesName(expectedName, actualPile)
          return undefined

        foundIndices.push(index)

    return foundIndices

  computeOutput: (inventory) ->
    return @output.clone() if @findMatchingSlots(inventory) != undefined
    undefined




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
