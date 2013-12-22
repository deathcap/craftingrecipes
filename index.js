// Generated by CoffeeScript 1.6.3
(function() {
  var AmorphousRecipe, PositionalRecipe, Recipe, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Recipe = (function() {
    function Recipe() {}

    Recipe.prototype.matches = function(inventory) {
      return false;
    };

    Recipe.prototype.craft = function(inventory) {
      return void 0;
    };

    Recipe.prototype.findIngredient = function(inventory, ingredient, excludedSlots) {
      var i, itemPile, _i, _ref;
      for (i = _i = 0, _ref = inventory.size(); 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        if (excludedSlots.indexOf(i) !== -1) {
          continue;
        }
        itemPile = inventory.get(i);
        if (itemPile == null) {
          continue;
        }
        console.log('testing itemPile', itemPile, i, ' against ', ingredient);
        if ((itemPile != null ? itemPile.item : void 0) === ingredient) {
          console.log('  found ', itemPile, i);
          return i;
        }
      }
      return void 0;
    };

    return Recipe;

  })();

  AmorphousRecipe = (function(_super) {
    __extends(AmorphousRecipe, _super);

    function AmorphousRecipe(ingredients, output) {
      this.ingredients = ingredients;
      this.output = output;
    }

    AmorphousRecipe.prototype.findMatchingSlots = function(inventory) {
      var foundIndex, foundIndices, ingredient, _i, _len, _ref;
      foundIndices = [];
      _ref = this.ingredients;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        ingredient = _ref[_i];
        console.log('check ingredient', ingredient);
        foundIndex = this.findIngredient(inventory, ingredient, foundIndices);
        console.log('found=', foundIndex);
        if (foundIndex == null) {
          return false;
        }
        foundIndices.push(foundIndex);
      }
      console.log('foundIndices', foundIndices);
      return foundIndices;
    };

    AmorphousRecipe.prototype.matches = function(inventory) {
      return this.findMatchingSlots(inventory) !== false;
    };

    return AmorphousRecipe;

  })(Recipe);

  PositionalRecipe = (function(_super) {
    __extends(PositionalRecipe, _super);

    function PositionalRecipe() {
      _ref = PositionalRecipe.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    return PositionalRecipe;

  })(Recipe);

  module.exports = {
    Recipe: Recipe,
    AmorphousRecipe: AmorphousRecipe,
    PositionalRecipe: PositionalRecipe
  };

}).call(this);
