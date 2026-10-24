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
    self.jumpHeight=160
    self.dir=1
    self.parent.world:add(self,self.x,self.y,self.w,self.h)

    self.bullets={}
end

function pl:update(dt)
    --YOINKED from another one of my games :3
    self.jump=false
    self.prevY=self.y
    self.vy=self.vy+self.parent.world.gravity*dt
    self.y=self.y+self.vy*dt

    if input:down("right") then
        self.vx=self.speed
        self.dir=1
    elseif input:down("left") then
        self.vx=-self.speed
        self.dir=-1
    else
        self.vx=0
    end
    self.x=self.x+self.vx*dt

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

    if self.jump then
        if input:pressed("jump") then
            self.vy=-self.jumpHeight
        end
    end

    local spd=80
    if input:pressed("shoot") then
        local b={x=pl.x,y=pl.y,w=4,h=4,s=math.random(486,490),kind="pbullet",vx=spd*self.dir,vy=-70,timer=1,kill=false}
        self.parent.world:add(b,b.x,b.y,b.w,b.h)
        table.insert(self.bullets,b)
    end

    for k,v in ipairs(self.bullets) do
        v.timer=v.timer-dt
        v.vy=v.vy+self.parent.world.gravity*dt
        v.y=v.y+v.vy*dt
        v.x=v.x+v.vx*dt
        local ax,ay,col,len=self.parent.world:move(v,v.x,v.y,bfilter)
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

    for i=#self.bullets,1,-1 do
        local b=self.bullets[i]
        if b.kill then
            self.parent.world:remove(b)
            table.remove(self.bullets,i)
        end
    end
end

function pl:draw()
    --lg.rectangle("fill",self.x,self.y,self.w,self.h)

    for k,v in ipairs(self.bullets) do
        sheet:draw(v.s,v.x,v.y)
    end

    local o=0
    if self.dir==-1 then
        o=8
    end
    sheet:draw(504,pl.x-1+o,pl.y-1,0,self.dir,1)
end

return pl