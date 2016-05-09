'use strict';

class CraftingThesaurus {
  constructor() {
    this.map = {};
    global.CraftingThesaurus_instance = this; // TODO: desingletonify?
  }

  registerName(lookupName, item) {
    if (lookupName.indexOf('.') === -1) {
      throw new Error(`craftingrecipes registerName(${lookupName}): name is in invalid format, should be 'shape.material'`);
    }

    if (this.map[lookupName] === undefined) {
      this.map[lookupName] = [];
    }

    this.map[lookupName].push(item);
  }

  matchesName(lookupName, itemPile) {
    if (lookupName === undefined && itemPile === undefined) return true; // nothing matches nothing
    if (itemPile === undefined) return false;
    if (itemPile.item === lookupName) return true; // direct name match
   
    // known alias?
    const a = this.map[lookupName];
    if (a === undefined) return false;
    return a.indexOf(itemPile.item) != -1;
  }
}

class Recipe {
  computeOutput(inventory) {
    return undefined;
  }

  matches(inventory) {
    console.log('matches?',inventory);
    return this.computeOutput(inventory) !== undefined;
  }

  craft(inventory) {
    return undefined;
  }
}

class AmorphousRecipe extends Recipe {
  constructor(ingredients, output) {
    super();
    this.ingredients = ingredients;
    this.output = output;
  }

  // if itemPile is in pendingIngredients, remove it
  removeIngredient(itemPile, pendingIngredients) {
    for (let i = 0; i < pendingIngredients.length; ++i) {
      const testIngredient = pendingIngredients[i];

      if (global.CraftingThesaurus_instance.matchesName(testIngredient, itemPile)) {
        pendingIngredients.splice(i, 1);
        console.log('matchesName',testIngredient,itemPile);
        return true;
      }
    }

    return false;
  }

  findMatchingSlots(inventory) {
    const pendingIngredients = this.ingredients.slice();
    const foundIndices = [];

    for (let i = 0; i < inventory.size(); ++i)  {
      const itemPile = inventory.get(i)
      if (itemPile === undefined) continue;

      console.log('findMatchingSlots',itemPile,pendingIngredients);
      if (!this.removeIngredient(itemPile, pendingIngredients)) {
        console.log('FOUND SOMETHING WE DIDNT WANT!');
        // found something we didn't want
        return undefined;
      }

      foundIndices.push(i);
    }

    if (pendingIngredients.length !== 0) {
      // didn't find everything
      return undefined;
    }

    return foundIndices;
  }
   
  computeOutput(inventory) {
    if (this.findMatchingSlots(inventory) !== undefined) {
      return this.output.clone();
    }
    return undefined;
  }

  craft(inventory) {
    const slots = this.findMatchingSlots(inventory);
    if (!slots) return undefined;

    for (let slot of slots) {
      inventory.takeAt(slot, 1); // TODO: check return
    }

    return this.output.clone();
  }
}

class PositionalRecipe extends Recipe {
  // TODO: accept patternStrArray, ingredientMap (['AB''], {A:.., B:..})
  constructor(ingredientMatrix, output) {
    super();
    this.ingredientMatrix = ingredientMatrix;
    this.output = output;
  }

  findMatchingSlots(inputInventory) {
    console.log('findMatchingSlots',inputInventory);
    // inventory input ingredients must match this.ingredientMatrix at same (relative) positions
    const foundIndices = [];

    const a = PositionalRecipe.tighten(inputInventory);
    const inventory = a[0];
    const shiftRow = a[1];
    const shiftColumn = a[2];

    if (inventory.height !== this.ingredientMatrix.length || inventory.width !== this.ingredientMatrix[0].length) {
      console.log('fms wrong dimensions',
          inventory.height, this.ingredientMatrix.length,
          inventory.width, this.ingredientMatrix[0].length,
          inventory, this.ingredientMatrix);
      return undefined;
    }

    for (let i = 0; i < this.ingredientMatrix.length; ++i) {
      const row = this.ingredientMatrix[i];

      for (let j = 0; j < row.length; ++j) {
        const expectedName = row[j];

        const index = j + i * inventory.width;
        const actualPile = inventory.get(index);

        if (!global.CraftingThesaurus_instance.matchesName(expectedName, actualPile)) {
          console.log('fms not matching',expectedName,actualPile);
          return undefined;
        }

        // add original index from inputInventory for removing ingredients
        const unshiftedIndex = (j + shiftColumn) + (i + shiftRow) * inputInventory.width;
        foundIndices.push(unshiftedIndex);
      }
    }

    console.log('fms foundIndices',foundIndices);
    return foundIndices;
  }

  // tighten the bounds around an inventory, shrinking it from the edges if possible
  static tighten(inventory) {
    // iterate from each side, computing occupied bounds
    let x;
    for (x = 0; x < inventory.width; ++x) {
      let isOccupied = false;
      for (let y = 0; y < inventory.height; ++y) {
        if (inventory.get(y + x * inventory.width) !== undefined) {
          isOccupied = true;
        }
      }

      if (isOccupied) break;
    }

    const firstRow = x;

    for (x = inventory.width - 1; x >= 0; --x) {
      let isOccupied = false;
      for (let y = 0; y < inventory.height; ++y) {
        if (inventory.get(y + x * inventory.width) !== undefined) {
          isOccupied = true;
        }
      }
      if (isOccupied) break;
    }
    const lastRow = x;


    let y;
    for (y = 0; y < inventory.height; ++y) {
      let isOccupied = false;
      for (let x = 0; x < inventory.width; ++x) {
        if (inventory.get(y + x * inventory.width) !== undefined) {
          isOccupied = true;
        }
      }
      if (isOccupied) break;
    }

    const firstColumn = y;

    for (y = inventory.height - 1; y >= 0; --y) {
      let isOccupied = false;
      for (let x = 0; x < inventory.width; ++x) {
        if (inventory.get(y + x * inventory.width) !== undefined) {
          isOccupied = true;
        }
      }
      if (isOccupied) break;
    }
    const lastColumn = y;

    //console.log('firstRow',firstRow,'lastRow',lastRow);
    //console.log('firstColumn',firstColumn,'lastColumn',lastColumn);

    // copy to new smaller-or-equal inventory
    let newWidth = lastColumn - firstColumn + 1;
    let newHeight = lastRow - firstRow + 1;

    if (newWidth < 0 || newHeight < 0) {
      // completely empty inventory - but cannot shrink to 0x0 (dimensions must be
      // positive in inventory >=0.1.2), so go with the next best thing (1x1)
      newWidth = newHeight = 1;
    }

    //console.log('new ',newWidth,newHeight);
    const newInventory = new inventory.constructor(newWidth, newHeight);
    for (let oldX = firstRow; oldX <= lastRow; ++oldX) {
      for (let oldY = firstColumn; oldY <= lastColumn; ++oldY) {
        const pile = inventory.get(oldY + oldX * inventory.width);
        const newX = oldX - firstRow;
        const newY = oldY - firstColumn;
        newInventory.set(newY + newX * newInventory.width, pile);
      }
    }

    return [newInventory, firstRow, firstColumn];
  }

  computeOutput(inventory) {
    console.log('computeOutput',inventory);
    if (this.findMatchingSlots(inventory) !== undefined) {
      return this.output.clone();
    }
    return undefined;
  }

  // TODO: refactor with AmorphousRecipe
  craft(inventory) {
    const slots = this.findMatchingSlots(inventory);
    if (!slots) return undefined;

    for (let slot of slots) {
      inventory.takeAt(slot, 1); // TODO: check return
    }

    return this.output.clone();
  }
}

class RecipeList {
  constructor() {
    this.recipes = [];
  }

  register(recipe) {
    this.recipes.push(recipe);
  }

  find(inventory) {
    for (let recipe of this.recipes) {
      if (recipe.computeOutput(inventory) !== undefined) {
        return recipe;
      }
    }

    return undefined;
  }

  craft(inventory) {
    for (let recipe of this.recipes) {
      const output = recipe.craft(inventory);
      if (output) return output;
    }
    return undefined;
  } 
}

module.exports = (game, opts) => {
  throw new Error('craftingrecipes plugin (plugin only) replaced by voxel-recipes');
};

module.exports.Recipe = Recipe;
module.exports.AmorphousRecipe = AmorphousRecipe;
module.exports.PositionalRecipe = PositionalRecipe;
module.exports.CraftingThesaurus = CraftingThesaurus;
module.exports.RecipeList = RecipeList;

