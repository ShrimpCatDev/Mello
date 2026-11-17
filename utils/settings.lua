local set={}

function set:init()
    input:update()
    self.menu=require("utils/menu")
    self.menu:init(conf.gw/2,conf.gh/2)
    self.active=true
    save.options=save.options or {}
    save.options.volume=save.options.volume or 100
    local i=self.menu:add(
        "Volume: "..save.options.volume,
        (function(s)
            save.options.volume=save.options.volume+10
            if save.options.volume>100 then save.options.volume=0 end
            s.name="Volume: "..save.options.volume
            love.audio.setVolume(save.options.volume/100)
            local s=assets.sfx.get
            s:setPitch(1)
            s:stop()
            s:play()
        end)
    )

    save.options.crt=save.options.crt or false
    local i=self.menu:add(
        "Toggle CRT Effect",
        (function(s)
            save.options.crt=not save.options.crt
            if save.options.crt then
                shove.addGlobalEffect(shaders.crt)
            else
                shove.removeGlobalEffect(shaders.crt)
            end
        end)
    )

    save.options.fullscreen=save.options.fullscreen or false
    local t={
        [true]="Disable Fullscreen",
        [false]="Enable Fullscreen"
    }
    local i=self.menu:add(
        t[save.options.fullscreen],
        (function(s)
            save.options.fullscreen=not love.window.getFullscreen()
            love.window.setFullscreen(save.options.fullscreen)
            s.name=t[save.options.fullscreen]
        end)
    )

    local i=self.menu:add(
        "Exit",
        (function(s)
            self.active=false
            saveData()
        end)
    )

    local menu=self.menu
    self.w,self.h=1,#menu.items*menu.font:getHeight()+8
    local pw=0
    for k,v in pairs(menu.items) do
        if menu.font:getWidth(v.name)>pw then
            pw=menu.font:getWidth(v.name)
        end
    end
    self.w=pw+20

    self.menu.y=conf.gw/2-(#menu.items*menu.font:getHeight()+8)/2
end

function set:update(dt)
    if self.active then
        self.menu:update(dt)
        if input:pressed("shoot") then
            self.active=false
            saveData()
        end
    end
end

function set:draw()
    if self.active then
        lg.setColor(0,0,0,1)
            lg.rectangle("fill",conf.gw/2-self.w/2,self.menu.y-4,self.w+1,self.h)
        lg.setColor(1,1,1,1)
            lg.rectangle("line",conf.gw/2-self.w/2+0.5,self.menu.y-4+0.5,self.w+1,self.h)
        lg.setColor(1,1,1,1)
        self.menu:draw()
    end
end

return set