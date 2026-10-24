local level={}

function level:init()
    shove.createLayer("terrain")
end

function level:enter()
    local bump=require('lib.bump')
    self.world=bump.newWorld(8)
    self.world.gravity=400

    self.player=require('entity.player')
    self.player:init(self,8,8)

    self.map=require("map")
    self.map:init()
    self.map:load("levels/level1.json")
    self.map:initBump(self.world)
end

function level:update(dt)
    self.player:update(dt)
end

function level:draw()
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

            lg.setColor(1,1,1,1)
            self.map:draw()

            self.player:draw()
        shove.endLayer()
    shove.endDraw()
end

return level