v = cp.v

# constants
PLAYER_WIDTH = 32
PLAYER_HEIGHT = 32

TILE_GROUP = 2
PLAYER_GROUP = 1

MAP_WIDTH = 16
MAP_HEIGHT = 16

COLOR_PALETTES = [["#CDD1FF", "#6C72B2", "#B3BAFF", "#B29F5A", "#FFEFB3"],
                  ["#2B2E36", "#54877E", "#B1B88C", "#F2D9A0", "#9E4C43"],
                  ["#B8BBBF", "#9FA2A6", "#636364", "#D4E204", "#F2D9A0"],
                  ["#B24504", "#FF660D", "#FF7626", "#00B2B2", "#0DFFFF"],
                  ["#FF5A33", "#FFBEB0", "#FAF6F3", "#D6DAE2", "#364A73"],
                  ["#F24968", "#03A64A", "#F2CB05", "#F79120", "#B296C6"]]

# globals
COLOR_PALETTE = COLOR_PALETTES[0]
zoom = 0.1

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
    @shape.setFriction(0)
    @shape.group = TILE_GROUP
    @colorIndex = 1
    @shape.collision_type = "tile"
    space.addBody(@)
    space.addShape(@shape)

  draw: ->
    atom.context.fillStyle = COLOR_PALETTE[@colorIndex]
    atom.context.save()
    if zoom > 1.01 || zoom < 0.99
      atom.context.translate(@p.x, @p.y)
      atom.context.scale(zoom, zoom)
      atom.context.translate(-@p.x, -@p.y)
    atom.context.fillRect(@p.x-@width/2, @p.y-@height/2, @width, @height)
    atom.context.restore()


class Entity extends cp.Body
  constructor: (x, y, space, @width = PLAYER_WIDTH, @height = PLAYER_HEIGHT) ->
    super(1, Infinity)
    @setPos v(x, y)
    @shape = new cp.CircleShape(@, Math.max(@width*0.5, @height*0.5), v(0,0))
    @shape.setFriction(0)
    @shape.setElasticity(0)
    @shape.group = PLAYER_GROUP
    @colorIndex = 4
    space.addBody(@)
    space.addShape(@shape)

  draw: ->
    atom.context.fillStyle = COLOR_PALETTE[@colorIndex]
    atom.context.save()
    atom.context.translate(@p.x, @p.y)
    atom.context.rotate(@a)
    atom.context.scale(zoom, zoom)
    atom.context.fillRect(-@width/2, -@height/2, @width, @height)
    #atom.context.arc(0, 0, @width/2, 0, 2 * Math.PI, false)
    atom.context.fill()
    atom.context.restore()

class Game extends atom.Game
  constructor: ->
    super()
    @currentLevel = 3
    @reset()

  reset: ->
    @isLoaded = false
    @finishedLevel = false
    @space = new cp.Space()
    @space.damping = 0.5

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

    if @finishedLevel
      zoom += -zoom*0.2
      if zoom < 0.1
        @reachedGoal()
        zoom = 0.1
    else
      zoom += (1-zoom)*0.2

    # is the player on a platform
    playerGrounded = @space.pointQueryFirst(v(@player.p.x,
      @player.p.y+PLAYER_HEIGHT/2+5), 1, PLAYER_GROUP)


    @player.resetForces()
    # gravity
    @player.applyForce(v(0,500), v(0,0))

    keyFlag = false
    if atom.input.down("left")
      if @player.vx > 0
        @player.vx *= 0.5
      @player.applyForce(v(-500, 0), v(0,0))
      keyFlag = true

    if atom.input.down("right")
      if @player.vx < 0
        @player.vx *= 0.5
      @player.applyForce(v(500, 0), v(0,0))
      keyFlag = true

    if playerGrounded?
      if not keyFlag
        @player.vx *= 0.5
      if atom.input.pressed("up")
        @player.vy = -300

    if atom.input.pressed("a")
      @tilemap = @tilemaps.pop()
      @tilemaps.unshift(@tilemap)
      COLOR_PALETTE = COLOR_PALETTES.pop()
      COLOR_PALETTES.unshift(COLOR_PALETTE)
      @updateTiles()

    if @player.p.y > 800
      @reset()

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
