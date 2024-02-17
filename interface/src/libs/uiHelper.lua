local UIHelper = {}
UIHelper.__index = UIHelper

function UIHelper.new()
    local self = setmetatable({}, UIHelper)
    self.coinsCollected = 0
    self.coinSprite = love.graphics.newImage('sprites/coin.png') 
    self.hearts = 3 
    self.heartSprite = love.graphics.newImage('sprites/heart.png') 
    return self
end

function UIHelper:addCoin()
    self.coinsCollected = self.coinsCollected + 1
end

function UIHelper:loseHeart()
    if self.hearts > 0 then
        self.hearts = self.hearts - 1
    end
end

function UIHelper:gainHeart()
    self.hearts = self.hearts + 1  
end

function UIHelper:update(dt)

end

function UIHelper:draw()
    local scale = 0.05 
    local screenWidth = love.graphics.getWidth()
    local heartWidth, heartHeight = self.heartSprite:getDimensions()

    love.graphics.setColor(1, 1, 1) 
    love.graphics.draw(self.coinSprite, 10, 10, 0, scale, scale)  
    love.graphics.print("x " .. tostring(self.coinsCollected), 10 + heartWidth * scale + 5, 20) 

    -- Draw hearts
    for i = 1, self.hearts do
        local heartX = screenWidth - (heartWidth * scale + 5) * i  
        love.graphics.draw(self.heartSprite, heartX, 10, 0, scale, scale)  
    end
end

return UIHelper