local bg={}

function bg:init()

end

function bg:update()

end

function bg:draw()
    --colors for the bg
    local colors={
        {0.1,0.5,1},
        {0.1,0.1,0.15}
    }

    --cool scrolling background checkerboard yes
    for y=-1,(conf.gh/8) do
        for x=-1,(conf.gw/8) do
            lg.setColor(colors[(x+y)%2+1])
            local xx=(x*8)+(love.timer.getTime()*4)%8
            local yy=(y*8)+(love.timer.getTime()*4)%8
            lg.rectangle("fill",xx,yy,8,8)
        end
    end
end

return bg