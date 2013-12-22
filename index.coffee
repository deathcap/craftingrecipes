# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

class Recipe
  matches: (inventory) -> false
  craft: (inventory) -> undefined

class AmorphousRecipe extends Recipe
  constructor: (@ingredients, @output) ->

  matches: (inventory) ->
    for ingredient in @ingredients
      console.log 'check ingredient',ingredient

      # search in inventory
      found = false
      for itemPile in inventory.array
        console.log 'testing itemPile',itemPile
        if itemPile?.item == ingredient  # TODO: thesaurus
          console.log '  found ',itemPile
          found = true
          break
      console.log 'found=',found
      return false if not found

    return true

class PositionalRecipe extends Recipe


module.exports = {Recipe, AmorphousRecipe, PositionalRecipe}
