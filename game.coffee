v = cp.v

class Entity extends cp.Body
  constructor: (x, y, @space) ->
    super(3,1,20, v(x,y))
    @width = 12
    @height = 12
    @shape = new cp.CircleShape(@, 20, v(0,0))
    @shape.setFriction(1)

  draw: ->
    atom.context.fillStyle = "white"
    atom.context.fillRect(@p.x-@width/2, @p.y-@height/2, @width, @height)

class Game extends atom.Game
  constructor: ->
    super()
    space = new cp.Space()
    player = new Entity(50, 50, space)
    space.addBody(player)
    space.addShape(player.shape)

    @player = player
    @space = space

    atom.input.bind(atom.key.LEFT_ARROW, "left")
    atom.input.bind(atom.key.RIGHT_ARROW, "right")
    atom.input.bind(atom.key.UP_ARROW, "up")
    atom.input.bind(atom.key.DOWN_ARROW, "down")
    atom.input.bind(atom.button.LEFT, "mouse")

  update: (dt) ->
    @player.resetForces()
    if atom.input.down("left")
      @player.applyForce(v(-100,0),v(0,0))

    if atom.input.down("right")
      @player.applyForce(v(100,0),v(0,0))

    if atom.input.down("up")
      @player.applyForce(v(0,-100),v(0,0))

    if atom.input.down("down")
      @player.applyForce(v(0,100),v(0,0))


    @space.step(dt)

  draw: ->
    atom.context.fillStyle = "#000"
    atom.context.fillRect(0, 0, atom.width, atom.height)
    @player.draw()

game = new Game()

window.onblur = -> game.stop()
window.onfocus = -> game.run()

game.run()
