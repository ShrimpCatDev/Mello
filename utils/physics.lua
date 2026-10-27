local physics={}

function physics.gravity(item)
    v.jump=false
    v.prevY=v.y
    v.vy=v.vy+self.parent.world.gravity*dt
    v.x=v.x+v.vx*dt
    v.y=v.y+v.vy*dt
end

return physics