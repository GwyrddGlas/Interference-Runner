local enemies = {}
local world
local enemyList = {} 

local bombImage
function enemies.init(physicsWorld)
    world = physicsWorld
    bombImage = love.graphics.newImage('sprites/bomb.png')
end

function enemies.create(x, y)
    local enemy = world:newRectangleCollider(x, y, 50, 50)
    enemy:setType("static")
    enemy:setCollisionClass("Enemy")
    enemy.isEnemy = true
    enemyList[#enemyList+1] = enemy
    return enemy
end

function enemies.handleCollisions(playerCollider)
    for i = #enemyList, 1, -1 do 
        local enemy = enemyList[i]
        if playerCollider:enter('Enemy') then
            local collision_data = playerCollider:getEnterCollisionData('Enemy')
            if collision_data.collider == enemy then
                uiHelperInst:loseHeart()
                enemy:destroy() 
                table.remove(enemyList, i)  
            end
        end
    end
end

function enemies.update(dt, moveSpeed)
    for i, collider in ipairs(enemyList) do
        if collider.isEnemy then
            local x, y = collider:getPosition()
            collider:setPosition(x + moveSpeed * dt, y)

            if x < -100 then  
                collider:destroy() 
                table.remove(enemyList, i) 
            end
        end
    end
end

function enemies.draw()
    for _, enemy in ipairs(enemyList) do
        local x, y = enemy:getPosition()
        local scaleX, scaleY = 0.2, 0.2
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(bombImage, x, y, 0, scaleX, scaleY, bombImage:getWidth() / 2, bombImage:getHeight() / 2)
    end
end


return enemies