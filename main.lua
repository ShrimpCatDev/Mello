--[[
    For Those Reading My Code:
    I was sick while working on this so WHO KNOWS what unholy spaghetti code i wrote
    Look at your own risk, ill try to clean things up later fs fs fs
]]

lg=love.graphics
if not unpack then unpack=table.unpack end --for lua 5.2 users lol

function saveData()
    local d=tostring(json.encode(save))
    love.filesystem.write("save.json",d)
end

function loadData()
    save.options=save.options or {}
    save.options.volume=save.options.volume or {}
    love.audio.setVolume(save.options.volume/100)
end

function love.load()
    version="v0.3a"

    require('lib.require')
    json=require('lib.json')

    conf=require('config')
    require('lib.func')

    anim=require('lib.anim')
    color=require("lib.hex2color")
    lg.setLineStyle("rough")

    shove=require('lib.shove')
    shove.setResolution(conf.gw,conf.gh,{fitMethod=conf.fit,renderMode=conf.rendermode})
    shove.setWindowMode(conf.ww,conf.wh,{resizable=true})
    shove.setScalingFilter(conf.filter)

    assets=require('lib.cargo').init('assets')

    sheet=require('lib.sheet')
    tileset=sheet:init(assets.maps.tileset,8,8)

    local baton=require("lib/baton")
    input=baton.new(conf.input)

    shaders={
        white=lg.newShader("shaders/white.glsl")
    }

    fonts={
        monogram=assets.fonts.monogram.monogram(16),
        pixel=lg.newImageFont("assets/fonts/pixel/round_6x6.png",[==[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+-=()[]{}<>/*:#%!?.,'"@&$ ]==],1)
    }
    lg.setFont(fonts.pixel)
    
    states=require.tree('states')

    timer=require('lib.hump.timer')

    local s=love.filesystem.read("save.json")
    if s then s=json.decode(s) end
    save=s or {}
    loadData()

    gs=require('lib.hump.gamestate')
    gs.registerEvents()
    gs.switch(states.title)
end

function love.update(dt)
    timer.update(dt)
    input:update()
end

function love.keypressed(k)
    if k=="f5" then
        assets.maps.tileset=lg.newImage("assets/maps/tileset.png")
        tileset=sheet:init(assets.maps.tileset,8,8)
    end
end