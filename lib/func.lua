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
            if world then world:remove(b) end
            table.remove(root,i)
        end
    end
end

function wrap(item,world)
    item.vy=math.min(item.vy,150)
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

function damageEnemy(h,v,self)
    v.glow=0.1
    h.other.kill=true
    v.hp=v.hp-1
    self.timer:tween(0.08,v,{bw=0.6,bh=1.4},"out-cubic",function()
        self.timer:tween(0.1,v,{bw=1,bh=1},"out-back",function() end)
    end)

    local s=assets.sfx.hurt2:clone()
    s:setPitch(love.math.random(100,110)/100)
    s:play()

    if v.hp<1 and not v.kill then
        v.kill=true
        self.parent.score=self.parent.score+50
        self.parent.items:new(v.x,v.y,self.drops)
    end
end

function initEnemy(a)
    a.glow=0
    a.bw=1
    a.bh=1
end

function drawEnemy(v,func)
    lg.setShader(shaders.white)
    shaders.white:send("WhiteFactor",math.ceil(math.max(v.glow,0)))
        local o=0
        if v.dir==-1 then
            o=8
        end
        sheet:draw(v.anim:get(),v.x+v.w/2,v.y+v.h,0,v.dir*v.bw,v.bh,v.w/2,v.h)
        func(o,v)
    lg.setShader()
end