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
    --draw previous level to canvas if need be
    if not self.first then
        lg.setCanvas(self.levelCanvas)
            lg.clear()
            self.map:draw()
        lg.setCanvas()
    end
    self.particles.clear()

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

    --init food
    self.items=nil
    self.items=require("entity.items")
    self.items:init(self)

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
    timer.tween(1.5,self.map,{oy=0},"in-out-back",function()
        timer.tween(0.2,self,{drawOpacity=1},"out-cubic")
        timer.after(0.5,function()
            self.active=true
        end)
    end)

    self.first=false
    self.levelDone=false
end

function level:gameOver()
    self.active=false
    self.over=true

    timer.script(function(wait)
        self.music:stop()
        timer.tween(0.5,self.fadeDeath,{opacity=1},"in-cubic")
        wait(0.2)
        timer.tween(0.8,self.player,{x=conf.gw/2-self.player.w/2,y=conf.gh/2-self.player.h/2},"out-cubic",function()
            self.player.anim.current=self.player.anim.die
        end)
        wait(2)
        assets.music.die:play()
        self.deadAnimDone=true
    end)
    --gs.switch(states.gameover,self.level,self.score)
end

function level:enter(prev,bootLevel)
    local bump=require('lib.bump')
    self.world=bump.newWorld(8)
    self.world.gravity=400

    self.player=require('entity.player')

    self.spriteCanvas=lg.newCanvas(conf.gw,conf.gh)
    self.levelCanvas=lg.newCanvas(conf.gw,conf.gh)

    self.particles=require('entity.particles')
    self.particles.clear()

    self.first=true
    self.levelDone=false
    self.level=bootLevel or 1
    self:initLevel(self.level)

    self.shadow=lg.newCanvas(conf.gw,conf.gh)
    self.score=0

    self.bar={y=0,w=conf.gw,h=7,dy=0}
    self.bar.canvas=lg.newCanvas(self.bar.w,self.bar.h)
    self.bar.opacity=1
    self.bar.dopacity=self.bar.opacity

    self.fadeDeath={opacity=0}
    self.over=false
    self.deadAnimDone=false
    self.music=assets.music.level
    self.music:setLooping(true)
    self.music:stop()
    self.music:play()

    self.fade=require('utils.fade')
    self.fade:init()

    self.fade:fade(0.3,1,0,"#000000")
    self.paused=false
end

function level:countEntities()
    local num=0
    for k,v in pairs(self.enemies) do
        for l,j in pairs(v.items) do
            num=num+1
        end
    end

    for k,v in pairs(self.items.items) do
        num=num+1
    end

    return num
end

function level:update(dt)
    self.map:update(dt)
    if self.active and not self.paused then
        self.items:update(dt)
        self.player:update(dt)
        for k,v in pairs(self.enemies) do
            v:update(dt)
        end
        self.particles.update(dt)

        if self:countEntities()<1 and not self.levelDone then
            self.levelDone=true
            self.level=self.level+1
            if not love.filesystem.read("levels/level"..self.level..".json") then
                self.level=1
            end

            timer.after(0.5,function()
                self:initLevel(self.level)
            end)
            print("done!")
        end
    elseif self.over then
        self.player.anim.current:update(dt)
        if self.deadAnimDone then
            if input:pressed("jump") then
                self.fade:fade(0.4,0,1,"#000000",function()
                    self.deadAnimDone=false
                    gs.switch(states.level,self.level)
                end)
            end
            if input:pressed("shoot") then
                self.fade:fade(0.4,0,1,"#000000",function()
                    gs.switch(states.title)
                end)
            end
        end
    end

    if input:pressed("pause") and self.active then
        self.paused=not self.paused

        if self.paused then
            self.music:pause()
        else
            self.music:play()
        end
    end

    if self.paused and not self.fade.fading then
        if input:pressed("shoot") then
            self.music:stop()
            self.fade:fade(0.4,0,1,"#000000",function()
                gs.switch(states.title)
            end)
        end
    end
end

function level:draw()
    --drawing the sprites canvas to draw to the shadow canvas to draw to the terrain layer to draw to the screen TwT
    lg.setCanvas(self.spriteCanvas)
        lg.clear()
        for k,v in pairs(self.enemies) do
            v:draw()
        end
        self.items:draw()
        self.player:draw()
    lg.setCanvas(self.shadow)
        lg.clear()
        lg.setColor(1,1,1,1)
        self.map:draw()
        lg.draw(self.levelCanvas,0,self.map.oy+conf.gh)

        local o=math.floor(self.drawOpacity*4+0.5)/4
        lg.setColor(1,1,1,o)
        lg.draw(self.spriteCanvas)
        self.particles.draw()
    lg.setCanvas()

    shove.beginDraw()
        shove.beginLayer("terrain")
            --colors for the bg
            local colors={
                {0.05,0.05,0.1},
                {0.1,0.1,0.15}
            }

            --cool scrolling background checkerboard yes
            for y=-1,(conf.gh/8) do
                for x=-1,(conf.gw/8) do
                    lg.setColor(colors[(x+y)%2+1])
                    local xx=(x*8)+(love.timer.getTime()*4)%8
                    local yy=(y*8)+(love.timer.getTime()*4)%8
                    lg.rectangle("fill",xx,yy,8,8)
                end
            end

            --shadow for the map and sprites
            lg.setColor(0,0,0,1)
            lg.draw(self.shadow,1,1)
            lg.setColor(1,1,1,1)
            lg.draw(self.shadow)
        shove.endLayer()

        lg.setCanvas(self.bar.canvas)
            --le bar
            lg.setColor(0,0,0,1)
                lg.rectangle("fill",0,0,self.bar.w,self.bar.h)
            lg.setColor(1,1,1,1)

            --score stats
            lg.setColor(color("#f7f1e4"))
            local t="Score: "..self.score
            local font=lg.getFont()
            lg.print(t,self.bar.w-font:getWidth(t),1)

            --hp bar
            local t="HP:"
            local o=font:getWidth(t)
            lg.print(t,1,1)

            local w,h=3,self.bar.h-2
            
            --empty bar part
            lg.setColor(color("#5f5666"))
            for i=0,self.player.maxHp-1 do
                lg.rectangle("fill",o+(i*(w+1))+1,1,w,h)
            end

            --full bar part
            lg.setColor(color("#f7f1e4"))
            for i=0,self.player.hp-1 do
                lg.rectangle("fill",o+(i*(w+1))+1,1,w,h)
            end
        
            lg.setColor(1,1,1,1)
        lg.setCanvas()
        
        --ui layer
        shove.beginLayer("ui")
            --ngl i forgot what this was for
            lg.setColor(1,1,1,self.bar.dopacity)
            lg.draw(self.bar.canvas)

            local o=math.floor(self.fadeDeath.opacity*4+0.5)/4
            lg.setColor(0,0,0,o)
            lg.rectangle("fill",0,0,conf.gw,conf.gh)
            lg.setColor(1,1,1,1)

            --pause screen
            if self.paused then
                lg.setColor(0,0,0,0.5)
                lg.rectangle("fill",0,0,conf.gw,conf.gh)
                lg.setColor(color("#f7f1e4"))
                local t="Paused"
                local font=lg.getFont()
                lg.print(t,conf.gw/2-font:getWidth(t)/2,conf.gh/2-font:getHeight(t)/2-4)

                local t="Press X to return to title"
                lg.print(t,conf.gw/2-font:getWidth(t)/2,conf.gh/2-font:getHeight(t)/2+4)
            end

            --debug fps, ignore :3
            if conf.debug then
                lg.setColor(1,1,1,1)
                lg.print(love.timer.getFPS(),1,9)
            end

            --Game over stuff
            if self.over then
                self.player:draw()
                if self.deadAnimDone then
                    lg.setColor(1,1,1,1)
                    local f=lg.getFont()
                    
                    lg.setColor(color("#f7f1e4"))
                    local t="Game Over"
                    lg.print(t,conf.gw/2-f:getWidth(t)/2,self.player.y-f:getHeight()-3)

                    lg.setColor(color("#b5a9a3"))
                    local t="Score: "..self.score
                    lg.print(t,conf.gw/2-f:getWidth(t)/2,self.player.y+self.player.h+2)

                    lg.setColor(color("#5f5666"))
                    local t="Press Z to continue/X to quit"
                    lg.print(t,conf.gw/2-f:getWidth(t)/2,conf.gh-f:getHeight())
                end
            end

            --the cool fade lol hi lol
            self.fade:draw()
        shove.endLayer()
    shove.endDraw()
end

function level:keypressed(k)
    if conf.debug then
        if k=="k" then
            for k,v in pairs(self.enemies) do
                for l,j in pairs(v.items) do
                    j.kill=true
                end
            end
        end
        if k=="p" then
            self.player:damage(10000)
        end
    end
end

function level:leave()
    love.audio.stop()
    timer.clear()
end

return level