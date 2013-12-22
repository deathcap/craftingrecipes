# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

test = require 'tape'
{Recipe, AmorphousRecipe, PositionalRecipe, CraftingThesaurus} = require './'
Inventory = require 'inventory'
ItemPile = require 'itempile'

# convenience function to create inventory with items of given names, one each
craftingGrid = (names) ->
  input = new Inventory(4)
  for i in [0...names.length]
    input.set i, new ItemPile(names[i], 1)
  return input

test 'simple recipe match', (t) ->
  r = new AmorphousRecipe ['log'], new ItemPile('plank')

  t.equals(r.matches(craftingGrid ['log']), true)
  t.equals(r.matches(craftingGrid [undefined, 'log']), true)
  t.equals(r.matches(craftingGrid [undefined, undefined, 'log']), true)
  t.equals(r.matches(craftingGrid [undefined, undefined, undefined, 'log']), true)
  t.end()

test 'double ingredients', (t) ->
  r = new AmorphousRecipe ['plank', 'plank'], new ItemPile('stick')

  t.equals(r.matches(craftingGrid ['plank']), false)
  t.equals(r.matches(craftingGrid ['plank', 'plank']), true)
  t.equals(r.matches(craftingGrid ['plank', 'plank', 'plank']), true)
  t.equals(r.matches(craftingGrid [undefined,'plank', 'plank']), true)
  t.equals(r.matches(craftingGrid [undefined, undefined,'plank', 'plank']), true)
  t.end()

test 'thesaurus', (t) ->
  r = new AmorphousRecipe ['log'], 'plank'

  CraftingThesaurus.registerName 'log', new ItemPile('logOak')
  CraftingThesaurus.registerName 'log', new ItemPile('logBirch')

  t.equals(r.matches(craftingGrid ['log']), true)
  t.equals(r.matches(craftingGrid ['logOak']), true)
  t.equals(r.matches(craftingGrid ['logBirch']), true)
  t.equals(r.matches(craftingGrid ['logWhatever']), false)

  t.end()

test 'take craft empty', (t) ->
  r = new AmorphousRecipe ['log'], new ItemPile('plank')
 
  grid = craftingGrid ['log']
  output = r.craft(grid)
  t.equals(!!output, true)
  console.log 'output',output
  t.equals(output.item, 'plank')
  t.equals(grid.get(0), undefined)
  t.equals(grid.get(1), undefined)
  t.equals(grid.get(2), undefined)
  t.equals(grid.get(3), undefined)

  t.end()

test 'take craft leftover', (t) ->
  r = new AmorphousRecipe ['log'], new ItemPile('plank')

  grid = new Inventory(4)
  grid.set 0, new ItemPile('log', 10)

  output = r.craft(grid)
  t.equals(!!output, true)
  console.log 'output',output
  t.equals(output.item, 'plank')
  console.log 'new grid',grid
  t.equals(grid.get(0) != undefined, true)
  t.equals(grid.get(0).count, 9)
  t.equals(grid.get(0).item, 'log')
  t.equals(grid.get(1), undefined)
  t.equals(grid.get(2), undefined)
  t.equals(grid.get(3), undefined)

  t.end()
