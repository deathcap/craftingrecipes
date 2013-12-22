# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

test = require 'tape'
{Recipe, AmorphousRecipe, PositionalRecipe} = require './'
Inventory = require 'inventory'
ItemPile = require 'itempile'

# convenience function to create inventory with items of given names, one each
craftingGrid = (names) ->
  input = new Inventory(4)
  for i in [0...names.length]
    input.set i, new ItemPile(names[i], 1)
  return input

test 'simple recipe match', (t) ->
  r = new AmorphousRecipe ['log'], 'plank'

  t.equals(r.matches(craftingGrid ['log']), true)
  t.equals(r.matches(craftingGrid [undefined, 'log']), true)
  t.equals(r.matches(craftingGrid [undefined, undefined, 'log']), true)
  t.equals(r.matches(craftingGrid [undefined, undefined, undefined, 'log']), true)
  t.end()

test 'double ingredients', (t) ->
  r = new AmorphousRecipe ['plank', 'plank'], 'stick'

  t.equals(r.matches(craftingGrid ['plank']), false)
  t.equals(r.matches(craftingGrid ['plank', 'plank']), true)
  t.equals(r.matches(craftingGrid ['plank', 'plank', 'plank']), true)
  t.equals(r.matches(craftingGrid [undefined,'plank', 'plank']), true)
  t.equals(r.matches(craftingGrid [undefined, undefined,'plank', 'plank']), true)
  t.end()

