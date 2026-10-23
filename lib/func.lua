--just some general utils

function math.round(n)
    return math.floor(n+0.5)
end

function math.lerp(a,b,t,dt)
    return a+(b-a)*t*dt
end

function math.clamp(n,min,max)
    return math.max(min,math.min(max,n))
end

function math.collision(ax,ay,aw,ah,bx,by,bw,bh)
    return ax<bx+bw and ax+aw>bx and ay<by+bh and ay+ah>by
end

function math.dist(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt(dx * dx + dy * dy)
end
