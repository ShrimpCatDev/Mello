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
        jump={'key:w',"key:up","key:space","key:z","button:a"},
        start={"key:space","key:z","key:return","button:a","button:start"}
    },
    joystick = love.joystick.getJoysticks()[1]
}

return conf
