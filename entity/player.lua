local pl={}

function pl:init(parent,x,y)
    self.parent=parent
    self.x=x
    self.y=y
    self.vx=0
    self.vy=0
    self.w=8
    self.h=8
    self.parent.world:add(self,self.x,self.y,self.w,self.h)
end

function pl:update(dt)
    --YOINKED from another one of my games :3
    self.vy=self.vy+self.parent.world.gravity*dt
    self.y=self.y+self.vy*dt
    local ax,ay,col,len=self.parent.world:move(self,self.x,self.y,self.filter)
    self.x,self.y=ax,ay
end

function pl:draw()
    lg.rectangle("fill",self.x,self.y,self.w,self.h)
end

return pl