local exp={}

function exp:enter()
    shove.createLayer("example")
end

function exp:update(dt)

end

function exp:draw()
    shove.beginDraw()
        shove.beginLayer("example")
            lg.print("Hello world!")
        shove.endLayer()
    shove.endDraw()
end

return exp