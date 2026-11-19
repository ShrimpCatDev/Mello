local items={}

function items:init(parent)
    self.parent=parent
    self.items={}
    self.foods={
        ["pear"]={name="pear",sprite=537,points=40},
        ["pie"]={name="pie",sprite=538,points=50},
        ["cherry"]={name="cherry",sprite=539,points=60},
        ["popsicle"]={name="popsicle",sprite=533,points=250},
        ["turnip"]={name="turnip",sprite=534,points=200},
        ["meat"]={name="meat",sprite=535,points=150},
        ["coconut"]={name="coconut",sprite=536,points=70},

        ["speedPotion"]={name="speedPotion",sprite=513,points=200,func=function(v,pl)
            pl.speed=100
        end},
        ["healPotion"]={name="healPotion",sprite=518,points=250,func=function(v,pl)
            pl.hp=pl.hp+1
            pl.hp=math.min(pl.hp,pl.maxHp)
        end},
        ["healthPotion"]={name="healthPotion",sprite=515,points=250,func=function(v,pl)
            pl.maxHp=pl.maxHp+1
            pl.maxHp=math.min(pl.maxHp,10)
        end}
    }
    self.get={}
    self.timer=timer:new()
end

function items:new(x,y,kinds,special)
    local k=kinds[love.math.random(1,#kinds)]
    local d=self.foods[k]
    local a={x=x,y=y,id=k,kind="item",w=8,h=8,vx=0,vy=-90*0.6,prevY=0,kill=false,timer=5}
    a.func=d.func or false
    a.special=special or false
    self.parent.world:add(a,a.x,a.y,a.w,a.h)
    table.insert(self.items,a)

    a.sx=0
    self.timer:tween(0.2,a,{sx=1},"out-cubic")
end

function items:update(dt)
    self.timer:update(dt)
    for k,v in pairs(self.items) do
        v.prevY=v.y

        if not v.special then
            v.vy=v.vy+self.parent.world.gravity*0.6*dt
            v.x=v.x+v.vx*dt
            v.y=v.y+v.vy*dt
        end

        v.timer=v.timer-dt
        wrap(v,self.parent.world)

        local ax,ay,col,len=self.parent.world:move(v,v.x,v.y,self.parent.filter)
        v.x,v.y=ax,ay

        for _,h in ipairs(col) do
            if (h.other.flag==1 or h.other.flag==2) and h.normal.y<0 then
                v.vy=0
            end

            if h.other.flag==1 and h.normal.y>0 then
                v.vy=0
            end

            if h.other.kind=="player" then
                v.kill=true
                self.parent.score=self.parent.score+self.foods[v.id].points
                if v.func then v.func(v,self.parent.player) end
                
                local s=assets.sfx.get
                s:stop()
                s:setPitch(love.math.random(80,120)/100)
                s:play()

                local a={x=v.x,y=v.y,id=v.id,r=0,kill=false,w=8,h=8,sx=1,sy=1}
                table.insert(self.get,a)
                
                self.timer:tween(0.3,a,{y=a.y-10},"out-cubic",function()
                    self.timer:tween(0.2,a,{sx=0},"out-back",function()
                        a.kill=true
                    end)
                end)

                self.parent.particles.new(
                    v.x+v.w/2,
                    v.y+v.h/2,
                    0,-20,0,0,
                    1,
                    function(x,y,lt,time,d)
                        local t=self.foods[v.id].points
                        lg.setColor(color("#f7f1e4",math.floor((love.timer.getTime()*16)%2)+0.5))
                        local f=lg.getFont()
                        lg.print(t,x-f:getWidth(t)/2,y-f:getHeight()/2)
                    end,
                    function()

                    end,
                    {}
                )
            end
        end

        if v.timer<=0  then
            v.kill=true
            local a={x=v.x,y=v.y,id=v.id,r=0,kill=false,w=8,h=8,sx=1,sy=1}
            table.insert(self.get,a)
            
            self.timer:tween(0.5,a,{sx=0},"in-back",function()
                a.kill=true
            end)
        end
    end

    killStuff(self.parent.world,self.items)
    killStuff(nil,self.get)
end

function items:draw()
    dwrap(function()
        for k,v in pairs(self.items) do
            sheet:draw(self.foods[v.id].sprite,v.x+v.w/2,v.y+v.h/2,v.r,v.sx,v.sy,v.w/2,v.h/2)
        end
        for k,v in pairs(self.get) do
            sheet:draw(self.foods[v.id].sprite,v.x+v.w/2,v.y+v.h/2,v.r,v.sx,v.sy,v.w/2,v.h/2)
        end
    end)
end

return items