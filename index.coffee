# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

class Recipe
  matches: (inventory) -> false
  craft: (inventory) -> undefined

  findIngredient: (inventory, ingredient, excludedSlots) ->
    for i in [0...inventory.size()]
      continue if excludedSlots.indexOf(i) != -1

      itemPile = inventory.get(i)
      continue if not itemPile?

      console.log 'testing itemPile',itemPile,i,' against ',ingredient
      if itemPile?.item == ingredient  # TODO: thesaurus
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

class PositionalRecipe extends Recipe


module.exports = {Recipe, AmorphousRecipe, PositionalRecipe}
