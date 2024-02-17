local GameStateManager = {
    currentState = nil,
    previousState = nil,
}

function GameStateManager:getPreviousState()
    return self.previousState
end

function GameStateManager:getState()
    return self.currentState
end

function GameStateManager:setState(newState)
    self.previousState = self.currentState
    self.currentState = newState

    if self.currentState.enter then
        self.currentState:enter()
    end
end

function GameStateManager:update(dt)
    if self.currentState and self.currentState.update then
        self.currentState:update(dt)
    end
end

function GameStateManager:draw()
    if self.currentState and self.currentState.draw then
        self.currentState:draw()
    end
end

return GameStateManager