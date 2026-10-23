local exp={}

function exp:enter()
    self.colors={
        {0.1,0.1,0.1},
        {0.1,0.5,1}
    }
    shove.createLayer("map")

    self.ts=8
    local w,h=conf.gw/self.ts,conf.gh/self.ts

    self.map=createMap(w,h)
    
end

function exp:update(dt)

end

function exp:draw()
    shove.beginDraw()
        shove.beginLayer("map")
            for row,i in ipairs(self.map) do
                for col,j in ipairs(i) do
                    lg.setColor(self.colors[j+1])
                    local x,y=(col-1)*self.ts,(row-1)*self.ts
                    lg.rectangle("fill",x,y,self.ts,self.ts)
                end
            end
        shove.endLayer()
    shove.endDraw()
end

return exp