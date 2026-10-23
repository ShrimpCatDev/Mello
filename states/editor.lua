local exp={}

function exp:enter()
    self.map=require("map")
    self.map:init()

    shove.createLayer("map")
end

function exp:update(dt)
    local inside,mx,my=shove.mouseToViewport()
    if inside and love.mouse.isDown(1) then
        local col,row=math.floor(mx/8)+1,math.floor(my/8)+1
        self.map:set(col,row,1)
    end
end

function exp:draw()
    shove.beginDraw()
        shove.beginLayer("map")
            self.map:draw()
        shove.endLayer()
    shove.endDraw()
end

return exp