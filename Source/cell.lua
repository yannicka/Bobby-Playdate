import 'CoreLibs/object'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'

local gfx <const> = playdate.graphics

local CELL_SIZE <const> = 20

local tilesImage = gfx.imagetable.new('img/tiles')
assert(tilesImage)

class('Cell').extends(playdate.graphics.sprite)

function Cell:init(position)
    Cell.super.init(self)

    self.position = position

    self:setCenter(0, 0)
    self:setImage(tilesImage[1])
    self:setZIndex(700)
    self:moveTo(position[1] * CELL_SIZE, position[2] * CELL_SIZE)
    self:add()
end

function Cell:update(dt)
    -- self.animationManager.update(dt)
end

function Cell:render(ctx)
    ctx.save()
    ctx.translate(self.position.x * CELL_SIZE, self.position.y * CELL_SIZE)

    self.animationManager.render(ctx)

    ctx.restore()
end

-- Évènement : avant que le joueur n'entre dans la case
function Cell:onBeforePlayerIn(_player)
    -- À surcharger
end

-- Évènement : lorsque le joueur est entièrement dans la case
--
-- @return `this` si la case est inchangée ou `null` pour la supprimer
function Cell:onAfterPlayerIn(_player, _game)
    return this
end

-- Évènement : lorsque le joueur a quitté la case
function Cell:onAfterPlayerOut()
    -- À surcharger
end

-- Est-ce qu'on peut rentrer sur la case ?
function Cell:canEnter(_direction)
    return true
end

-- Est-ce qu'on peut sortir de la case ?
function Cell:canLeave(_direction)
    return true
end

function Cell:getPosition()
    return self.position
end

function Cell:getAnimationManager()
    return self.animationManager
end

-- Pièce
class('Coin').extends(Cell)

function Coin:init(position)
    Coin.super.init(self, position)

    self:setImage(tilesImage[11])
end

function Coin:onAfterPlayerIn(_player)
    self:remove()
end

-- Rocher
class('Stone').extends(Cell)

function Stone:init(position)
    Stone.super.init(self, position)

    self:setImage(tilesImage[1])
end

function Stone:canEnter()
    return false
end

-- Bouton
class('Button').extends(Cell)

function Button:init(position, value)
    Button.super.init(self, position)

    self:setImage(tilesImage[82])

    self.value = value or 1
end

function Button:onAfterPlayerOut()
    self.value -= 1

    self:setImage(tilesImage[81])
end

function Button:canEnter(_direction)
    return self.value ~= 0
end

-- Tapis roulant
class('Conveyor').extends(Cell)

function Conveyor:init(position, direction)
    Conveyor.super.init(self, position)

    self:setImage(tilesImage[31])

    self.direction = direction
end

function Conveyor:onAfterPlayerIn(player, _game)
    player:move(self.direction)

    return self
end

local a = [[

// Tapis roulant
export class Conveyor extends Cell {
  private readonly direction: Direction

  public constructor(position: Point, direction: Direction) {
    super(position)

    this.direction = direction

    this.getAnimationManager().addAnimation(Direction.Up.toString(), [ 30, 31, 32, 33 ], {
      frameDuration: 0.08,
    })

    this.getAnimationManager().addAnimation(Direction.Right.toString(), [ 40, 41, 42, 43 ], {
      frameDuration: 0.08,
    })

    this.getAnimationManager().addAnimation(Direction.Down.toString(), [ 50, 51, 52, 53 ], {
      frameDuration: 0.08,
    })

    this.getAnimationManager().addAnimation(Direction.Left.toString(), [ 60, 61, 62, 63 ], {
      frameDuration: 0.08,
    })

    this.getAnimationManager().play(direction.toString())
  }

  public onAfterPlayerIn(player: Player, _game: Game): this | null {
    player.move(this.direction, 'idle')

    return this
  }
}

// Tourniquet
export class Turnstile extends Cell {
  private angle: Rotation

  public constructor(position: Point, angle: Rotation) {
    super(position)

    this.angle = angle

    this.getAnimationManager().addAnimation(Rotation.UpLeft.toString(), [ 70 ])
    this.getAnimationManager().addAnimation(Rotation.UpRight.toString(), [ 71 ])
    this.getAnimationManager().addAnimation(Rotation.DownRight.toString(), [ 72 ])
    this.getAnimationManager().addAnimation(Rotation.DownLeft.toString(), [ 73 ])

    this.getAnimationManager().addAnimation(Rotation.Horizontal.toString(), [ 74 ])
    this.getAnimationManager().addAnimation(Rotation.Vertical.toString(), [ 75 ])

    this.getAnimationManager().addAnimation(Rotation.Up.toString(), [ 76 ])
    this.getAnimationManager().addAnimation(Rotation.Right.toString(), [ 77 ])
    this.getAnimationManager().addAnimation(Rotation.Down.toString(), [ 78 ])
    this.getAnimationManager().addAnimation(Rotation.Left.toString(), [ 79 ])

    this.getAnimationManager().play(angle.toString())
  }

  public onAfterPlayerOut(): void {
    switch (this.angle) {
      case Rotation.UpRight:
        this.angle = Rotation.DownRight
        break

      case Rotation.UpLeft:
        this.angle = Rotation.UpRight
        break

      case Rotation.DownRight:
        this.angle = Rotation.DownLeft
        break

      case Rotation.DownLeft:
        this.angle = Rotation.UpLeft
        break

      case Rotation.Vertical:
        this.angle = Rotation.Horizontal
        break

      case Rotation.Horizontal:
        this.angle = Rotation.Vertical
        break

      case Rotation.Up:
        this.angle = Rotation.Right
        break

      case Rotation.Right:
        this.angle = Rotation.Down
        break

      case Rotation.Down:
        this.angle = Rotation.Left
        break

      case Rotation.Left:
        this.angle = Rotation.Up
        break
    }

    this.getAnimationManager().play(this.angle.toString())
  }

  public canEnter(direction: Direction): boolean {
    switch (this.angle) {
      case Rotation.UpRight:
        return [ Direction.Down, Direction.Left ].includes(direction)

      case Rotation.UpLeft:
        return [ Direction.Down, Direction.Right ].includes(direction)

      case Rotation.DownRight:
        return [ Direction.Up, Direction.Left ].includes(direction)

      case Rotation.DownLeft:
        return [ Direction.Up, Direction.Right ].includes(direction)

      case Rotation.Vertical:
        return [ Direction.Right, Direction.Left ].includes(direction)

      case Rotation.Horizontal:
        return [ Direction.Up, Direction.Down ].includes(direction)

      case Rotation.Up:
        return direction === Direction.Down

      case Rotation.Right:
        return direction === Direction.Left

      case Rotation.Down:
        return direction === Direction.Up

      case Rotation.Left:
        return direction === Direction.Right
    }
  }

  public canLeave(direction: Direction): boolean {
    switch (this.angle) {
      case Rotation.UpRight:
        return [ Direction.Up, Direction.Right ].includes(direction)

      case Rotation.UpLeft:
        return [ Direction.Up, Direction.Left ].includes(direction)

      case Rotation.DownRight:
        return [ Direction.Down, Direction.Right ].includes(direction)

      case Rotation.DownLeft:
        return [ Direction.Down, Direction.Left ].includes(direction)

      case Rotation.Vertical:
        return [ Direction.Right, Direction.Left ].includes(direction)

      case Rotation.Horizontal:
        return [ Direction.Up, Direction.Down ].includes(direction)

      case Rotation.Up:
        return direction === Direction.Up

      case Rotation.Right:
        return direction === Direction.Right

      case Rotation.Down:
        return direction === Direction.Down

      case Rotation.Left:
        return direction === Direction.Left
    }
  }
}

// Balise de début de niveau
export class Start extends Cell {
  public constructor(position: Point) {
    super(position)
  }

  public render(_ctx: CanvasRenderingContext2D): void {
    // Pas de rendu
  }
}

// Balise de fin de niveau
export class End extends Cell {
  private active: boolean

  public constructor(position: Point) {
    super(position)

    this.active = false

    this.getAnimationManager().addAnimation('inactive', [ 20 ])

    this.getAnimationManager().addAnimation('active', [ 21, 22, 23, 24, 23, 22 ], {
      frameDuration: 0.1,
    })

    this.getAnimationManager().play('inactive')
  }

  public onAfterPlayerIn(player: Player, game: Game): this | null {
    if (this.isActive()) {
      player.setImmobility(true)
      player.getAnimationManager().play('turn')

      setTimeout(() => {
        game.nextLevel()
      }, 480)
    }

    return this
  }

  public activate(): void {
    this.active = true

    this.getAnimationManager().play('active')
  }

  public isActive(): boolean {
    return this.active
  }
}

// Pièce
export class Coin extends Cell {
  public constructor(position: Point) {
    super(position)

    this.getAnimationManager().addAnimation('idle', [ 10 ])

    this.getAnimationManager().play('idle')
  }

  public onAfterPlayerIn(_player: Player, _game: Game): this | null {
    return null
  }
}

// Glace
export class Ice extends Cell {
  public constructor(position: Point) {
    super(position)

    this.getAnimationManager().addAnimation('idle', [ 2 ])

    this.getAnimationManager().play('idle')
  }

  public onAfterPlayerIn(player: Player, _game: Game): this | null {
    player.move(player.getDirection(), 'idle')

    return this
  }
}

// Élévation de terrain / Motte de terre
export class Elevation extends Cell {
  public constructor(position: Point) {
    super(position)

    this.getAnimationManager().addAnimation('idle', [ 1 ])

    this.getAnimationManager().play('idle')
  }

  public onBeforePlayerIn(player: Player): void {
    player.getAnimationManager().play(`jump-${Direction.Down.toString()}`, true)
  }

  public onAfterPlayerIn(player: Player, _game: Game): this | null {
    player.move(player.getDirection(), null)

    return this
  }

  public canEnter(direction: Direction): boolean {
    if (direction === Direction.Down) {
      return false
    }

    return true
  }
}

]]
