local title={}

function title:init()
    shove.createLayer("title")
    self.letters={
        560,561,562,563,564
    }
    self.menu={
        items={"Start","Level Editor"},
        funcs={
            function(s)
                gs.switch(states.level)
            end,
            function(s)
                self.textInput:spawn(function(output)
                    gs.switch(states.editor,output)
                end)
            end
        },
        x=conf.gw/2,
        y=conf.gh/2,
        sel=2
    }
    self.textInput=require('utils.textInput')
    self.textInput:init()
end

function title:enter()
    
end

function title:update(dt)
    if not self.textInput.open then
        if input:pressed("down") then
            self.menu.sel=self.menu.sel+1
        end
        if input:pressed("up") then
            self.menu.sel=self.menu.sel-1
        end
        if self.menu.sel>#self.menu.items then self.menu.sel=1 end
        if self.menu.sel<1 then self.menu.sel=#self.menu.items end
        if input:pressed("jump") then
            local f=self.menu.funcs[self.menu.sel]
            
            f(self)
        end
    end
end

function title:draw()
    shove.beginDraw()
        shove.beginLayer("map")
            lg.clear(color("#2da1c4"))
            local total=(#self.letters*9)-1
            local t=love.timer.getTime()
            for k,v in ipairs(self.letters) do
                local p=k-1
                sheet:draw(v,(p*9)+(conf.gw/2)-(total/2)+(math.sin(t*2+(k*0.4))*3),32+(math.cos(t*4+(k*0.8))*3))
            end

            lg.setColor(color("#f7f1e4"))
            local font=lg.getFont()
            for k,v in ipairs(self.menu.items) do
                local s=v
                if k==self.menu.sel then
                    s="> "..v.." <"
                end
                lg.print(s,self.menu.x-font:getWidth(s)/2,(k-1)*(font:getHeight()+1)+self.menu.y)
            end
            lg.setColor(1,1,1,1)
            self.textInput:draw()
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