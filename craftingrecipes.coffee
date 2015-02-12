
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

  findMatchingSlots: (inputInventory) ->
    # inventory input ingredients must match @ingredientMatrix at same (relative) positions
    foundIndices = []

    [inventory, shiftRow, shiftColumn] = PositionalRecipe.tighten inputInventory
    if inventory.height != @ingredientMatrix.length or inventory.width != @ingredientMatrix[0].length
      return undefined

    for row, i in @ingredientMatrix
      for expectedName, j in row
        index = j + i * inventory.width
        actualPile = inventory.get(index)

        if not CraftingThesaurus.instance.matchesName(expectedName, actualPile)
          return undefined

        # add original index from inputInventory for removing ingredients
        unshiftedIndex = (j + shiftColumn) + (i + shiftRow) * inputInventory.width
        foundIndices.push(unshiftedIndex)

    return foundIndices

  # tighten the bounds around an inventory, shrinking it from the edges if possible
  @tighten = (inventory) ->
    # iterate from each side, computing occupied bounds
    for x in [0...inventory.width]
      isOccupied = false
      for y in [0...inventory.height]
        isOccupied = true if inventory.get(y + x * inventory.width)?
      break if isOccupied
    firstRow = x

    for x in [inventory.width - 1..0]
      isOccupied = false
      for y in [0...inventory.height]
        isOccupied = true if inventory.get(y + x * inventory.width)?
      break if isOccupied
    lastRow = x


    for y in [0...inventory.height]
      isOccupied = false
      for x in [0...inventory.width]
        isOccupied = true if inventory.get(y + x * inventory.width)?
      break if isOccupied
    firstColumn = y

    for y in [inventory.height - 1..0]
      isOccupied = false
      for x in [0...inventory.width]
        isOccupied = true if inventory.get(y + x * inventory.width)?
      break if isOccupied
    lastColumn = y

    #console.log 'firstRow',firstRow,'lastRow',lastRow
    #console.log 'firstColumn',firstColumn,'lastColumn',lastColumn

    # copy to new smaller-or-equal inventory
    newWidth = lastColumn - firstColumn + 1
    newHeight = lastRow - firstRow + 1

    if newWidth < 0 or newHeight < 0
      # completely empty inventory - but cannot shrink to 0x0 (dimensions must be
      # positive in inventory >=0.1.2), so go with the next best thing (1x1)
      newWidth = newHeight = 1

    #console.log 'new ',newWidth,newHeight
    newInventory = new inventory.constructor(newWidth, newHeight)
    for oldX in [firstRow..lastRow]
      for oldY in [firstColumn..lastColumn]
        pile = inventory.get(oldY + oldX * inventory.width)
        newX = oldX - firstRow
        newY = oldY - firstColumn
        newInventory.set newY + newX * newInventory.width, pile

    return [newInventory, firstRow, firstColumn]

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
  throw new Error 'craftingrecipes plugin (plugin only) replaced by voxel-recipes'

module.exports.Recipe = Recipe
module.exports.AmorphousRecipe = AmorphousRecipe
module.exports.PositionalRecipe = PositionalRecipe
module.exports.CraftingThesaurus = CraftingThesaurus
module.exports.RecipeList = RecipeList

