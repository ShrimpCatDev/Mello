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

function createMap(w,h)
    local map={}
    for y=1,h do
        local t={}
        for x=1,w do
            table.insert(t,0)
        end
        table.insert(map,t)
    end
    return map
end

function killStuff(world,root)
    for i=#root,1,-1 do
        local b=root[i]
        if b.kill then
            world:remove(b)
            table.remove(root,i)
        end
    end
end

function wrap(item,world)
    if item.x>conf.gw-4 then
        item.x=-4
        world:update(item,item.x,item.y)
    elseif item.x<-4 then
        item.x=conf.gw-4
        world:update(item,item.x,item.y)
    elseif item.y>conf.gh-4 then
        item.y=-4
        world:update(item,item.x,item.y)
    elseif item.y<-4 then
        item.y=conf.gh-4
        world:update(item,item.x,item.y)
    end
end

function dwrap(func)
    func()
    lg.push()
        lg.translate(conf.gw,0)
        func()
    lg.pop()
    lg.push()
        lg.translate(-conf.gw,0)
        func()
    lg.pop()
    lg.push()
        lg.translate(0,conf.gh)
        func()
    lg.pop()
    lg.push()
        lg.translate(0,-conf.gh)
        func()
    lg.pop()
end