v = cp.v
TILE_WIDTH = 32
TILE_HEIGHT = 32
MAP_WIDTH = 4
MAP_HEIGHT = 4

class Tilemap
  constructor: (noise, depth, @space) ->
    @tiles = new Array
    for i in [0..MAP_WIDTH]
      for j in [0..MAP_HEIGHT]
        xx = i * TILE_WIDTH
        yy = j * TILE_HEIGHT
        if noise.noise3d(i, j, depth*0.2)>0.5 then @tiles.push(new Tile(xx, yy, @space)) else null
        #if noise.noise3d(i*0.1, j*0.1, depth*0.2)>0.5 then @tiles.push(new Tile(xx, yy, @space)) else null

  draw: ->
    for i in @tiles
      i.draw() if i?
    null

class Tile extends cp.Body
  constructor: (x, y, space) ->
    super(Infinity, Infinity)
    @.setPos v(x, y)
    @width = TILE_WIDTH
    @height = TILE_HEIGHT
    @shape = new cp.BoxShape(@, @width, @height)
    space.addBody(@)
    space.addShape(@shape)

  draw: ->
    atom.context.fillStyle = "white"
    atom.context.fillRect(@p.x-@width/2, @p.y-@height/2, @width, @height)


class Entity extends cp.Body
  constructor: (x, y, space, @width = TILE_WIDTH, @height = TILE_HEIGHT) ->
    super(1, Infinity)
    @.setPos v(x, y)
    @shape = new cp.CircleShape(@, Math.max(@width*0.5, @height*0.5), v(0,0))
    @shape.setFriction(0.5)
    @shape.setElasticity(0.8)
    space.addBody(@)
    space.addShape(@shape)

  draw: ->
    atom.context.fillStyle = "white"
    atom.context.save()
    atom.context.translate(@p.x, @p.y)
    atom.context.rotate(@a)
    atom.context.fillRect(-@width/2, -@height/2, @width, @height)
    atom.context.restore()

class Game extends atom.Game
  constructor: ->
    super()
    @space = new cp.Space()
    @space.damping = 0.01
    @player = new Entity(50, 50, @space)
    noise = new SimplexNoise()
    @tilemaps = new Array()
    for i in [0..4]
      @tilemaps[i] = new Tilemap(noise, i, @space)
    @tilemap = @tilemaps[0]
    @updateTiles()

    atom.input.bind(atom.key.LEFT_ARROW, "left")
    atom.input.bind(atom.key.RIGHT_ARROW, "right")
    atom.input.bind(atom.key.UP_ARROW, "up")
    atom.input.bind(atom.key.DOWN_ARROW, "down")
    atom.input.bind(atom.key.A, "a")
    atom.input.bind(atom.key.S, "s")
    atom.input.bind(atom.key.DOWN_ARROW, "down")
    atom.input.bind(atom.button.LEFT, "mouse")

  updateTiles: ->
    for i in @tilemaps
      if i is @tilemap
        for j in i.tiles
          j.active = true
      else
        for j in i.tiles
          j.active = false

  update: (dt) ->
    @player.resetForces()
    if atom.input.down("left")
      @player.applyForce(v(-2000,0), v(0,0))

    if atom.input.down("right")
      @player.applyForce(v(2000,0), v(0,0))

    if atom.input.down("up")
      @player.applyForce(v(0,-2000), v(0,0))

    if atom.input.down("down")
      @player.applyForce(v(0,2000), v(0,0))

    if atom.input.pressed("a")
      @tilemap = @tilemaps.pop()
      @tilemaps.unshift(@tilemap)
      @updateTiles()

    if atom.input.pressed("s")
      @tilemap = @tilemaps.shift()
      @tilemaps.push(@tilemap)
      @updateTiles()

    @space.step(dt)

  draw: ->
    atom.context.fillStyle = "#000"
    atom.context.fillRect(0, 0, atom.width, atom.height)
    atom.context.save()
    atom.context.translate(-@player.p.x+atom.width*0.5,
      -@player.p.y+atom.height*0.5)
    @player.draw()
    @tilemap.draw()
    atom.context.restore()

game = new Game()

window.onblur = -> game.stop()
window.onfocus = -> game.run()

game.run()
