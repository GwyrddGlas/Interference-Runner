local windfield = require("libs/windfield")
local enemies = require("libs/enemies")
local powerups = require("libs/powerups")
local uiHelper = require("libs/uiHelper")

local InGame = {
    delayAfterEnter = 0.5,
    world = nil,
    topCollision = nil,
    characterX = 100, 
    characterY = 0,
    jumpHeight = -1700,
    gravity = 140,
    moveSpeed = -300,  -- Speed at which the world moves towards the player
    floorSections = {}
}

local floorX, floorY
uiHelperInst = uiHelper.new()

function InGame:enter()
    self.world = windfield.newWorld(0, self.gravity, false)

    local screenHeight = love.graphics.getHeight()
    local rectHeight = screenHeight / 4

    floorX = 0
    floorY = screenHeight - rectHeight + 30

    -- Create the initial floor section
    self:generateFloorSection(floorX, floorY, love.graphics.getWidth(), 10)  -- Initial floor covering the screen width with visible height

    self.characterY = floorY - 100

    self.world:addCollisionClass('Player')
    self.world:addCollisionClass('Enemy')
    self.world:addCollisionClass('Powerup')

    self.characterCollider = self.world:newRectangleCollider(self.characterX, self.characterY, 50, 100)  -- Adjusted collider size to match character size
    self.characterCollider:setRestitution(0)  -- Prevent bouncing
    self.characterCollider:setType('dynamic')
    self.characterCollider:setFixedRotation(true)  -- Prevent the character from rotating
    self.characterCollider:setCollisionClass('Player')

    enemies.init(self.world)
    powerups.init(self.world)

    self.speedIncreaseRate = 10    -- How much to increase the speed by
    self.speedIncreaseInterval = 5 -- How often to increase the speed (seconds)
    self.timeSinceLastIncrease = 0

    self.backgroundImage = love.graphics.newImage('sprites/background.png')  -- Replace with the actual path to your image
end

function InGame:handleEnemyCollision(enemyCollider)
    for i, enemy in ipairs(enemyList) do
        if enemy == enemyCollider then
            enemy:destroy() 
            table.remove(enemyList, i)  
            break  
        end
    end
end

function InGame:generateFloorSection(x, y, width, height)
    local floorSection = self.world:newRectangleCollider(x, y - height / 2, width, height)
    floorSection:setType('static')

    table.insert(self.floorSections, {collider = floorSection, width = width, height = height})
end

function InGame:update(dt)
    self.world:update(dt)

    for _, sectionData in ipairs(self.floorSections) do
        local sectionCollider = sectionData.collider
        local x, y = sectionCollider:getPosition()
        sectionCollider:setPosition(x + self.moveSpeed * dt, y)
    end

    local _, vy = self.characterCollider:getLinearVelocity()
    if love.keyboard.isDown("up") and vy == 0 then
        self.characterCollider:applyLinearImpulse(0, self.jumpHeight)
    end

    local lastSectionData = self.floorSections[#self.floorSections]
    local lastSection = lastSectionData.collider
    local lastX, _ = lastSection:getPosition()

    if (lastX + lastSectionData.width / 2) < love.graphics.getWidth() then
        self:generateFloorSection(lastX + lastSectionData.width / 2, floorY, 480, 10)

        local rand = math.random(1, 5)

        if rand == 3 then
            enemies.create(lastX, floorY-50) --tmp enemies 
        end
        if rand == 2 then
            powerups.create(lastX, floorY-70) --tmp powerups 
        end
    end

    self.timeSinceLastIncrease = self.timeSinceLastIncrease + dt
    
    -- Check if it's time to increase the speed
    if self.timeSinceLastIncrease >= self.speedIncreaseInterval then
        self.moveSpeed = self.moveSpeed - self.speedIncreaseRate -- Negative because speed is a negative value
        self.timeSinceLastIncrease = 0 -- Reset the timer
        print("Speed increased to: " .. self.moveSpeed) -- For debugging
    end

    enemies.handleCollisions(self.characterCollider)
    powerups.handleCollisions(self.characterCollider)

    enemies.update(dt, self.moveSpeed)
    powerups.update(dt, self.moveSpeed)
    uiHelperInst:update(dt)

    -- Remove off-screen floor sections
    -- self:cleanupOffscreenElements()
end

function InGame:cleanupOffscreenElements()
    for i = #self.floorSections, 1, -1 do
        local sectionData = self.floorSections[i]
        local sectionCollider = sectionData.collider
        local x, _ = sectionCollider:getPosition()

        -- Check if the section's right edge is off-screen to the left
        if (x - sectionData.width ) < 0 then
            sectionCollider:destroy()
            table.remove(self.floorSections, i)
        end
    end
end

local function drawFloor()
    for i, sectionData in ipairs(InGame.floorSections) do
        local sectionCollider = sectionData.collider
        local x, y = sectionCollider:getPosition()
        local width = sectionData.width
        local height = sectionData.height

        love.graphics.setColor(1 - (i * 0.1 % 1), 0.4, 0.4 + (i * 0.1 % 1))
        love.graphics.rectangle("fill", x - width / 2, y - height / 2, width, height)

       -- -- Draw section index for debugging
       -- love.graphics.setColor(1, 1, 1) 
       -- love.graphics.print("Section " .. tostring(i), x - width / 2, y - 10)
    end
end

local function drawCharacter()
    local x, y = InGame.characterCollider:getPosition()
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", x - 25, y - 50, 50, 100)
end

function InGame:draw()
    love.graphics.draw(self.backgroundImage, 0, 0, 0, love.graphics.getWidth() / self.backgroundImage:getWidth(), love.graphics.getHeight() / self.backgroundImage:getHeight())

    drawFloor()
    enemies.draw()
    powerups.draw()
    drawCharacter()
    uiHelperInst:draw()
    
   -- self.world:draw()
end

return InGame
