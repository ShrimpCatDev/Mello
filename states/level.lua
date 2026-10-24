local level={}

function level:init()
    shove.createLayer("terrain")
end

function level:enter()
    local bump=require('lib.bump')
    self.world=bump.newWorld(8)
    self.world.gravity=400

    self.player=require('entity.player')

    self.map=require("map")
    self.map:init()
    self.map:load("levels/level1.json")
    self.map:initBump(self.world)

    local spawnX,spawnY=8,conf.gh-18
    for _,v in ipairs(self.map.data.sprites or {}) do
        if v.id=="player" then
            spawnX,spawnY=v.x+1,v.y
        end
    end
    self.player:init(self,spawnX,spawnY)

    self.shadow=lg.newCanvas(conf.gw,conf.gh)
end

function level:update(dt)
    self.player:update(dt)
end

function level:draw()
    lg.setCanvas(self.shadow)
        lg.clear()
        lg.setColor(1,1,1,1)
        self.map:draw()

        self.player:draw()
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
    shove.endDraw()
end

function level:keypressed(k)
    if k=="escape" then
        gs.switch(states.title)
    end
end

return level