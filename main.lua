lg=love.graphics


function love.load()
    color=require("lib.hex2color")
    require('lib.require')
    conf=require('config')
    require('lib.func')
    json=require('lib.json')
    lg.setLineStyle("rough")

    shove=require('lib.shove')
    shove.setResolution(conf.gw,conf.gh,{fitMethod=conf.fit,renderMode=conf.rendermode})
    shove.setWindowMode(conf.ww,conf.wh,{resizable=true})
    shove.setScalingFilter(conf.filter)

    assets=require('lib.cargo').init('assets')

    local baton=require("lib/baton")
    input=baton.new(conf.input)

    fonts={
        monogram=assets.fonts.monogram.monogram(16),
        pixel=lg.newImageFont("assets/fonts/pixel/round_6x6.png",[==[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+-=()[]{}<>/*:#%!?.,'"@&$ ]==],1)
    }
    lg.setFont(fonts.pixel)
    
    states=require.tree('states')

    timer=require('lib.hump.timer')

    sheet=require('lib.sheet')
    tileset=sheet:init(assets.maps.tileset,8,8)

    gs=require('lib.hump.gamestate')
    gs.registerEvents()
    gs.switch(states.title)
end

function love.update(dt)
    timer.update(dt)
    input:update()
end

function love.draw()
    
end