local level={}

function level.filter(item,other)
    if other.flag then
        if other.flag==1 then
            return "slide"
        elseif other.flag==2 and item.vy>=0 and other.y>=item.prevY+item.h then
            return "slide"
        else
            return nil
        end
    end
    return "cross"
end

function level:init()
    shove.createLayer("terrain")
    shove.createLayer("ui")
end

function level:initLevel(level)
    --remove stuffs
    for k,v in pairs(self.world:getItems()) do
        self.world:remove(v)
    end

    --init map
    local l=level or 1
    self.map=require("map")
    self.map:init()
    self.map:load("levels/level"..l..".json")
    self.map:initBump(self.world)
    self.map.oy=0

    --init enemies
    self.enemies=nil
    self.enemies=require.tree('entity/enemies')
    self.active=false
    self.drawOpacity=0
    for k,v in pairs(self.enemies) do
        v:init(self)
    end
    for k,v in ipairs(self.map.data.sprites) do
        local e=self.enemies[v.id]
        if e then
            e:new(v.x,v.y)
        end
    end

    --init player
    local spawnX,spawnY=8,conf.gh-18
    for _,v in ipairs(self.map.data.sprites or {}) do
        if v.id=="player" then
            spawnX,spawnY=v.x+1,v.y+1
        end
    end
    self.player:init(self,spawnX,spawnY)

    --init draw stuff
    self.map.oy=-conf.gh
    self.drawOpacity=0
    timer.tween(2,self.map,{oy=0},"in-linear",function()
        timer.tween(0.2,self,{drawOpacity=1},"out-cubic")
        timer.after(0.5,function()
            self.active=true
        end)
    end)
end

function level:enter()
    local bump=require('lib.bump')
    self.world=bump.newWorld(8)
    self.world.gravity=400

    self.player=require('entity.player')

    self.spriteCanvas=lg.newCanvas(conf.gw,conf.gh)

    self:initLevel(1)

    self.shadow=lg.newCanvas(conf.gw,conf.gh)
    self.score=0

    self.bar={y=0,w=conf.gw,h=7,dy=0}
    self.bar.canvas=lg.newCanvas(self.bar.w,self.bar.h)
    self.bar.opacity=1
    self.bar.dopacity=self.bar.opacity
end

function level:update(dt)
    self.map:update(dt)
    if self.active then
        self.player:update(dt)
        for k,v in pairs(self.enemies) do
            v:update(dt)
        end
    end
    if self.player.y<=conf.gh/4 then
        self.bar.opacity=0
    else
        self.bar.opacity=1
    end
    self.bar.dopacity=math.lerp(self.bar.dopacity,self.bar.opacity,16,dt)
end

function level:draw()
    lg.setCanvas(self.spriteCanvas)
        lg.clear()
        for k,v in pairs(self.enemies) do
            v:draw()
        end
        self.player:draw()
    lg.setCanvas(self.shadow)
        lg.clear()
        lg.setColor(1,1,1,1)
        self.map:draw()

        lg.setColor(1,1,1,self.drawOpacity)
        lg.draw(self.spriteCanvas)
    lg.setCanvas()

    shove.beginDraw()
        shove.beginLayer("terrain")
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
            lg.setColor(0,0,0,1)
            lg.draw(self.shadow,1,1)
            lg.setColor(1,1,1,1)
            lg.draw(self.shadow)
        shove.endLayer()

        lg.setCanvas(self.bar.canvas)
            lg.setColor(0,0,0,1)
                lg.rectangle("fill",0,0,self.bar.w,self.bar.h)
            lg.setColor(1,1,1,1)
            lg.print("Score: "..self.score,1,1)
        lg.setCanvas()

        shove.beginLayer("ui")
            lg.setColor(1,1,1,self.bar.dopacity)
            lg.draw(self.bar.canvas)
        shove.endLayer()
    shove.endDraw()
end

function level:keypressed(k)
    if k=="escape" then
        gs.switch(states.title)
    end
end

return level