local settings = {}

local buttons = {}
local sliders = {}
local font

local function newButton(text, fn)
    return {
        text = text,
        fn = fn,
        now = false,
        last = false
    }
end

local function newSlider(title, min, max, value, fn)
    return {
        title = title,
        min = min,
        max = max,
        value = value,
        fn = fn,
        dragging = {
            active = false,
            diffX = 0
        }
    }
end

local backgroundMusic = love.audio.newSource("music/Retrowave-Music.ogg", "stream")
backgroundMusic:setVolume(0.3)
backgroundMusic:setLooping(true)
backgroundMusic:play() 


local function addMenuButtons()
    buttons = {}
    sliders = {}

    table.insert(sliders, newSlider("Music Volume", 0, 1, 0.5, function(value)
        backgroundMusic:setVolume(value) 
    end))

   --table.insert(buttons, newButton("Some Button", function(value)
   --    -- Code to adjust music volume, e.g., love.audio.setVolume(value)
   --    gameSettings.musc = value*100
   --    print("Music Volume: " .. value * 100)
   --end))

end

local function drawRoundedRectWithOutline(x, y, width, height, borderRadius, fillColor, outlineColor, lineWidth)
    love.graphics.setColor(fillColor)
    love.graphics.rectangle("fill", x, y, width, height, borderRadius, borderRadius)

    love.graphics.setColor(outlineColor)
    love.graphics.setLineWidth(lineWidth or 2)
    love.graphics.rectangle("line", x, y, width, height, borderRadius, borderRadius)

    love.graphics.setColor(1, 1, 1, 1)
end

local function drawSlider(s, x, y, w, h)
    -- Draw the slider track
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", x, y, w, h)
    
    -- Draw the slider button
    local sliderPos = x + (w - h) * ((s.value - s.min) / (s.max - s.min))
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", sliderPos, y + h / 2, h / 2)
    
    love.graphics.setColor(1, 1, 1)
end

function settings:enter()
    font = love.graphics.newFont(18) 
    addMenuButtons()
end

function settings:update(dt)
    local mx, my = love.mouse.getPosition()
    local buttonWidth = 200
    local buttonHeight = 50
    local sliderWidth = 200 
    local sliderHeight = 20
    local margin = 16
    local cursorY = love.graphics.getHeight() / 2 - ((buttonHeight + margin) * #buttons + (sliderHeight + margin) * #sliders) / 2

    for i, s in ipairs(sliders) do
        local bx = love.graphics.getWidth() / 2 - sliderWidth / 2
        local by = cursorY + (i - 1) * (buttonHeight + margin) + #buttons * (buttonHeight + margin)

        local sliderButtonX = bx + (sliderWidth - sliderHeight) * ((s.value - s.min) / (s.max - s.min))

        local detectionPadding = 10 
        local buttonHalfWidth = sliderHeight / 2 + detectionPadding
        local buttonHalfHeight = sliderHeight / 2 + detectionPadding

        local mouseOverSliderButton = mx > (sliderButtonX - buttonHalfWidth) and mx < (sliderButtonX + buttonHalfWidth) and my > (by - buttonHalfHeight) and my < (by + sliderHeight + buttonHalfHeight)

        local mousePressed = love.mouse.isDown(1)

        if mousePressed and mouseOverSliderButton then
            s.dragging.active = true
            s.dragging.diffX = mx - sliderButtonX
        elseif not mousePressed then
            s.dragging.active = false
        end

        if s.dragging.active then
            s.value = math.clamp(s.min, s.max, (mx - bx - s.dragging.diffX - sliderHeight / 2) / (sliderWidth - sliderHeight))
            if s.fn then s.fn(s.value) end
        end
    end
end

function math.clamp(min, max, val)
    return math.max(min, math.min(max, val))
end

function settings:draw()
    local buttonWidth = 200
    local buttonHeight = 50
    local sliderWidth = 200 
    local sliderHeight = 20
    local margin = 16
    local totalHeight = (buttonHeight + margin) * #buttons - margin
    local cursorY = love.graphics.getHeight() / 2 - totalHeight / 2

    for i, s in ipairs(sliders) do
        local bx = love.graphics.getWidth() / 2 - sliderWidth / 2
        local by = cursorY + (i - 1) * (buttonHeight + margin) + #buttons * (buttonHeight + margin) - font:getHeight() - margin / 2

        -- Display the slider's title and dynamically append the current value
        love.graphics.setColor(1, 1, 1)  -- Title color
        local sliderTitle = s.title .. ": " .. math.floor(s.value * 100)
        love.graphics.print(sliderTitle, bx, by - font:getHeight())

        -- Draw the slider below the title
        by = by + font:getHeight() + margin / 2
        drawSlider(s, bx, by, sliderWidth, sliderHeight)
    end

    love.graphics.setFont(font)
    for i, button in ipairs(buttons) do
        button.last = button.now

        local bx = love.graphics.getWidth() / 2 - buttonWidth / 2
        local by = cursorY + (i - 1) * (buttonHeight + margin)

        local mx, my = love.mouse.getPosition()
        local hot = mx > bx and mx < bx + buttonWidth and
                    my > by and my < by + buttonHeight

        button.now = love.mouse.isDown(1)
        if hot then
            drawRoundedRectWithOutline(bx, by, buttonWidth, buttonHeight, 5, {0.8, 0.8, 0.9}, {0.5, 0.5, 0.5}, 3)
            if button.now and not button.last then
                button.fn()
            end
        else
            drawRoundedRectWithOutline(bx, by, buttonWidth, buttonHeight, 5, {0.7, 0.7, 0.8}, {0.5, 0.5, 0.5}, 3)
        end

        love.graphics.setColor(0, 0, 0)
        love.graphics.print(button.text, bx + buttonWidth / 2 - font:getWidth(button.text) / 2, by + buttonHeight / 2 - font:getHeight() / 2)

        love.graphics.setColor(1, 1, 1)
    end
end

return settings
