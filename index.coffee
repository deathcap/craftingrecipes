# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

class CraftingThesaurus 
  @instance = undefined

  constructor: () ->
    @map = {}
    CraftingThesaurus.instance = this # TODO: desingletonify?

  registerName: (lookupName, item) ->
    throw "craftingrecipes registerName(#{lookupName}): name is in invalid format, should be 'shape.material'" if lookupName.indexOf('.') == -1

    @map[lookupName] = [] if not @map[lookupName]?
    @map[lookupName].push(item)

  matchesName: (lookupName, itemPile) ->
    return true if lookupName == undefined && itemPile == undefined # nothing matches nothing
    return false if not itemPile?
    return true if itemPile.item == lookupName  # direct name match
   
    # known alias?
    a = @map[lookupName]
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
      if CraftingThesaurus.instance.matchesName(testIngredient, itemPile)
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

        if not CraftingThesaurus.instance.matchesName(expectedName, actualPile)
          console.log 'fail match',expectedName,actualPile
          return undefined

        foundIndices.push(index)

    console.log 'foundIndices=',foundIndices
    return foundIndices

  computeOutput: (inventory) ->
    return @output.clone() if @findMatchingSlots(inventory) != undefined
    undefined

  # TODO: refactor with AmorphousRecipe
  craft: (inventory) ->
    slots = @findMatchingSlots(inventory)
    return undefined if !slots

    for slot in slots
      inventory.takeAt slot, 1 # TODO: check return

    return @output.clone()


class RecipeList
  constructor: () ->
    @recipes = []
    @thesaurus = new CraftingThesaurus()

  register: (recipe) ->
    @recipes.push(recipe)

  find: (inventory) ->
    for recipe in @recipes
      return recipe if recipe.computeOutput(inventory) != undefined
    return undefined

  craft: (inventory) ->
    for recipe in @recipes
      output = recipe.craft(inventory)
      return output if output
    return undefined

module.exports = (game, opts) ->
  return new RecipeList()

module.exports.Recipe = Recipe
module.exports.AmorphousRecipe = AmorphousRecipe
module.exports.PositionalRecipe = PositionalRecipe
module.exports.CraftingThesaurus = CraftingThesaurus
module.exports.RecipeList = RecipeList

