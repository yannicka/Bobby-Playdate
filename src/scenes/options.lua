local gfx <const> = playdate.graphics

class('OptionsScene').extends(Scene)

function OptionsScene:init()
    OptionsScene.super.init(self)

    gfx.setDrawOffset(0, 0)
end

function OptionsScene:update()
    gfx.drawText('*Options*', 10, 14)

    local playButton = ScreenButton('Reset progress', 20, 50, 10)
    playButton.selected = true
    playButton:render()

    if playdate.buttonJustPressed(playdate.kButtonA) then
        finishedLevels = {}
        playdate.datastore.write(finishedLevels)
        changeScene(HomeScene)
    end

    if playdate.buttonJustPressed(playdate.kButtonB) then
        changeScene(HomeScene)
    end
end

function OptionsScene:destroy()
end
