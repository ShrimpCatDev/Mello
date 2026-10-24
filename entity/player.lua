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

function pl:init(parent,x,y)
    self.parent=parent
    self.x=x
    self.y=y
    self.vx=0
    self.vy=0
    self.w=8
    self.h=8
    self.speed=120
    self.jumpHeight=160
    self.dir=1
    self.parent.world:add(self,self.x,self.y,self.w,self.h)
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

    if self.y<-self.h then
        self.y=conf.gh
        self.parent.world:update(self,self.x,self.y)
    elseif self.y>conf.gh then
        self.y=-self.h
        self.parent.world:update(self,self.x,self.y)
    end

    if self.x<-self.w then
        self.x=conf.gw
        self.parent.world:update(self,self.x,self.y)
    elseif self.x>conf.gw then
        self.x=-self.w
        self.parent.world:update(self,self.x,self.y)
    end

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

    
end

function pl:draw()
    lg.rectangle("fill",self.x,self.y,self.w,self.h)
end

return pl