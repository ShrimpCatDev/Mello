local shroom={}

function shroom:init(parent)
    self.parent=parent
    self.items={}
    self.speed=45
    self.hp=5
end

function shroom:new(x,y)
    local rnd={-1,1}
    local a={dir=rnd[love.math.random(1,2)],x=x,y=y,id="shroom",kind="enemy",w=8,h=8,vx=self.speed,vy=0,prevY=0,kill=false,hp=self.hp}
    a.vx=self.speed*a.dir
    a.anim=anim.new({468,469,470},80,"loop")
    self.parent.world:add(a,a.x,a.y,a.w,a.h)
    table.insert(self.items,a)
end

function shroom:update(dt)
    for k,v in pairs(self.items) do
        v.anim:update(dt)
        v.jump=false
        v.prevY=v.y
        v.vy=v.vy+self.parent.world.gravity*dt
        v.x=v.x+v.vx*dt
        v.y=v.y+v.vy*dt
        wrap(v,self.parent.world)

        local ax,ay,col,len=self.parent.world:move(v,v.x,v.y,self.parent.filter)
        v.x,v.y=ax,ay

        for _,h in ipairs(col) do
            if (h.other.flag==1 or h.other.flag==2) and h.normal.y<0 then
                v.vy=0
                v.jump=true
                if love.math.random(0,100)==50 then
                    v.vy=-160
                end
            end

            if h.other.flag==1 and h.normal.y>0 then
                v.vy=0
            end

            if h.other.flag==1 and h.normal.x~=0 and h.normal.y==0 then
                v.vx=self.speed*h.normal.x
                v.dir=h.normal.x
            end

            if h.other.kind=="pbullet" then
                h.other.kill=true
                v.hp=v.hp-1
                if v.hp<1 then
                    v.kill=true
                    self.parent.score=self.parent.score+50
                end
            end
        end
    end

    killStuff(self.parent.world,self.items)
end

function shroom:draw()
    dwrap(function()
        for k,v in pairs(self.items) do
            local o=0
            if v.dir==-1 then
                o=8
            end
            sheet:draw(v.anim:get(),v.x+o,v.y,0,v.dir,1)
        end
    end)
end

return shroom