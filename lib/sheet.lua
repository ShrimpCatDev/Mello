local sheet={}

function sheet:init(img,w,h)
    self.quads={}
    self.img=img

    local ww,hh=img:getWidth(),img:getHeight()
    for y=0,hh/h-1 do
        for x=0,ww/w-1 do
            local quad=love.graphics.newQuad(x*w,y*h,w,h,ww,hh)
            table.insert(self.quads,quad)
        end
    end
end

function sheet:draw(i,...)
    love.graphics.draw(self.img,self.quads[i+1],...)
end

return sheet