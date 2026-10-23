local exp={}

function exp:enter()
    self.map=require("map")
    self.map:init()
    self.selectedTile=1
    self.mouse={x=0,y=0}
    self.mode="draw"

    self.name="test"

    shove.createLayer("map")

    local data=love.filesystem.read("test.json")
    if data then
        print("map exists!")
        self.map.data=json.decode(data)
    else
        print("no map twt")
    end
end

function exp:update(dt)
    local inside,mx,my=shove.mouseToViewport()
    self.mouse.x,self.mouse.y=mx,my
    if inside then
        if self.mode=="draw" then
            if love.mouse.isDown(1) then
                local col,row=math.floor(mx/8)+1,math.floor(my/8)+1
                self.map:set(col,row,self.selectedTile)
            elseif love.mouse.isDown(2) then
                local col,row=math.floor(mx/8)+1,math.floor(my/8)+1
                self.map:set(col,row,0)
            end
        end
    end
end

function exp:draw()
    shove.beginDraw()
        shove.beginLayer("map")
            if self.mode=="draw" then
                self.map:draw()

                lg.setColor(1,1,1,0.4)
                local col,row=math.floor(self.mouse.x/8),math.floor(self.mouse.y/8)
                self.map:drawTile(self.selectedTile,col*8,row*8)
                lg.setColor(1,1,1,1)
            end

            if self.mode=="select" then
                for i=0,#self.map.sheet.quads-1 do
                    self.map:drawTile(i,(i%(conf.gw/8))*8,math.floor(i/(conf.gw/8))*8)
                end
                lg.rectangle("line",(self.selectedTile%(conf.gw/8))*8+0.5,math.floor(self.selectedTile/(conf.gw/8))*8+0.5,7,7)
            end
        shove.endLayer()
    shove.endDraw()
end

function exp:keypressed(k)
    if k=="s" then
        self.mode="select"
    end
    if k=="d" then
        self.mode="draw"
    end
    if k=="c" then
        self.map:clear()
    end
    if k=="e" then
        local data=json.encode(self.map.data)
        love.filesystem.write("test.json",data)
    end
end

function exp:mousepressed(x,y,b)
    local inside,mx,my=shove.screenToViewport(x,y)
    if inside and b==1 then
        if self.mode=="select" then
            local xx,yy=math.floor(mx/8),math.floor(my/8)
            local col=conf.gw/8
            local sel=yy*col+xx
            if xx>=0 and xx<col and yy>=0 and sel<#self.map.sheet.quads then
                self.selectedTile=sel
                print(sel)
            end
        end
    end
end

return exp