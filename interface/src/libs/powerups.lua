local powerups = {}
local world 
local powerupsList = {}

local coinSprite
function powerups.init(physicsWorld)
    world = physicsWorld
    coinSprite = love.graphics.newImage('sprites/coin.png')
end

function powerups.create(x, y)
    local powerUp = world:newRectangleCollider(x, y, 50, 50)
    powerUp:setType('static')
    powerUp:setCollisionClass("Powerup")
    powerUp.isPowerUp = true
    powerupsList[#powerupsList+1] = powerUp
    return powerUp
end

function powerups.update(dt, moveSpeed)
    for i, collider in ipairs(powerupsList) do
        if collider.isPowerUp then
            local x, y = collider:getPosition()
            collider:setPosition(x + moveSpeed * dt, y)

            -- Optionally, remove the powerup if it's off-screen
            if x < -100 then
                collider:destroy()
                table.remove(powerupsList, i)
            end
        end
    end
end

function powerups.handleCollisions(playerCollider)
    for i = #powerupsList, 1, -1 do 
        local powerUp = powerupsList[i]
        if playerCollider:enter('Powerup') then
            local collision_data = playerCollider:getEnterCollisionData('Powerup')
            if collision_data.collider == powerUp then
                uiHelperInst:addCoin()
                powerUp:destroy() 
                table.remove(powerupsList, i)  
            end
        end
    end
end

function powerups.draw()
    for _, powerUp in ipairs(powerupsList) do
        local x, y = powerUp:getPosition()
        local scaleX, scaleY = 0.08, 0.08
        love.graphics.setColor(1, 1, 1)

        love.graphics.draw(coinSprite, x, y, 0, scaleX, scaleY, coinSprite:getWidth() / 2, coinSprite:getHeight() / 2)
    end
end

return powerups