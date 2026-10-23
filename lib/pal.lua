local pal={
    palettes={},
    current={}
}

function pal:new(name,img)
    local tbl={}
    for y=0,img:getHeight()-1 do
        for x=0,img:getWidth()-1 do
            local r,g,b = img:getPixel(x,y)
            table.insert(tbl,{r=r,g=g,b=b})
        end
    end
    self.palettes[name]=tbl
end

function pal:load(name)
    self.current=self.palettes[name]
end

function pal:color(index,name)
    local c={}
    if name then
        c=self.palettes[name][index+1]
    else
        c=self.current[index+1]
    end
    
    return c.r,c.g,c.b
end

function pal:getLen(name)
    if name then
        return #self.palettes[name]
    else
        return #self.current
    end
end

function pal:rmv(name)
    self.palettes[name]=nil
end

return pal