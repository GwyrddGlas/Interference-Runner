GameStateManager = require("libs/GameStateManager") --global for easier management
local MainMenu = require("states/MainMenu")

function love.load()
    GameStateManager:setState(MainMenu) -- load main menu first
end

function love.update(dt)
    GameStateManager:update(dt)
end

function love.keypressed(key, scancode, isrepeat )
    if key == "escape" then
        GameStateManager:setState(GameStateManager:getPreviousState())
    end
end

function love.draw()
    GameStateManager:draw()
end