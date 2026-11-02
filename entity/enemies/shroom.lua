local shroom={}

function shroom:init(parent)
    self.parent=parent
    self.items={}
    self.speed=45
    self.hp=5
    self.drops={
        "cherry","pie","pear"
    }
end

function shroom:new(x,y)
    local rnd={-1,1}
    local a={dir=rnd[love.math.random(1,2)],x=x,y=y,id="shroom",kind="enemy",w=8,h=8,vx=self.speed,vy=0,prevY=0,kill=false,hp=self.hp,gonnaJump=false}
    a.vx=self.speed*a.dir
    a.animRun=anim.new({468,469,470},80,"loop")
    a.animJump=anim.new({471},80,"loop")
    a.anim=a.animRun
    self.parent.world:add(a,a.x,a.y,a.w,a.h)
    table.insert(self.items,a)
end

function shroom:update(dt)
    for k,v in pairs(self.items) do
        v.anim:update(dt)
        v.jump=false
        v.prevY=v.y
        v.vy=v.vy+self.parent.world.gravity*dt
        if not v.gonnaJump then
            v.x=v.x+v.vx*dt
        end
        v.y=v.y+v.vy*dt
        wrap(v,self.parent.world)

        local ax,ay,col,len=self.parent.world:move(v,v.x,v.y,self.parent.filter)
        v.x,v.y=ax,ay

        for _,h in ipairs(col) do
            if (h.other.flag==1 or h.other.flag==2) and h.normal.y<0 then
                v.vy=0
                v.jump=true
                if not v.gonnaJump then
                    if love.math.random(0,100)==50 then
                        v.gonnaJump=true
                        v.anim=v.animJump
                        timer.after(0.8,function()
                            local s=assets.sfx.jumpSmall:clone()
                            s:setPitch(love.math.random(100,110)/100)
                            s:play()
                            v.vy=-160
                            v.gonnaJump=false
                            v.anim=v.animRun
                        end)
                    end
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
                    self.parent.items:new(v.x,v.y,self.drops)
                    local s=assets.sfx.hurt2:clone()
                    s:setPitch(love.math.random(100,110)/100)
                    s:play()
                else
                    
                end
            end

            if h.other.kind=="player" then
                h.other:damage()
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