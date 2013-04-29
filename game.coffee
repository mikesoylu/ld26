v = cp.v

# constants
PLAYER_WIDTH = 32
PLAYER_HEIGHT = 32

TILE_GROUP = 2
PLAYER_GROUP = 1

MAP_WIDTH = 16
MAP_HEIGHT = 16

COLOR_PALETTE = ["#CDD1FF", "#6C72B2", "#B3BAFF", "#B29F5A", "#FFEFB3"]


class Tilemap
  constructor: (objects, space) ->
    @tiles = new Array
    for i in objects
      if i.name is "spawn"
        # just fix the pos here so we dont do it in game.ctr
        @playerPos = v(i.x+i.width/2, i.y+i.height/2)
      else if i.name is "goal"
        @goalPos = v(i.x+i.width/2, i.y+i.height/2)
      else
        @tiles.push(new Tile(i.x, i.y, i.width, i.height, space))

  draw: ->
    for i in @tiles
      i.draw() if i?
    null

class Tile extends cp.Body
  constructor: (x, y, @width, @height, space) ->
    super(Infinity, Infinity)
    @setPos v(x+@width*0.5, y+@height*0.5)
    @shape = new cp.BoxShape(@, @width, @height)
    @shape.group = TILE_GROUP
    @colorIndex = 1
    @shape.collision_type = "tile"
    space.addBody(@)
    space.addShape(@shape)

  draw: ->
    atom.context.fillStyle = COLOR_PALETTE[@colorIndex]
    atom.context.fillRect(@p.x-@width/2, @p.y-@height/2, @width, @height)


class Entity extends cp.Body
  constructor: (x, y, space, @width = PLAYER_WIDTH, @height = PLAYER_HEIGHT) ->
    super(1, Infinity)
    @setPos v(x, y)
    @shape = new cp.CircleShape(@, Math.max(@width*0.5, @height*0.5), v(0,0))
    @shape.setFriction(0.5)
    @shape.setElasticity(0.8)
    @shape.group = PLAYER_GROUP
    @colorIndex = 4
    space.addBody(@)
    space.addShape(@shape)

  draw: ->
    atom.context.fillStyle = COLOR_PALETTE[@colorIndex]
    atom.context.save()
    atom.context.translate(@p.x, @p.y)
    atom.context.rotate(@a)
    atom.context.fillRect(-@width/2, -@height/2, @width, @height)
    atom.context.restore()

class Game extends atom.Game
  constructor: ->
    super()
    @currentLevel = 1
    @reset()

  reset: ->
    @isLoaded = false
    @finishedLevel = false
    @playerGrounded = false
    @space = new cp.Space()
    @space.damping = 0.01

    @player = new Entity(0, 0, @space)
    @player.shape.collision_type = "player"
    @player.shape.layers = 1

    @goal = new Tile(-2000, -2000, PLAYER_WIDTH, PLAYER_HEIGHT, @space)
    @goal.colorIndex = 3
    @goal.shape.collision_type = "goal"
    @goal.shape.layers = 1

    # load level
    $.getJSON("assets/level#{@currentLevel}.json", (data) =>
      console.log(data)
      @tilemaps = new Array
      for i in data.layers
        tm = new Tilemap(i.objects, @space)
        @tilemaps.push(tm)
        if tm.goalPos?
          @goal.p = tm.goalPos
        if tm.playerPos?
          @player.p = tm.playerPos
      @tilemap = @tilemaps[0]
      @updateTiles()
      @isLoaded = true
    )

    @space.addCollisionHandler "player", "goal", (arb) =>
      if not @finishedLevel
        @finishedLevel = true
        @space.addPostStepCallback @reachedGoal

    @space.addCollisionHandler "player", "tile", null, null, (arb) =>
      dx = arb.body_a.p.x-arb.body_b.p.x
      dy = arb.body_a.p.y-arb.body_b.p.y
      if dy<0 && Math.abs(dx)<PLAYER_WIDTH/2
        @playerGrounded = true
      return true

    atom.input.bind(atom.key.LEFT_ARROW, "left")
    atom.input.bind(atom.key.RIGHT_ARROW, "right")
    atom.input.bind(atom.key.UP_ARROW, "up")
    atom.input.bind(atom.key.A, "a")
    atom.input.bind(atom.key.DOWN_ARROW, "down")
    atom.input.bind(atom.button.LEFT, "mouse")

  reachedGoal: =>
    console.log("YAY")
    @currentLevel++
    @reset()

  updateTiles: ->
    for i in @tilemaps
      if i is @tilemap
        for j in i.tiles
          j.shape.layers = 1
      else
        for j in i.tiles
          j.shape.layers = 0
    null

  update: (dt) ->
    if @isLoaded is false
      return
    @player.resetForces()

    @player.applyForce(v(0,1000), v(0,0))

    if atom.input.down("left")
      @player.applyForce(v(-2000,0), v(0,0))

    if atom.input.down("right")
      @player.applyForce(v(2000,0), v(0,0))

    if atom.input.pressed("up") && @playerGrounded
      @player.vy = -500

    if atom.input.pressed("a")
      @tilemap = @tilemaps.pop()
      @tilemaps.unshift(@tilemap)
      @updateTiles()

    @playerGrounded = false
    @space.step(dt)
    null

  draw: ->
    if @isLoaded is false
      return
    atom.context.fillStyle = COLOR_PALETTE[2]
    atom.context.fillRect(0, 0, atom.width, atom.height)

    atom.context.save()
    atom.context.translate(-@player.p.x+atom.width*0.5,
      -@player.p.y+atom.height*0.5)

    @goal.draw()

    j = 1
    for i in @tilemaps
      atom.context.globalAlpha = j
      j *= 0.5
      i.draw()

    atom.context.globalAlpha = 1
    @player.draw()
    atom.context.restore()

game = new Game()

window.onblur = -> game.stop()
window.onfocus = -> game.run()

game.run()
