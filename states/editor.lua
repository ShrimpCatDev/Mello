local exp={}

function exp:init()
    shove.createLayer("map")
    
end

function exp:enter(prev,name)
    self.map=require("map")
    self.map:init()
    self.selectedTile=1
    self.selectedFlag=1
    self.mouse={x=0,y=0}

    self.modes={"draw","select"}
    self.selectedMode=1
    self.mode=self.modes[self.selectedMode]

    self.name=name

    self.bar={
        y=-8,
        icons={
            558,
            559
        },
        modes={
            "terrain","flags"
        },
        mode=1
    }

    local data=love.filesystem.read(self.name..".json")
    if data then
        print("map exists!")
        self.map.data=json.decode(data)
    end
end

function exp:update(dt)
    local inside,mx,my=shove.mouseToViewport()
    self.mouse.x,self.mouse.y=mx,my
    if inside then
        local col,row=math.floor(mx/8)+1,math.floor(my/8)+1
        if self.bar.mode==1 then
            if self.mode=="draw" then
                if love.mouse.isDown(1) then
                    self.map:set(col,row,self.selectedTile)
                elseif love.mouse.isDown(2) then
                    self.map:set(col,row,0)
                end
            end
        else
            if love.mouse.isDown(1) then
                self.map:flag(col,row,self.selectedTile)
            elseif love.mouse.isDown(2) then
                self.map:flag(col,row,0)
            end
        end
    end
end

function exp:draw()
    shove.beginDraw()
        shove.beginLayer("map")
            if self.mode=="draw" then
                local colors={
                    {0.05,0.05,0.1},
                    {0.1,0.1,0.15}
                }

                for y=-1,(conf.gh/8) do
                    for x=-1,(conf.gw/8) do
                        lg.setColor(colors[(x+y)%2+1])
                        local xx=(x*8)+(love.timer.getTime()*4)%8
                        local yy=(y*8)+(love.timer.getTime()*4)%8
                        lg.rectangle("fill",xx,yy,8,8)
                    end
                end

                lg.setColor(1,1,1,1)
                self.map:draw()

                lg.setColor(1,1,1,0.4)
                local x,y=math.floor(self.mouse.x/8)*8,math.floor(self.mouse.y/8)*8

                if self.bar.modes[self.bar.mode]=="terrain" then
                    self.map:drawTile(self.selectedTile,x,y)
                else

                end
                lg.setColor(1,1,1,1)

                lg.push()
                lg.translate(0,self.bar.y)
                    lg.setColor(0,0,0,1)
                    lg.rectangle("fill",0,0,conf.gw,8)
                    lg.setColor(1,1,1,1)
                    self.map:drawTile(self.bar.icons[self.bar.mode],0,0)
                    lg.print(self.bar.modes[self.bar.mode],10,1)
                lg.pop()

                if self.bar.mode==2 then
                    self.map:drawFlags()
                end
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
    if k=="c" then
        self.map:clear()
    end
    if k=="tab" then
        self.bar.mode=self.bar.mode+1
        self.bar.mode=((self.bar.mode-1)%#self.bar.modes)+1
        print(self.bar.mode)

        timer.tween(0.2,self.bar,{y=0},"out-cubic",function()
            timer.after(0.8,function()
                timer.tween(0.2,self.bar,{y=-8},"out-cubic")
            end)
        end)
    end
    if k=="space" and self.bar.modes[self.bar.mode]=="terrain" then
        self.selectedMode=self.selectedMode+1
        self.selectedMode=((self.selectedMode-1)%#self.modes)+1
        self.mode=self.modes[self.selectedMode]
    end
    if k=="s" and love.keyboard.isDown("lctrl") then
        local data=json.encode(self.map.data)
        love.filesystem.write(self.name..".json",data)
        print("saved "..self.name..".json")
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