local exp={}

function exp:enter()
    self.map=require("map")
    self.map:init()
    self.selectedTile=1
    self.mouse={x=0,y=0}

    shove.createLayer("map")
end

function exp:update(dt)
    local inside,mx,my=shove.mouseToViewport()
    self.mouse.x,self.mouse.y=mx,my
    if inside and love.mouse.isDown(1) then
        local col,row=math.floor(mx/8)+1,math.floor(my/8)+1
        self.map:set(col,row,self.selectedTile)
    end
end

function exp:draw()
    shove.beginDraw()
        shove.beginLayer("map")
            self.map:draw()

            lg.setColor(1,1,1,0.4)
            local col,row=math.floor(self.mouse.x/8),math.floor(self.mouse.y/8)
            self.map:drawTile(self.selectedTile,col*8,row*8)
            lg.setColor(1,1,1,1)
        shove.endLayer()
    shove.endDraw()
end

function exp:keypressed(k)
    if k=="up" then
        self.selectedTile=self.selectedTile+1
    end
    if k=="down" then
        self.selectedTile=self.selectedTile-1
    end
end

return exp