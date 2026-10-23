lg=love.graphics


function love.load()
    require('lib.require')
    conf=require('config')

    shove=require('lib.shove')
    shove.setResolution(conf.gw,conf.gh,{fitMethod=conf.fit,renderMode=conf.render})
    shove.setWindowMode(conf.ww,conf.wh,{resizable=true})
    shove.setScalingFilter(conf.filter)

    assets=require('lib.cargo').init('assets')

    fonts={
        monogram=assets.fonts.monogram.monogram(16),
        pixel=lg.newImageFont("assets/fonts/pixel/round_6x6.png",[==[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+-=()[]{}<>/*:#%!?.,'"@&$ ]==],1)
    }
    lg.setFont(fonts.pixel)

    
    states=require.tree('states')

    gs=require('lib.hump.gamestate')
    gs.registerEvents()
    gs.switch(states.example)
end

function love.update(dt)

end

function love.draw()
    
end