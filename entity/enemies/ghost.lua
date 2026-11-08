local temp={}

function temp:init(parent)
    self.parent=parent
    self.items={}
    self.speed=32
    self.hp=5
    self.drops={
        "pear","pie"
    }
    self.hats={433,434,435,436}
    self.timer=timer:new()
end

function temp:new(x,y)
    local rnd={-1,1}
    local a={x=x,y=y,id="temp",kind="enemy",w=8,h=8,vx=0,vy=0,prevY=0,kill=false,hp=self.hp,dir=rnd[love.math.random(1,2)],dy=rnd[love.math.random(1,2)],hy=0,hvy=0}
    self.parent.world:add(a,a.x,a.y,a.w,a.h)
    a.anim=anim.new({450,451},250,"loop")
    a.hat=self.hats[love.math.random(1,#self.hats)]
    initEnemy(a)
    if love.math.random(1,50)==25 then
        a.hat=437
    end
    table.insert(self.items,a)
end

function temp:update(dt)
    self.timer:update(dt)
    for k,v in pairs(self.items) do
        v.glow=v.glow-dt
        v.anim:update(dt)
        v.prevY=v.y
        --v.vy=v.vy+self.parent.world.gravity*dt
        v.vx=v.dir*self.speed
        v.vy=v.dy*self.speed
        v.x=v.x+v.vx*dt
        v.y=v.y+v.vy*dt

        v.hvy=v.hvy+self.parent.world.gravity*dt
        v.hy=v.hy+v.hvy*dt
        v.hy=math.min(v.hy,0)

        wrap(v,self.parent.world)

        local ax,ay,col,len=self.parent.world:move(v,v.x,v.y,self.parent.filter)
        v.x,v.y=ax,ay

        for _,h in ipairs(col) do
            if (h.other.flag==1 or h.other.flag==2) and h.normal.y~=0 then
                v.dy=h.normal.y
            end

            if (h.other.flag==1 or h.other.flag==2) and h.normal.x~=0 then
                v.dir=h.normal.x
            end

            if h.other.kind=="pbullet" then
                damageEnemy(h,v,self)
                if v.hy>=0 then v.hvy=-80 end
            end

            if h.other.kind=="player" then
                h.other:damage()
            end
        end
    end

    killStuff(self.parent.world,self.items)
end

function temp:draw()
    dwrap(function()
        for k,v in pairs(self.items) do
            drawEnemy(v,function(o)
                sheet:draw(v.hat,v.x+o,v.y+v.hy-7,0,v.dir,1)
            end)
        end
    end)
end

return temp