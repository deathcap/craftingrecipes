# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

test = require 'tape'
{Recipe, AmorphousRecipe, PositionalRecipe} = require './'
Inventory = require 'inventory'
ItemPile = require 'itempile'

test 'recipe', (t) ->
  r = new AmorphousRecipe ['log'], 'plank'
  console.log(r)

  input = new Inventory(4)
  input.set 1, new ItemPile('log')
  console.log 'input='+input

  console.log r.matches(input)

  t.end()

