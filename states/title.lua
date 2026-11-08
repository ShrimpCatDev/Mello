local title={}

function title:init()
    shove.createLayer("title")
    self.letters={
        560,561,562,563,564
    }

    self.textInput=require('utils.textInput')
    self.textInput:init()

    self.menu=require("utils.menu")
    self.menu:init(conf.gw/2,conf.gh/2,1)
    self.menu:add(
        "Start",
        function(s)
            self.fade:fade(0.4,0,1,"#000000",function()
                gs.switch(states.level)
            end)
        end
    )
    if conf.debug then
        self.menu:add(
            "Level Editor",
            function()
                self.textInput:spawn(function(output)
                    gs.switch(states.editor, output)
                end)
            end
        )
    end

    self.fade=require('utils.fade')
    self.fade:init()
end

function title:enter()
    self.fade:fade(0.3,1,0,"#000000")
end

function title:update(dt)
    if not self.textInput.open then
        self.menu:update(dt)
    end
end

function title:draw()
    shove.beginDraw()
        shove.beginLayer("map")
            --lg.clear(color("#2da1c4"))
            lg.draw(assets.sprites.cover)
            local total=(#self.letters*9)-1
            local t=love.timer.getTime()
            for k,v in ipairs(self.letters) do
                local p=k-1
                sheet:draw(v,(p*9)+(conf.gw/2)-(total/2)+(math.sin(t*2+(k*0.4))*3),32+(math.cos(t*4+(k*0.8))*3))
            end

            self.menu:draw()
            self.textInput:draw()

            local s=version
            lg.print(s,conf.gw-lg.getFont():getWidth(s)-1,conf.gh-lg.getFont():getHeight(s)-1)

            local s="ShrimpCat"
            lg.print(s,1,conf.gh-lg.getFont():getHeight(s)-1)

            self.fade:draw()
        shove.endLayer()
    shove.endDraw()
end

function title:textinput(k)
    self.textInput:input(k)
end

function title:keypressed(k)
    self.textInput:key(k)
end 

return title