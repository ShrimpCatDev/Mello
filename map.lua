local map={}
local sheet=require('lib.sheet')

function map:init()
    self.sheet=sheet
    self.tileset=assets.maps.tileset
    self.tilewidth,self.tileheight=8,8
    self.quads=sheet:init(assets.maps.tileset,self.tilewidth,self.tileheight)

    self:clear()
end

function map:update()

end

function map:draw()
    for row,i in ipairs(self.data.tiles) do
        for col,v in ipairs(i) do
            local x,y=(col-1)*self.tilewidth,(row-1)*self.tileheight
            sheet:draw(v,x,y)
        end
    end
end

function map:drawTile(t,x,y)
    sheet:draw(t,x,y)
end

function map:set(x,y,t)
    self.data.tiles[y][x]=t
end

function map:clear()
    local w,h=conf.gw/self.tilewidth,conf.gh/self.tileheight
    self.data={
        tiles=createMap(w,h),
        flags=createMap(w,h)
    }
end

return map