local text={}

function text:init()
    self.text=""
    self.open=false
end

function text:update(dt)

end

function text:draw()
    if self.open then
        lg.setColor(0,0,0,0.4)
        lg.rectangle("fill",0,0,conf.gw,conf.gh)
        lg.setColor(1,1,1,1)
        lg.print(self.text..".",1,1)
    end
end

function text:input(k)
    if self.open then
        self.text=self.text..k
    end
end

function text:key(k)
    if self.open then
        if k=="backspace" then
            self.text=string.sub(self.text,1,string.len(self.text)-1)
        end
        if k=="return" then
            self.open=false
            local t=self.text
            self.text=""
            if self.func then self.func(t) end
        end
        if k=="escape" then
            self.open=false
            self.text=""
        end
    end
end 

function text:spawn(endFunc)
    self.func=endFunc
    self.open=true
    self.text=""
end

return text