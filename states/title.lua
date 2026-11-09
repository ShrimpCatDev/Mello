local title={}

function title:init()
    shove.createLayer("title")
    self.letters={
        560,561,562,563,564
    }

    self.options=require("utils/settings")

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
    self.menu:add(
        "Options",
        function()
            self.options:init()
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
        self.menu:add(
            "Start from level",
            function()
                self.textInput:spawn(function(output)
                    gs.switch(states.level,tonumber(output))
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
    if not self.textInput.open and not self.options.active then
        self.menu:update(dt)
    end
    self.options:update(dt)
end

function title:draw()
    shove.beginDraw()
        shove.beginLayer("map")
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

            lg.setColor(1,1,1,1)
            local colors={
                color("#d01f6c"),
                color("#ff921b"),
                color("#81ca05"),
                color("#1a98e0"),
                color("#f8fdff")
            }

            for i=0,#colors-1 do
                lg.setColor(colors[i+1])
                local total=(#self.letters*9)-1
                local t=love.timer.getTime()+i*0.2
                for k,v in ipairs(self.letters) do
                    local p=k-1
                    sheet:draw(v,(p*9)+(conf.gw/2)-(total/2)+(math.sin(t*2+(k*0.4))*3),32+(math.cos(t*4+(k*0.8))*3)+#colors-1-(i*0.5))
                end
            end

            self.menu:draw()
            self.textInput:draw()

            local s=version
            lg.print(s,conf.gw-lg.getFont():getWidth(s)-1,conf.gh-lg.getFont():getHeight(s)-1)

            local s="ShrimpCat"
            lg.print(s,1,conf.gh-lg.getFont():getHeight(s)-1)

            self.options:draw()

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