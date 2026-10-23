local map={}
local sheet=require('lib.sheet')

function map:init()
    self.tileset=assets.maps.tileset
    self.tilewidth,self.tileheight=8,8
    self.quads=sheet:init(assets.maps.tileset,self.tilewidth,self.tileheight)

    local w,h=conf.gw/self.tilewidth,conf.gh/self.tileheight
    self.tiles=createMap(w,h)
end

function map:update()

end

function map:draw()
    for row,i in ipairs(self.tiles) do
        for col,v in ipairs(i) do
            local x,y=(col-1)*self.tilewidth,(row-1)*self.tileheight
            sheet:draw(v,x,y)
        end
    end
end

function map:set(x,y,t)
    self.tiles[y][x]=t
end

return map