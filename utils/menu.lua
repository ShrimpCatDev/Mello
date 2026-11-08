local menu={}

function menu:init(x,y,defaultSel)
    self.sel=defaultSel or 1
    self.items={}
    self.time=0
    self.font=love.graphics.getFont()
    self.x=x or 0
    self.y=y or 0
end

function menu:add(name,func)
    table.insert(self.items,{name=name,func=func})
end

function menu:update(dt)
    self.time=self.time+dt
    if input:pressed("down") then
        self.sel=self.sel+1
    end
    if input:pressed("up") then
        self.sel=self.sel-1
    end
    if self.sel>#self.items then self.sel=1 end
    if self.sel<1 then self.sel=#self.items end

    if input:pressed("jump") then
        local f=self.items[self.sel].func
        f(self)
    end
end

function menu:draw()
    lg.setColor(color("#f7f1e4"))
    local font=self.font
    for k,v in ipairs(self.items) do
        local s=v.name
        if k==self.sel then
            s="> "..v.name.." <"
        end
        lg.print(s,self.x-font:getWidth(s)/2,(k-1)*(font:getHeight()+1)+self.y)
    end
    lg.setColor(1,1,1,1)
end

return menu