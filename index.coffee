# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

class Recipe
  matches: (inventory) -> false
  craft: (inventory) -> undefined

class AmorphousRecipe extends Recipe
  constructor: (@ingredients, @output) ->

  findMatchingSlots: (inventory) ->
    foundIndices = []
    for ingredient in @ingredients
      console.log 'check ingredient',ingredient

      # search in inventory
      foundIndex = undefined
      for i in [0...inventory.size()]
        itemPile = inventory.get(i)
        continue if not itemPile?
        console.log 'testing itemPile',itemPile
        # TODO: don't reuse found slots
        if itemPile?.item == ingredient  # TODO: thesaurus
          console.log '  found ',itemPile,i
          foundIndex = i
          break
      console.log 'found=',foundIndex
      return false if not foundIndex?
      foundIndices.push(foundIndex)

    console.log 'foundIndices',foundIndices
    return foundIndices
   

  matches: (inventory) ->
    return !! @findMatchingSlots(inventory)

class PositionalRecipe extends Recipe


module.exports = {Recipe, AmorphousRecipe, PositionalRecipe}
