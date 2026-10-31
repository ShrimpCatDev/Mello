local conf={}

conf.gw=144
conf.gh=128

conf.ww=conf.gw*4
conf.wh=conf.gh*4

conf.rendermode="layer"
conf.fit="aspect"

conf.filter="nearest"

conf.input={
    controls={
        right={'key:d',"key:right","button:dpright"},
        left={'key:a',"key:left","button:dpleft"},
        up={'key:w',"key:up","button:dpup"},
        down={'key:s',"key:down","button:dpdown"},
        jump={"key:space","key:z","button:a"},
        shoot={"key:rshift","key:x","button:b"}
    },
    joystick = love.joystick.getJoysticks()[1]
}

debug=true

return conf
