# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

test = require 'tape'
{Recipe, AmorphousRecipe, PositionalRecipe, CraftingThesaurus} = require './'
Inventory = require 'inventory'
ItemPile = require 'itempile'

test 'thesaurus register', (t) ->
  t.equals(CraftingThesaurus.matchesName('logOak', new ItemPile('plankOak')), false)

  CraftingThesaurus.registerName 'blackDye', new ItemPile('squidInk')
  CraftingThesaurus.registerName 'blackDye', new ItemPile('syntheticBlackInk')
  CraftingThesaurus.registerName 'whiteDye', new ItemPile('bonemeal')
  CraftingThesaurus.registerName 'whiteDye', new ItemPile('bleach')

  t.equals(CraftingThesaurus.matchesName('blackDye', new ItemPile('squidInk')), true)
  t.equals(CraftingThesaurus.matchesName('blackDye', new ItemPile('syntheticBlackInk')), true)
  t.equals(CraftingThesaurus.matchesName('blackDye', new ItemPile('something')), false)
  t.equals(CraftingThesaurus.matchesName('whiteDye', new ItemPile('bonemeal')), true)
  t.equals(CraftingThesaurus.matchesName('whiteDye', new ItemPile('bleach')), true)
  t.equals(CraftingThesaurus.matchesName('whiteDye', new ItemPile('dirt')), false)

  t.end()

# convenience function to create inventory with items of given names, one each
craftingGrid = (names) ->
  input = new Inventory(2, 2)
  for i in [0...names.length]
    input.set i, new ItemPile(names[i], 1) if names[i]?
  return input

test 'amorphous simple recipe match', (t) ->
  r = new AmorphousRecipe ['log'], new ItemPile('plank')

  t.equals(r.matches(craftingGrid ['log']), true)
  t.equals(r.matches(craftingGrid [undefined, 'log']), true)
  t.equals(r.matches(craftingGrid [undefined, undefined, 'log']), true)
  t.equals(r.matches(craftingGrid [undefined, undefined, undefined, 'log']), true)
  t.end()

test 'amorphous double ingredients', (t) ->
  r = new AmorphousRecipe ['plank', 'plank'], new ItemPile('stick')

  t.equals(r.matches(craftingGrid ['plank']), false)
  t.equals(r.matches(craftingGrid ['plank', 'plank']), true)
  t.equals(r.matches(craftingGrid [undefined,'plank', 'plank']), true)
  t.equals(r.matches(craftingGrid [undefined, undefined,'plank', 'plank']), true)
  t.end()

test 'amorphous extraneous inputs', (t) ->
  r = new AmorphousRecipe ['plank', 'plank'], new ItemPile('stick')

  t.equals(r.matches(craftingGrid ['plank', 'plank', 'plank']), false)
  t.equals(r.matches(craftingGrid ['plank', 'plank', 'plank', 'plank']), false)
  t.end()

test 'craft thesaurus', (t) ->
  r = new AmorphousRecipe ['log'], new ItemPile('plank')

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

test 'positional recipe match one row', (t) ->

  r = new PositionalRecipe [['first', 'second']], new ItemPile('output', 2)

  t.equal(r.matches(craftingGrid ['first', 'second']), true)
  t.equal(r.matches(craftingGrid ['first']), false)
  t.equal(r.matches(craftingGrid ['second']), false)
  t.equal(r.matches(craftingGrid ['second', 'first']), false)
  t.equal(r.matches(craftingGrid [undefined, 'first']), false)
  t.equal(r.matches(craftingGrid [undefined, 'first', 'second']), false)

  t.end()

test 'positional recipe match two rows', (t) ->
  r = new PositionalRecipe [
      ['ingot', undefined, 'ingot'],
      [undefined, 'ingot', undefined]
    ], new ItemPile('bucket')

  t.end()
