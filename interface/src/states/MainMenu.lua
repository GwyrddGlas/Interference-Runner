local ingame = require("states/InGame")
local settings = require("states/Settings")

local MainMenu = {
    delayAfterEnter = 0.5
}

local buttons = {}

local function newButton(text, fn)
    return {
        text = text,
        fn = fn,
        now = false,
        last = false
    }
end

local function addMenuButtons()
    buttons = {}
    
    table.insert(buttons, newButton(
        "Play",
        function()
            GameStateManager:setState(ingame)
        end
    ))
    
    table.insert(buttons, newButton(
        "Settings",
        function()
            GameStateManager:setState(settings)
        end
    ))

    table.insert(buttons, newButton(
        "Quit",
        function()
            love.event.quit()
        end
    ))
end

function MainMenu:enter()
    MainMenu.delay = MainMenu.delayAfterEnter
    local myFont = love.graphics.newFont(25)
    love.graphics.setFont(myFont)
    self.backgroundImage = love.graphics.newImage("sprites/backgroundMain.png")

    print("Entered Main Menu")
    addMenuButtons()
end

function MainMenu:update(dt)
    if MainMenu.delay and MainMenu.delay > 0 then
        MainMenu.delay = MainMenu.delay - dt
        return
    end

    MainMenu.delay = nil

    local x, y = love.mouse.getPosition()

    for i, button in ipairs(buttons) do
        button.last = button.now
        button.now = x > button.x and x < button.x + button.width and y > button.y and y < button.y + button.height

        if button.now and love.mouse.isDown(1)  then
            button.fn()
        end
    end
end 

local function drawRoundedRectWithOutline(x, y, width, height, borderRadius, fillColor, outlineColor, lineWidth)
    love.graphics.setColor(fillColor)
    love.graphics.rectangle("fill", x, y, width, height, borderRadius, borderRadius)

    love.graphics.setColor(outlineColor)
    love.graphics.setLineWidth(lineWidth or 2) 
    love.graphics.rectangle("line", x, y, width, height, borderRadius, borderRadius)

    love.graphics.setColor(1, 1, 1, 1)
end

function MainMenu:draw()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local baseWidth = 250 * 1.5 
    local baseHeight = 50 * 1.5
    local margin = 15 * 1.5
    local totalButtonHeight = (#buttons * baseHeight) + ((#buttons - 1) * margin)
    local buttonStartY = (screenHeight - totalButtonHeight) / 2  -- Start in the middle of the screen

    -- Draw the background image
    love.graphics.draw(self.backgroundImage, 0, 0, 0, screenWidth / self.backgroundImage:getWidth(), screenHeight / self.backgroundImage:getHeight())

    for i, button in ipairs(buttons) do
        -- Center the button horizontally
        button.x = (screenWidth - baseWidth) / 2
        -- Position the button vertically
        button.y = buttonStartY + ((baseHeight + margin) * (i - 1))
        
        button.width = baseWidth
        button.height = baseHeight

        local fillColor = {0.012, 0.224, 0.502} -- fill color
        local outlineColor = {1, 1, 1} -- outline color

        -- Draw the filled rectangle for the button background
        drawRoundedRectWithOutline(button.x, button.y, button.width, button.height, 10, fillColor, outlineColor, 2)
        
        if button.now then
            drawRoundedRectWithOutline(button.x, button.y, button.width, button.height, 10, {0.992, 0.455, 0.745}, {1, 1, 1}, 2) -- Light blue color for hover effect
        end

        -- Draw the button text
        local textW = love.graphics.getFont():getWidth(button.text)
        local textH = love.graphics.getFont():getHeight(button.text)
        love.graphics.setColor(1, 1, 1, 1) -- White text color
        love.graphics.print(button.text, button.x + (baseWidth / 2) - (textW / 2), button.y + (baseHeight / 2) - (textH / 2))
    end
end

return MainMenu