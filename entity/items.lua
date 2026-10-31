local items={}

function items:init(parent)
    self.parent=parent
    self.items={}
    self.foods={
        ["pear"]={name="pear",sprite=537,points=40},
        ["pie"]={name="pie",sprite=538,points=50},
        ["cherry"]={name="cherry",sprite=539,points=60}
    }
end

function items:new(x,y,kinds)
    local k=kinds[love.math.random(1,#kinds)]
    local data=self.foods[k]
    local a={x=x,y=y,id=k,kind="item",w=8,h=8,vx=0,vy=-90,prevY=0,kill=false,timer=5}
    self.parent.world:add(a,a.x,a.y,a.w,a.h)
    table.insert(self.items,a)
end

function items:update(dt)
    for k,v in pairs(self.items) do
        v.prevY=v.y
        v.vy=v.vy+self.parent.world.gravity*dt
        v.x=v.x+v.vx*dt
        v.y=v.y+v.vy*dt
        v.timer=v.timer-dt
        wrap(v,self.parent.world)

        local ax,ay,col,len=self.parent.world:move(v,v.x,v.y,self.parent.filter)
        v.x,v.y=ax,ay

        for _,h in ipairs(col) do
            if (h.other.flag==1 or h.other.flag==2) and h.normal.y<0 then
                v.vy=0
            end

            if h.other.flag==1 and h.normal.y>0 then
                v.vy=0
            end

            if h.other.kind=="player" then
                v.kill=true
                self.parent.score=self.parent.score+self.foods[v.id].points
            end
        end

        if v.timer<=0 then
            v.kill=true
        end
    end

    killStuff(self.parent.world,self.items)
end

function items:draw()
    dwrap(function()
        for k,v in pairs(self.items) do
            sheet:draw(self.foods[v.id].sprite,v.x,v.y)
        end
    end)
end

return items