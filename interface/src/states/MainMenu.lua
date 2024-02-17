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
    local baseWidth = 250 
    local baseHeight = 50 
    local margin = 15 
    local borderRadius = 10 
    local outerPadding = 20 
    local gapBetweenLogoAndButtons = 50 

    local totalButtonHeight = (#buttons * baseHeight * 1.2) + ((#buttons - 1) * margin)

    local outerRectWidth = baseWidth * 1.2 + outerPadding * 2
    local outerRectHeight = totalButtonHeight + outerPadding * 2
    local outerRectX = love.graphics.getWidth() / 4 - outerRectWidth / 2
    local outerRectY = love.graphics.getHeight() / 2 - outerRectHeight / 2 

    -- Draw the outer rounded rectangle
    local outerFillColor = {0.4, 0.2, 0.6} -- Purple fill color
    local outerOutlineColor =  {0.8, 0.4, 1} -- Light purple outline color
    drawRoundedRectWithOutline(outerRectX, outerRectY, outerRectWidth, outerRectHeight, borderRadius, outerFillColor, outerOutlineColor, 4)

    -- Draw buttons inside the outer rounded rectangle
    for i, button in ipairs(buttons) do
        button.x = outerRectX + outerPadding
        button.y = outerRectY + outerPadding + (baseHeight * 1.2 + margin) * (i - 1)

        button.width = baseWidth * 1.2
        button.height = baseHeight * 1.2

        local fillColor = {0.7, 0.1, 0.5} -- Pink fill color
        local outlineColor = {0.6, 0.4, 1} -- Light pink outline color

        drawRoundedRectWithOutline(button.x, button.y, button.width, button.height, borderRadius, fillColor, outlineColor, 4)
        
        local textW = love.graphics.getFont():getWidth(button.text)
        local textH = love.graphics.getFont():getHeight(button.text)
        
        if button.now then
            drawRoundedRectWithOutline(button.x, button.y, button.width, button.height, borderRadius, {0.8, 0.8, 1}, {0.8, 0.8, 1}, 4) -- Light blue fill color for hover effect
        end

        love.graphics.setColor(1, 1, 1, 1) -- White text color
        love.graphics.print(button.text, button.x + (button.width / 2) - (textW / 2), button.y + (button.height / 2) - (textH / 2))
    end
end


return MainMenu