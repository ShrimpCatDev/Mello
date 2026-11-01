local gameover={}

function gameover:init()
    shove.createLayer("gameover")
end

function gameover:enter(prev,level,score)
    self.level=level or 1
    self.score=score or 0
end

function gameover:update(dt)
    if input:pressed("jump") then
        gs.switch(states.level,self.level)
    end
    if input:pressed("shoot") then
        gs.switch(states.title)
    end
end

function gameover:draw()
    shove.beginDraw()
        shove.beginLayer("gameover")
            lg.print("Game Over TwT\nPress A to Continue\nPress B to Quit",1,1)
        shove.endLayer()
    shove.endDraw()
end

return gameover