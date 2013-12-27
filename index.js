// Generated by CoffeeScript 1.6.3
(function() {
  var AmorphousRecipe, CraftingThesaurus, PositionalRecipe, Recipe, RecipeList,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  CraftingThesaurus = (function() {
    CraftingThesaurus.instance = void 0;

    function CraftingThesaurus() {
      this.map = {};
      CraftingThesaurus.instance = this;
    }

    CraftingThesaurus.prototype.registerName = function(lookupName, itemPile) {
      if (this.map[lookupName] == null) {
        this.map[lookupName] = [];
      }
      return this.map[lookupName].push(itemPile.item);
    };

    CraftingThesaurus.prototype.matchesName = function(lookupName, itemPile) {
      var a;
      if (lookupName === void 0 && itemPile === void 0) {
        return true;
      }
      if (itemPile == null) {
        return false;
      }
      if (itemPile.item === lookupName) {
        return true;
      }
      a = this.map[lookupName];
      if (a == null) {
        return false;
      }
      return a.indexOf(itemPile.item) !== -1;
    };

    return CraftingThesaurus;

  })();

  Recipe = (function() {
    function Recipe() {}

    Recipe.prototype.computeOutput = function(inventory) {
      return void 0;
    };

    Recipe.prototype.matches = function(inventory) {
      return this.computeOutput(inventory) !== void 0;
    };

    Recipe.prototype.craft = function(inventory) {
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

    AmorphousRecipe.prototype.removeIngredient = function(itemPile, pendingIngredients) {
      var i, testIngredient, _i, _len;
      for (i = _i = 0, _len = pendingIngredients.length; _i < _len; i = ++_i) {
        testIngredient = pendingIngredients[i];
        if (CraftingThesaurus.instance.matchesName(testIngredient, itemPile)) {
          pendingIngredients.splice(i, 1);
          return true;
        }
      }
      return false;
    };

    AmorphousRecipe.prototype.findMatchingSlots = function(inventory) {
      var foundIndices, i, itemPile, pendingIngredients, _i, _ref;
      pendingIngredients = this.ingredients.slice(0);
      foundIndices = [];
      for (i = _i = 0, _ref = inventory.size(); 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        itemPile = inventory.get(i);
        if (itemPile == null) {
          continue;
        }
        if (!this.removeIngredient(itemPile, pendingIngredients)) {
          return void 0;
        }
        foundIndices.push(i);
      }
      if (pendingIngredients.length !== 0) {
        return void 0;
      }
      return foundIndices;
    };

    AmorphousRecipe.prototype.computeOutput = function(inventory) {
      if (this.findMatchingSlots(inventory) !== void 0) {
        return this.output.clone();
      }
      return void 0;
    };

    AmorphousRecipe.prototype.craft = function(inventory) {
      var slot, slots, _i, _len;
      slots = this.findMatchingSlots(inventory);
      if (!slots) {
        return void 0;
      }
      for (_i = 0, _len = slots.length; _i < _len; _i++) {
        slot = slots[_i];
        inventory.takeAt(slot, 1);
      }
      return this.output.clone();
    };

    return AmorphousRecipe;

  })(Recipe);

  PositionalRecipe = (function(_super) {
    __extends(PositionalRecipe, _super);

    function PositionalRecipe(ingredientMatrix, output) {
      this.ingredientMatrix = ingredientMatrix;
      this.output = output;
    }

    PositionalRecipe.prototype.findMatchingSlots = function(inventory) {
      var actualPile, expectedName, foundIndices, i, index, j, row, _i, _j, _len, _len1, _ref;
      foundIndices = [];
      _ref = this.ingredientMatrix;
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        row = _ref[i];
        for (j = _j = 0, _len1 = row.length; _j < _len1; j = ++_j) {
          expectedName = row[j];
          index = j + i * inventory.width;
          actualPile = inventory.get(index);
          if (!CraftingThesaurus.instance.matchesName(expectedName, actualPile)) {
            console.log('fail match', expectedName, actualPile);
            return void 0;
          }
          foundIndices.push(index);
        }
      }
      console.log('foundIndices=', foundIndices);
      return foundIndices;
    };

    PositionalRecipe.prototype.computeOutput = function(inventory) {
      if (this.findMatchingSlots(inventory) !== void 0) {
        return this.output.clone();
      }
      return void 0;
    };

    PositionalRecipe.prototype.craft = function(inventory) {
      var slot, slots, _i, _len;
      slots = this.findMatchingSlots(inventory);
      if (!slots) {
        return void 0;
      }
      for (_i = 0, _len = slots.length; _i < _len; _i++) {
        slot = slots[_i];
        inventory.takeAt(slot, 1);
      }
      return this.output.clone();
    };

    return PositionalRecipe;

  })(Recipe);

  RecipeList = (function() {
    function RecipeList() {
      this.recipes = [];
      this.thesaurus = new CraftingThesaurus();
    }

    RecipeList.prototype.register = function(recipe) {
      return this.recipes.push(recipe);
    };

    RecipeList.prototype.find = function(inventory) {
      var recipe, _i, _len, _ref;
      _ref = this.recipes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        recipe = _ref[_i];
        if (recipe.computeOutput(inventory) !== void 0) {
          return recipe;
        }
      }
      return void 0;
    };

    RecipeList.prototype.craft = function(inventory) {
      var output, recipe, _i, _len, _ref;
      _ref = this.recipes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        recipe = _ref[_i];
        output = recipe.craft(inventory);
        if (output) {
          return output;
        }
      }
      return void 0;
    };

    return RecipeList;

  })();

  module.exports = function(game, opts) {
    return new RecipeList();
  };

  module.exports.Recipe = Recipe;

  module.exports.AmorphousRecipe = AmorphousRecipe;

  module.exports.PositionalRecipe = PositionalRecipe;

  module.exports.CraftingThesaurus = CraftingThesaurus;

  module.exports.RecipeList = RecipeList;

}).call(this);
