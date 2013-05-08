// Generated by CoffeeScript 1.5.0
(function() {
  var COLOR_PALETTE, COLOR_PALETTES, Entity, Game, MAP_HEIGHT, MAP_WIDTH, PLAYER_GROUP, PLAYER_HEIGHT, PLAYER_WIDTH, TILE_GROUP, Tile, Tilemap, game, v, zoom,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  v = cp.v;

  PLAYER_WIDTH = 32;

  PLAYER_HEIGHT = 32;

  TILE_GROUP = 2;

  PLAYER_GROUP = 1;

  MAP_WIDTH = 16;

  MAP_HEIGHT = 16;

  COLOR_PALETTES = [["#CDD1FF", "#6C72B2", "#B3BAFF", "#B29F5A", "#FFEFB3"], ["#2B2E36", "#54877E", "#B1B88C", "#F2D9A0", "#9E4C43"], ["#B8BBBF", "#9FA2A6", "#636364", "#D4E204", "#F2D9A0"], ["#B24504", "#FF660D", "#FF7626", "#00B2B2", "#0DFFFF"], ["#FF5A33", "#FFBEB0", "#FAF6F3", "#D6DAE2", "#364A73"], ["#F24968", "#03A64A", "#F2CB05", "#F79120", "#B296C6"]];

  COLOR_PALETTE = COLOR_PALETTES[0];

  zoom = 0.1;

  Tilemap = (function() {

    function Tilemap(objects, space) {
      var i, _i, _len;
      this.tiles = new Array;
      for (_i = 0, _len = objects.length; _i < _len; _i++) {
        i = objects[_i];
        if (i.name === "spawn") {
          this.playerPos = v(i.x + i.width / 2, i.y + i.height / 2);
        } else if (i.name === "goal") {
          this.goalPos = v(i.x + i.width / 2, i.y + i.height / 2);
        } else {
          this.tiles.push(new Tile(i.x, i.y, i.width, i.height, space));
        }
      }
    }

    Tilemap.prototype.draw = function() {
      var i, _i, _len, _ref;
      _ref = this.tiles;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        if (i != null) {
          i.draw();
        }
      }
      return null;
    };

    return Tilemap;

  })();

  Tile = (function(_super) {

    __extends(Tile, _super);

    function Tile(x, y, width, height, space) {
      this.width = width;
      this.height = height;
      Tile.__super__.constructor.call(this, Infinity, Infinity);
      this.setPos(v(x + this.width * 0.5, y + this.height * 0.5));
      this.shape = new cp.BoxShape(this, this.width, this.height);
      this.shape.setFriction(0);
      this.shape.group = TILE_GROUP;
      this.colorIndex = 1;
      this.shape.collision_type = "tile";
      space.addBody(this);
      space.addShape(this.shape);
    }

    Tile.prototype.draw = function() {
      atom.context.fillStyle = COLOR_PALETTE[this.colorIndex];
      atom.context.save();
      if (zoom > 1.01 || zoom < 0.99) {
        atom.context.translate(this.p.x, this.p.y);
        atom.context.scale(zoom, zoom);
        atom.context.translate(-this.p.x, -this.p.y);
      }
      atom.context.fillRect(this.p.x - this.width / 2, this.p.y - this.height / 2, this.width, this.height);
      return atom.context.restore();
    };

    return Tile;

  })(cp.Body);

  Entity = (function(_super) {

    __extends(Entity, _super);

    function Entity(x, y, space, width, height) {
      this.width = width != null ? width : PLAYER_WIDTH;
      this.height = height != null ? height : PLAYER_HEIGHT;
      Entity.__super__.constructor.call(this, 1, Infinity);
      this.setPos(v(x, y));
      this.shape = new cp.CircleShape(this, Math.max(this.width * 0.5, this.height * 0.5), v(0, 0));
      this.shape.setFriction(0);
      this.shape.setElasticity(0);
      this.shape.group = PLAYER_GROUP;
      this.colorIndex = 4;
      space.addBody(this);
      space.addShape(this.shape);
    }

    Entity.prototype.draw = function() {
      atom.context.fillStyle = COLOR_PALETTE[this.colorIndex];
      atom.context.save();
      atom.context.translate(this.p.x, this.p.y);
      atom.context.rotate(this.a);
      atom.context.scale(zoom, zoom);
      atom.context.fillRect(-this.width / 2, -this.height / 2, this.width, this.height);
      atom.context.fill();
      return atom.context.restore();
    };

    return Entity;

  })(cp.Body);

  Game = (function(_super) {

    __extends(Game, _super);

    function Game() {
      this.reachedGoal = __bind(this.reachedGoal, this);      Game.__super__.constructor.call(this);
      this.currentLevel = 3;
      this.reset();
    }

    Game.prototype.reset = function() {
      var _this = this;
      this.isLoaded = false;
      this.finishedLevel = false;
      this.space = new cp.Space();
      this.space.damping = 0.5;
      this.player = new Entity(0, 0, this.space);
      this.player.shape.collision_type = "player";
      this.player.shape.layers = 1;
      this.goal = new Tile(-2000, -2000, PLAYER_WIDTH, PLAYER_HEIGHT, this.space);
      this.goal.colorIndex = 3;
      this.goal.shape.collision_type = "goal";
      this.goal.shape.layers = 1;
      $.getJSON("assets/level" + this.currentLevel + ".json", function(data) {
        var i, tm, _i, _len, _ref;
        console.log(data);
        _this.tilemaps = new Array;
        _ref = data.layers;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          tm = new Tilemap(i.objects, _this.space);
          _this.tilemaps.push(tm);
          if (tm.goalPos != null) {
            _this.goal.p = tm.goalPos;
          }
          if (tm.playerPos != null) {
            _this.player.p = tm.playerPos;
          }
        }
        _this.tilemap = _this.tilemaps[0];
        _this.updateTiles();
        return _this.isLoaded = true;
      });
      this.space.addCollisionHandler("player", "goal", function(arb) {
        if (!_this.finishedLevel) {
          return _this.finishedLevel = true;
        }
      });
      atom.input.bind(atom.key.LEFT_ARROW, "left");
      atom.input.bind(atom.key.RIGHT_ARROW, "right");
      atom.input.bind(atom.key.UP_ARROW, "up");
      atom.input.bind(atom.key.A, "a");
      atom.input.bind(atom.key.DOWN_ARROW, "down");
      return atom.input.bind(atom.button.LEFT, "mouse");
    };

    Game.prototype.reachedGoal = function() {
      console.log("YAY");
      this.currentLevel++;
      return this.reset();
    };

    Game.prototype.updateTiles = function() {
      var i, j, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
      _ref = this.tilemaps;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        if (i === this.tilemap) {
          _ref1 = i.tiles;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            j = _ref1[_j];
            j.shape.layers = 1;
          }
        } else {
          _ref2 = i.tiles;
          for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
            j = _ref2[_k];
            j.shape.layers = 0;
          }
        }
      }
      return null;
    };

    Game.prototype.update = function(dt) {
      var keyFlag, playerGrounded;
      if (this.isLoaded === false) {
        return;
      }
      if (this.finishedLevel) {
        zoom += -zoom * 0.2;
        if (zoom < 0.1) {
          this.reachedGoal();
          zoom = 0.1;
        }
      } else {
        zoom += (1 - zoom) * 0.2;
      }
      playerGrounded = this.space.pointQueryFirst(v(this.player.p.x, this.player.p.y + PLAYER_HEIGHT / 2 + 5), 1, PLAYER_GROUP);
      this.player.resetForces();
      this.player.applyForce(v(0, 500), v(0, 0));
      keyFlag = false;
      if (atom.input.down("left")) {
        if (this.player.vx > 0) {
          this.player.vx *= 0.5;
        }
        this.player.applyForce(v(-500, 0), v(0, 0));
        keyFlag = true;
      }
      if (atom.input.down("right")) {
        if (this.player.vx < 0) {
          this.player.vx *= 0.5;
        }
        this.player.applyForce(v(500, 0), v(0, 0));
        keyFlag = true;
      }
      if (playerGrounded != null) {
        if (!keyFlag) {
          this.player.vx *= 0.5;
        }
        if (atom.input.pressed("up")) {
          this.player.vy = -300;
        }
      }
      if (atom.input.pressed("a")) {
        this.tilemap = this.tilemaps.pop();
        this.tilemaps.unshift(this.tilemap);
        COLOR_PALETTE = COLOR_PALETTES.pop();
        COLOR_PALETTES.unshift(COLOR_PALETTE);
        this.updateTiles();
      }
      if (this.player.p.y > 800) {
        this.reset();
      }
      this.space.step(dt);
      return null;
    };

    Game.prototype.draw = function() {
      var i, j, _i, _len, _ref;
      if (this.isLoaded === false) {
        return;
      }
      atom.context.fillStyle = COLOR_PALETTE[2];
      atom.context.fillRect(0, 0, atom.width, atom.height);
      atom.context.save();
      atom.context.translate(-this.player.p.x + atom.width * 0.5, -this.player.p.y + atom.height * 0.5);
      this.goal.draw();
      j = 1;
      _ref = this.tilemaps;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        atom.context.globalAlpha = j;
        j *= 0.5;
        i.draw();
      }
      atom.context.globalAlpha = 1;
      this.player.draw();
      return atom.context.restore();
    };

    return Game;

  })(atom.Game);

  game = new Game();

  window.onblur = function() {
    return game.stop();
  };

  window.onfocus = function() {
    return game.run();
  };

  game.run();

}).call(this);
