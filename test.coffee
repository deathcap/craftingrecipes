# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

test = require 'tape'
{Recipe, AmorphousRecipe, PositionalRecipe, CraftingThesaurus} = require './'
Inventory = require 'inventory'
ItemPile = require 'itempile'

test 'thesaurus register', (t) ->
  thesaurus = new CraftingThesaurus()

  t.equals(thesaurus.matchesName('logOak', new ItemPile('plankOak')), false)

  thesaurus.registerName 'blackDye', new ItemPile('squidInk')
  thesaurus.registerName 'blackDye', new ItemPile('syntheticBlackInk')
  thesaurus.registerName 'whiteDye', new ItemPile('bonemeal')
  thesaurus.registerName 'whiteDye', new ItemPile('bleach')

  t.equals(thesaurus.matchesName('blackDye', new ItemPile('squidInk')), true)
  t.equals(thesaurus.matchesName('blackDye', new ItemPile('syntheticBlackInk')), true)
  t.equals(thesaurus.matchesName('blackDye', new ItemPile('something')), false)
  t.equals(thesaurus.matchesName('whiteDye', new ItemPile('bonemeal')), true)
  t.equals(thesaurus.matchesName('whiteDye', new ItemPile('bleach')), true)
  t.equals(thesaurus.matchesName('whiteDye', new ItemPile('dirt')), false)

  t.end()

# convenience functions to create inventory with items of given names, one each
fillGrid = (input, names) ->
  for name, i in names
    input.set i, new ItemPile(name, 1) if name?
  return input

craftingGrid2 = (names) ->
  input = new Inventory(2, 2)
  fillGrid input, names
  return input

craftingGrid3 = (names) ->
  input = new Inventory(3, 3)
  fillGrid input, names
  return input

test 'amorphous simple recipe match', (t) ->
  r = new AmorphousRecipe ['log'], new ItemPile('plank')

  t.equals(r.matches(craftingGrid2 ['log']), true)
  t.equals(r.matches(craftingGrid2 [undefined, 'log']), true)
  t.equals(r.matches(craftingGrid2 [undefined, undefined, 'log']), true)
  t.equals(r.matches(craftingGrid2 [undefined, undefined, undefined, 'log']), true)
  t.end()

test 'amorphous double ingredients', (t) ->
  r = new AmorphousRecipe ['plank', 'plank'], new ItemPile('stick')

  t.equals(r.matches(craftingGrid2 ['plank']), false)
  t.equals(r.matches(craftingGrid2 ['plank', 'plank']), true)
  t.equals(r.matches(craftingGrid2 [undefined,'plank', 'plank']), true)
  t.equals(r.matches(craftingGrid2 [undefined, undefined,'plank', 'plank']), true)
  t.end()

test 'amorphous extraneous inputs', (t) ->
  r = new AmorphousRecipe ['plank', 'plank'], new ItemPile('stick')

  t.equals(r.matches(craftingGrid2 ['plank', 'plank', 'plank']), false)
  t.equals(r.matches(craftingGrid2 ['plank', 'plank', 'plank', 'plank']), false)
  t.end()

test 'craft thesaurus', (t) ->
  r = new AmorphousRecipe ['log'], new ItemPile('plank')

  # overwrites singleton instance (sorry); recipes below will use it
  thesaurus = new CraftingThesaurus()
  thesaurus.registerName 'log', new ItemPile('logOak')
  thesaurus.registerName 'log', new ItemPile('logBirch')

  t.equals(r.matches(craftingGrid2 ['log']), true)
  t.equals(r.matches(craftingGrid2 ['logOak']), true)
  t.equals(r.matches(craftingGrid2 ['logBirch']), true)
  t.equals(r.matches(craftingGrid2 ['logWhatever']), false)

  t.end()

test 'take craft empty', (t) ->
  r = new AmorphousRecipe ['log'], new ItemPile('plank')
 
  grid = craftingGrid2 ['log']
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

  t.equal(r.matches(craftingGrid2 ['first', 'second']), true)
  t.equal(r.matches(craftingGrid2 ['first']), false)
  t.equal(r.matches(craftingGrid2 ['second']), false)
  t.equal(r.matches(craftingGrid2 ['second', 'first']), false)
  t.equal(r.matches(craftingGrid2 [undefined, 'first']), false)
  t.equal(r.matches(craftingGrid2 [undefined, 'first', 'second']), false)

  t.end()

test 'positional recipe match two rows', (t) ->
  r = new PositionalRecipe [
      ['ingot', undefined, 'ingot'],
      [undefined, 'ingot', undefined]
    ], new ItemPile('bucket')

  t.equal(r.matches(craftingGrid3 ['ingot', undefined, 'ingot',   undefined, 'ingot']), true)
  t.equal(r.matches(craftingGrid3 ['ingot', undefined, 'ingot']), false)
  t.equal(r.matches(craftingGrid3 ['ingot']), false)

  t.end()

test 'positional recipe craft', (t) ->
  r = new PositionalRecipe [
      ['ingot', undefined, 'ingot'],
      [undefined, 'ingot', undefined]
    ], new ItemPile('bucket')

  grid = craftingGrid3 ['ingot', undefined, 'ingot',   undefined, 'ingot']
  output = r.craft(grid)
  t.equals(!!output, true)
  t.equals(output.item, 'bucket')
  console.log 'new grid',grid
  for i in [0...grid.size()]
    t.equals(grid.get(i), undefined)

  t.end()

test 'positional recipe craft leftover', (t) ->
  r = new PositionalRecipe [
      ['ingot', undefined, 'ingot'],
      [undefined, 'ingot', undefined]
    ], new ItemPile('bucket')

  grid = new Inventory(3, 3)

  grid.set 0, new ItemPile('ingot', 10)
  grid.set 2, new ItemPile('ingot', 5)
  grid.set 4, new ItemPile('ingot', 3)
 
  output = r.craft(grid)
  t.equals(!!output, true)
  t.equals(output.item, 'bucket')
  console.log 'new grid',grid

  t.equal(grid.get(0) != undefined, true)
  t.equal(grid.get(0).item, 'ingot')
  t.equal(grid.get(0).count, 10 - 1)

  t.equal(grid.get(2) != undefined, true)
  t.equal(grid.get(2).item, 'ingot')
  t.equal(grid.get(2).count, 5 - 1)

  t.equal(grid.get(4) != undefined, true)
  t.equal(grid.get(4).item, 'ingot')
  t.equal(grid.get(4).count, 3 - 1)

  for i in [0...grid.size()]
    continue if i in [0, 2, 4]
    t.equals(grid.get(i), undefined)

  t.end()

test 'positional recipe three rows', (t) ->
  r = new PositionalRecipe [
    ['wood.plank', 'wood.plank', 'wood.plank'],
    [undefined, 'stick', undefined],
    [undefined, 'stick', undefined]], new ItemPile('pickaxeWood', 1)

  grid = craftingGrid3 [
    'wood.plank', 'wood.plank', 'wood.plank',
    undefined, 'stick', undefined,
    undefined, 'stick', undefined]
  output = r.craft(grid)
  t.equals(!!output, true)
  t.equals(output.item, 'pickaxeWood')

  for i in [0...grid.size()]
    t.equals(grid.get(i), undefined)


  t.end()

