// Generated by CoffeeScript 1.5.0
(function() {
  var Entity, Game, MAP_HEIGHT, MAP_WIDTH, TILE_HEIGHT, TILE_WIDTH, Tile, Tilemap, game, v,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  v = cp.v;

  TILE_WIDTH = 32;

  TILE_HEIGHT = 32;

  MAP_WIDTH = 4;

  MAP_HEIGHT = 4;

  Tilemap = (function() {

    function Tilemap(noise, depth, space) {
      var i, j, xx, yy, _i, _j;
      this.space = space;
      this.tiles = new Array;
      for (i = _i = 0; 0 <= MAP_WIDTH ? _i <= MAP_WIDTH : _i >= MAP_WIDTH; i = 0 <= MAP_WIDTH ? ++_i : --_i) {
        for (j = _j = 0; 0 <= MAP_HEIGHT ? _j <= MAP_HEIGHT : _j >= MAP_HEIGHT; j = 0 <= MAP_HEIGHT ? ++_j : --_j) {
          xx = i * TILE_WIDTH;
          yy = j * TILE_HEIGHT;
          if (noise.noise3d(i, j, depth * 0.2) > 0.5) {
            this.tiles.push(new Tile(xx, yy, this.space));
          } else {
            null;
          }
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

    function Tile(x, y, space) {
      Tile.__super__.constructor.call(this, Infinity, Infinity);
      this.setPos(v(x, y));
      this.width = TILE_WIDTH;
      this.height = TILE_HEIGHT;
      this.shape = new cp.BoxShape(this, this.width, this.height);
      space.addBody(this);
      space.addShape(this.shape);
    }

    Tile.prototype.draw = function() {
      atom.context.fillStyle = "white";
      return atom.context.fillRect(this.p.x - this.width / 2, this.p.y - this.height / 2, this.width, this.height);
    };

    return Tile;

  })(cp.Body);

  Entity = (function(_super) {

    __extends(Entity, _super);

    function Entity(x, y, space, width, height) {
      this.width = width != null ? width : TILE_WIDTH;
      this.height = height != null ? height : TILE_HEIGHT;
      Entity.__super__.constructor.call(this, 1, Infinity);
      this.setPos(v(x, y));
      this.shape = new cp.CircleShape(this, Math.max(this.width * 0.5, this.height * 0.5), v(0, 0));
      this.shape.setFriction(0.5);
      this.shape.setElasticity(0.8);
      space.addBody(this);
      space.addShape(this.shape);
    }

    Entity.prototype.draw = function() {
      atom.context.fillStyle = "white";
      atom.context.save();
      atom.context.translate(this.p.x, this.p.y);
      atom.context.rotate(this.a);
      atom.context.fillRect(-this.width / 2, -this.height / 2, this.width, this.height);
      return atom.context.restore();
    };

    return Entity;

  })(cp.Body);

  Game = (function(_super) {

    __extends(Game, _super);

    function Game() {
      var i, noise, _i;
      Game.__super__.constructor.call(this);
      this.space = new cp.Space();
      this.space.damping = 0.01;
      this.player = new Entity(50, 50, this.space);
      noise = new SimplexNoise();
      this.tilemaps = new Array();
      for (i = _i = 0; _i <= 4; i = ++_i) {
        this.tilemaps[i] = new Tilemap(noise, i, this.space);
      }
      this.tilemap = this.tilemaps[0];
      this.updateTiles();
      atom.input.bind(atom.key.LEFT_ARROW, "left");
      atom.input.bind(atom.key.RIGHT_ARROW, "right");
      atom.input.bind(atom.key.UP_ARROW, "up");
      atom.input.bind(atom.key.DOWN_ARROW, "down");
      atom.input.bind(atom.key.A, "a");
      atom.input.bind(atom.key.S, "s");
      atom.input.bind(atom.key.DOWN_ARROW, "down");
      atom.input.bind(atom.button.LEFT, "mouse");
    }

    Game.prototype.updateTiles = function() {
      var i, j, _i, _len, _ref, _results;
      _ref = this.tilemaps;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        if (i === this.tilemap) {
          _results.push((function() {
            var _j, _len1, _ref1, _results1;
            _ref1 = i.tiles;
            _results1 = [];
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              j = _ref1[_j];
              _results1.push(j.active = true);
            }
            return _results1;
          })());
        } else {
          _results.push((function() {
            var _j, _len1, _ref1, _results1;
            _ref1 = i.tiles;
            _results1 = [];
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              j = _ref1[_j];
              _results1.push(j.active = false);
            }
            return _results1;
          })());
        }
      }
      return _results;
    };

    Game.prototype.update = function(dt) {
      this.player.resetForces();
      if (atom.input.down("left")) {
        this.player.applyForce(v(-2000, 0), v(0, 0));
      }
      if (atom.input.down("right")) {
        this.player.applyForce(v(2000, 0), v(0, 0));
      }
      if (atom.input.down("up")) {
        this.player.applyForce(v(0, -2000), v(0, 0));
      }
      if (atom.input.down("down")) {
        this.player.applyForce(v(0, 2000), v(0, 0));
      }
      if (atom.input.pressed("a")) {
        this.tilemap = this.tilemaps.pop();
        this.tilemaps.unshift(this.tilemap);
        this.updateTiles();
      }
      if (atom.input.pressed("s")) {
        this.tilemap = this.tilemaps.shift();
        this.tilemaps.push(this.tilemap);
        this.updateTiles();
      }
      return this.space.step(dt);
    };

    Game.prototype.draw = function() {
      atom.context.fillStyle = "#000";
      atom.context.fillRect(0, 0, atom.width, atom.height);
      atom.context.save();
      atom.context.translate(-this.player.p.x + atom.width * 0.5, -this.player.p.y + atom.height * 0.5);
      this.player.draw();
      this.tilemap.draw();
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
