
---@diagnostic disable-next-line: lowercase-global
theskibidi = {}
Workspace = {}
Scripts = {
    draw = {},
    load = {},
    update = {},
    mousepressed = {},
    mousereleased = {},
    mousemoved = {},
    keypressed = {},
    keyreleased = {},
}
Object = require("libraries.classic")

local getTouching = require("libraries.getTouching")
Tweenservice = require("libraries.flux")

Vector2 = require("libraries.vector")
Colour3 = Object.extend(Object)
function Colour3.new(r, g, b, h)
    if h == nil then h = 255 end
    return {r = r/255, g = g/255, b = b/255, h = h/255}
end

--Scripts
Script = Object.extend(Object)
Script.new = function(type, callback)
    local self = {}
    self.Callback = callback
    self.Name = type

    if Scripts[type] ~= nil then
        table.insert(Scripts[type], self)
        --print("Created new script of ".. type)
    end
end


-- Instances
Instance = Object.extend(Object)
Instance.new = function(type)
    local self = {}
    --self.UUID = math.random(-99999999,999999999)
    self.Type = type
    self.DrawMode = "fill"
    self.Position = Vector2.new(0, 0)
    self.Size = Vector2.new(50, 80)
    self.Velocity = Vector2.new(0, 0)
    self.Name = type
    self.Colour = Colour3.new(255, 255, 255, 255)
    self.CanCollide = true

    function self:GetTouching()
        local touching = {}
        for _,instance in pairs(Workspace) do
            if instance ~= self then
                if getTouching(self, instance) and instance.CanCollide then
                    table.insert(touching, instance)
                end
            end
        end
        return touching
    end

    function self:MouseOver()
        local dummyMouse = {}
        dummyMouse.Size = Vector2.new(1,1)
        dummyMouse.Position = Vector2.new(love.mouse.getX(), love.mouse.getY())
        return getTouching(self, dummyMouse)
    end

    function self:MakeDraggable()
        self.Dragging = false
        local startPos = nil
        local dragStart = nil

        Script.new("update", function()
            if self.Dragging and dragStart ~= nil and startPos ~= nil then
                local delta = Vector2.new(love.mouse.getX(), love.mouse.getY()) - dragStart
                local new = startPos + delta
                self.Position = new
            end
        end)

        Script.new("mousepressed", function(x, y, button)
            if self:MouseOver() and button == 1 then
                dragStart = Vector2.new(x, y)
                startPos = self.Position

                self.Dragging = true
            end
        end)
        Script.new("mousereleased", function()
            if self.Dragging then
                self.Dragging = false
            end
        end)

    end

    table.insert(Workspace, self)
    return self
end

function GetInstancesInRadius(position, radius, exclude)
    local touching = {}
    local dummyPos = {}
    dummyPos.Position = position
    dummyPos.Size = radius
    for _,instance in pairs(Workspace) do
        if instance ~= exclude then
            if getTouching(dummyPos, instance) and instance.CanCollide then
                table.insert(touching, instance)
            end
        end
    end
    return touching
end

-- CharacterController
CharacterController = Object.extend(Object)
function CharacterController:Add(instance, data)
    if instance.Position == nil then print("Invalid Instance") return end
    if data == nil then data = {} end

    print("Inserting CharacterController Values into "..instance.Name)
    instance.Speed = data.Speed or 150
    instance.Dampening = 10

    Script.new("update",function(dt)
        if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
            instance.Velocity.y = -instance.Speed
        end
        if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
            instance.Velocity.y = instance.Speed
        end
        if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
            instance.Velocity.x = instance.Speed
        end
        if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
            instance.Velocity.x = -instance.Speed
        end
    end)
end

Gravity = Vector2.new(0, -100)
theskibidi.Draw = function()
    for _,instance in pairs(Workspace) do
        love.graphics.setColor(instance.Colour.r, instance.Colour.g, instance.Colour.b, instance.Colour.h)
        love.graphics[instance.Type](instance.DrawMode, instance.Position.x, instance.Position.y, instance.Size.x, instance.Size.y)
    end
end
theskibidi.Update = function(dt)
    for _,instance in pairs(Workspace) do
        
        if instance.Velocity:mag() ~= 0 then
            local dampening = instance.Dampening or 0.9

            -- local mass = instance.Size.x + instance.Size.y
            -- local impulse = instance.Velocity + Gravity * mass
            -- local acc = impulse/mass
            -- local newvel = instance.Velocity + acc * dt
            -- newvel = newvel * (1 - dampening * dt)
            -- newvel = newvel:clamp(1000)
            -- instance.Velocity = newvel

            instance.Velocity = instance.Velocity / (1 + dampening*dt)
            if instance.Velocity.y < 0.05 and instance.Velocity.y > -0.05 then
                instance.Velocity.y = 0
            end
            if instance.Velocity.x < 0.05 and instance.Velocity.x > -0.05 then
                instance.Velocity.x = 0
            end
            local finalPos = instance.Position - instance.Velocity * dt

            if instance.CanCollide then
                if #GetInstancesInRadius(finalPos, instance.Size, instance) == 0 then
                    instance.Position = finalPos
                    else
                    instance.Velocity = Vector2.new()
                end
            else
                instance.Position = finalPos
            end
        end

    end
end

function love.load()
    for _,v in pairs(Scripts.load) do
        v.Callback()
    end
end
function love.draw()
    for _,v in pairs(Scripts.draw) do
        v.Callback()
    end
    theskibidi.Draw()
end
function love.mousepressed(x, y, button, istouch)
    for _,v in pairs(Scripts.mousepressed) do
        v.Callback(x, y, button, istouch)
    end
end
function love.mousemoved( x, y, dx, dy, istouch )
    for _,v in pairs(Scripts.mousemoved) do
        v.Callback( x, y, dx, dy, istouch )
    end
end
function love.update(dt)
    Tweenservice.update(dt)
    theskibidi.Update(dt)
    for _,v in pairs(Scripts.update) do
        v.Callback(dt)
    end
end
function love.mousereleased(x, y, button)
    for _,v in pairs(Scripts.mousereleased) do
        v.Callback(x, y, button)
    end
 end
function love.keypressed(key, scancode, isrepeat)
    for _,v in pairs(Scripts.keypressed) do
        v.Callback(key, scancode, isrepeat)
    end
end
function love.keyreleased(key, scancode)
    for _,v in pairs(Scripts.keypressed) do
        v.Callback(key, scancode)
    end
end