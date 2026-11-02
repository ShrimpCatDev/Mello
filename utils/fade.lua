local fade={}

function fade:init(color)
    self.opacity=0
    self.color=color or "#000000"
    self.fading=false
end

function fade:fade(speed,oldOpacity,opacity,color,endfunc)
    if color then self.color=color end
    self.opacity=oldOpacity or 0
    self.fading=true
    timer.tween(speed,self,{opacity=opacity},"out-cubic",function() 
        if endfunc then endfunc() end 
        self.fading=false
    end)
end

function fade:draw()
    local o=math.floor(self.opacity*4+0.5)/4
    lg.setColor(color(self.color,o))
    lg.rectangle("fill",0,0,conf.gw,conf.gh)
    lg.setColor(1,1,1,1)
end

return fade