local map={}
local sheet=require('lib.sheet')

function map:init()
    self.flagColors={
        {0,0,0,0},
        {1,0.2,0,0.5},
        {0.2,0.8,1,0.5}
    }
    self.cols={}
    self.sheet=sheet
    self.tileset=assets.maps.tileset
    self.tilewidth,self.tileheight=8,8
    self.quads=sheet:init(assets.maps.tileset,self.tilewidth,self.tileheight)

    self:clear()
    self.ox,self.oy=0,0
    self.debug=false
end

function map:load(name)
    self:clear()
    local data=love.filesystem.read(name)
    if data then
        self.data=json.decode(data)
        return data
    end
    return nil
end

function map:initBump(world)
    for k,v in pairs(self.cols) do
        world:remove(v)
    end

    self.cols={}

    for row,i in ipairs(self.data.flags) do
        for col,v in ipairs(i) do
            if v~=0 then
                local x,y=(col-1)*self.tilewidth,(row-1)*self.tileheight
                local w=self.tilewidth
                local h=self.tileheight
                local t={
                    x=x,
                    y=y,
                    w=w,
                    h=h,
                    flag=v
                }
                table.insert(self.cols,t)
                world:add(t,x,y,w,h)

                if col==1 then
                    local x,y=conf.gw,(row-1)*self.tileheight
                    local w=self.tilewidth
                    local h=self.tileheight
                    local t={
                        x=x,
                        y=y,
                        w=w,
                        h=h,
                        flag=v
                    }
                    table.insert(self.cols,t)
                    world:add(t,x,y,w,h)
                elseif col==#i then
                    local x,y=-8,(row-1)*self.tileheight
                    local w=self.tilewidth
                    local h=self.tileheight
                    local t={
                        x=x,
                        y=y,
                        w=w,
                        h=h,
                        flag=v
                    }
                    table.insert(self.cols,t)
                    world:add(t,x,y,w,h)
                end

                if row==1 then
                    local x,y=(col-1)*self.tilewidth,conf.gh
                    local w=self.tilewidth
                    local h=self.tileheight
                    local t={
                        x=x,
                        y=y,
                        w=w,
                        h=h,
                        flag=v
                    }
                    table.insert(self.cols,t)
                    world:add(t,x,y,w,h)
                elseif row==#self.data.flags then
                    local x,y=(col-1)*self.tilewidth,-8
                    local w=self.tilewidth
                    local h=self.tileheight
                    local t={
                        x=x,
                        y=y,
                        w=w,
                        h=h,
                        flag=v
                    }
                    table.insert(self.cols,t)
                    world:add(t,x,y,w,h)
                end
            end
        end
    end
end

function map:update(dt)
    if self.debug then
        local spd=50
        if love.keyboard.isDown("i") then
            self.oy=self.oy+spd*dt
        end
        if love.keyboard.isDown("k") then
            self.oy=self.oy-spd*dt
        end
        if love.keyboard.isDown("l") then
            self.ox=self.ox+spd*dt
        end
        if love.keyboard.isDown("j") then
            self.ox=self.ox-spd*dt
        end
        if love.keyboard.isDown("o") then
            self.ox=0
            self.oy=0
        end
    end
end

function map:draw(ox,oy)
    local xx,yy=ox or 0,oy or 0
    for row,i in ipairs(self.data.tiles) do
        for col,v in ipairs(i) do
            local x,y=(col-1)*self.tilewidth,(row-1)*self.tileheight
            sheet:draw(v,x+xx+self.ox,y+yy+self.oy)
        end
    end
    if self.debug then
        lg.setColor(1,1,1,0.5)
        for k,v in ipairs(self.cols) do
            lg.rectangle("fill",v.x+self.ox,v.y+self.oy,v.w,v.h)
        end
        lg.setColor(1,1,1,1)
    end
end

function map:drawFlags()
    for row,i in ipairs(self.data.flags) do
        for col,v in ipairs(i) do
            local x,y=(col-1)*self.tilewidth,(row-1)*self.tileheight
            lg.setColor(self.flagColors[v+1])
            lg.rectangle("fill",x,y,self.tilewidth,self.tileheight)
        end
    end
    lg.setColor(1,1,1,1)
end

function map:drawTile(t,x,y)
    sheet:draw(t,x,y)
end

function map:set(x,y,t)
    self.data.tiles[y][x]=t
end

function map:flag(x,y,t)
    self.data.flags[y][x]=t
end

function map:clear()
    local w,h=conf.gw/self.tilewidth,conf.gh/self.tileheight
    self.data={
        tiles=createMap(w,h),
        flags=createMap(w,h)
    }
end

return map