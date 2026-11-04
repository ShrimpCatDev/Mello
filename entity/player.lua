local pl={}

local function filter(item,other)
    if other.flag then
        if other.flag==1 then
            return "slide"
        elseif other.flag==2 and item.vy>=0 and other.y>=item.prevY+item.h then
            return "slide"
        else
            return nil
        end
    end
    return "cross"
end

local function bfilter(item,other)
    if other.flag then
        if other.flag~=0 then
            return "slide"
        else
            return nil
        end
    end
    return "cross"
end

function pl:init(parent,x,y)
    self.parent=parent
    self.x=x or 0
    self.y=y or 0
    self.vx=0
    self.vy=0
    self.w=6
    self.h=7
    self.speed=70

    self.ax=1000
    self.friction=8

    self.jumpHeight=160
    self.dir=1
    self.parent.world:add(self,self.x,self.y,self.w,self.h)

    self.anim={}
    self.anim.run=anim.new({504,507,505},80,"loop")
    self.anim.idle=anim.new({504,524},500,"loop")
    self.anim.die=anim.new({508,509,510,511,508,509,510,511,508,509,510,511,525,525,526},60,"noloop",function() end)
    self.anim.current=self.anim.run

    self.bullets={}
    self.kind="player"

    if self.parent.first then
        self.maxHp=5
        self.hp=self.maxHp
    end
    

    self.invis=0
    self.maxInvis=4
    self.move=true
    self.canDie=true
end

function pl:damage(hp)
    if self.invis<0 and self.canDie then
        print("ow!")
        local damage=hp or 1
        self.invis=self.maxInvis
        self.hp=self.hp-damage

        assets.sfx.hurt2:play()

        if self.hp<1 then
            self.parent:gameOver()
        end
    end
end

function pl:update(dt)
    self.anim.current:update(dt)
    --YOINKED from another one of my games :3
    self.jump=false
    self.prevY=self.y
    self.vy=self.vy+self.parent.world.gravity*dt
    self.y=self.y+self.vy*dt

    local mx=0
    self.invis=self.invis-dt
    
    if input:down("right") then
        mx=1
        self.dir=1
        self.anim.current=self.anim.run
    elseif input:down("left") then
        mx=-1
        self.dir=-1
        self.anim.current=self.anim.run
    else
        self.anim.current=self.anim.idle
    end
    self.vx=self.vx+mx*self.ax*dt
    self.vx=self.vx*(1-math.min(dt*self.friction,1))
    self.vx=math.max(-self.speed,math.min(self.speed,self.vx))
    self.x=self.x+self.vx*dt

    wrap(self,self.parent.world)
    self.y=math.clamp(self.y,-5,conf.gh+5)

    local ax,ay,col,len=self.parent.world:move(self,self.x,self.y,filter)
    self.x,self.y=ax,ay

    for k,v in ipairs(col) do
        if (v.other.flag==1 or v.other.flag==2) and v.normal.y<0 then
            self.vy=0
            self.jump=true
        end

        if v.other.flag==1 and v.normal.y>0 then
            self.vy=0
        end
    end

    if self.jump and input:pressed("jump") then
        self.vy=-self.jumpHeight
        assets.sfx.jump:play()
    end

    local spd=80
    if input:pressed("shoot") and #self.bullets<3 then
        local b={x=pl.x,y=pl.y,w=4,h=4,s=math.random(486,490),kind="pbullet",vx=spd*self.dir,vy=-70,timer=1,kill=false}
        b.die=function(v)
            local rnd=love.math.random
            for i=1,love.math.random(1,3) do
                local d=math.random(-20,20)
                self.parent.particles.new(
                    v.x+rnd(0,v.w),
                    v.y+rnd(0,v.h/2),
                    d,-20,-d,math.random(50,80),
                    1,
                    function(x,y,lt,time,data)
                        lg.setColor(1,1,1,1)
                        sheet:draw(data.spr,x,y)
                    end,
                    function()

                    end,
                    {spr=rnd(491,494)}
                )
            end
        end
        self.parent.world:add(b,b.x,b.y,b.w,b.h)
        table.insert(self.bullets,b)

        local s=assets.sfx.shoot:clone()
        s:setPitch(love.math.random(80,120)/100)
        s:play()
    end

    for k,v in ipairs(self.bullets) do
        v.timer=v.timer-dt
        v.prevY=v.y
        v.vy=v.vy+self.parent.world.gravity*dt
        v.y=v.y+v.vy*dt
        v.x=v.x+v.vx*dt
        wrap(v,self.parent.world)
        local ax,ay,col,len=self.parent.world:move(v,v.x,v.y,filter)
        v.x,v.y=ax,ay

        for k,h in ipairs(col) do
            if (h.other.flag==1 or h.other.flag==2) and h.normal.y<0 then
                v.vy=-math.abs(v.vy)*0.8
            end

            if (h.other.flag==1 or h.other.flag==2) and h.normal.y>0 then
                v.vy=0
            end

            if (h.other.flag==1 or h.other.flag==2) and h.normal.x~=0 and h.normal.y==0 then
                v.vx=spd*h.normal.x
            end
        end
        if v.timer<=0 then
            v.kill=true
        end
    end

    killStuff(self.parent.world,self.bullets)
end

function pl:draw()
    dwrap(function()
        if not self.parent.over then
            for k,v in ipairs(self.bullets) do
                sheet:draw(v.s,v.x,v.y)
            end
        end

        local o=0
        if self.dir==-1 then
            o=8
        end
        
        lg.setColor(1,1,1,1)
        if self.invis>0 and self.parent.active then
            lg.setColor(1,1,1,math.floor((love.timer.getTime()*32)%2)+0.5)
        end

        sheet:draw(self.anim.current:get(),pl.x-1+o,pl.y-1,0,self.dir,1)
        lg.setColor(1,1,1,1)
    end)
end

return pl