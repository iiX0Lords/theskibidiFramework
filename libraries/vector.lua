--[[
  Copyright (c) 2012 Roland Yonaba

  Permission is hereby granted, free of charge, to any person obtaining a
  copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:

  The above copyright notice and this permission notice shall be included
  in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

local sqrt, abs = math.sqrt, math.abs

-- Vector class
local Vec = { x = 0, y = 0}
Vec.__index = Vec

-- Tostring
Vec.__tostring = function(self) 
  return ('Vec [%.2f,%.2f]'):format(self.x,self.y) 
end

-- Instantiate
function Vec.new(x,y)
  return setmetatable({x = x or 0, y = y or 0},Vec)
end

-- Addition
function Vec.__add(a,b)
  return Vec.new(a.x + b.x, a.y + b.y)
end

-- Substraction
function Vec.__sub(a,b)
  return Vec.new(a.x - b.x, a.y - b.y)
end

-- Mult. / Scaling
function Vec.__mul(a,b)
  if type(b) == 'number' then
    return Vec.new(a.x * b, a.y * b)
  end
  return Vec.new(a.x * b.x, a.y * b.y)
end

-- Divide. / Scaling
function Vec.__div(a,b)
  if type(b) == 'number' then
    return Vec.new(a.x / b, a.y / b)
  end
  return Vec.new(a.x / b.x, a.y / b.y)
end

-- Sets by component
function Vec:set(x,y)
  self.x, self.y = x, y
end

-- Clears to zero
function Vec:clear()
  self.x, self.y = 0, 0
end

-- Magnitude
function Vec:mag()
  return sqrt(self.x * self.x + self.y * self.y)
end  

-- Gets a copy of vector
function Vec:clone()
  return Vec.new(self.x, self.y)
end  

-- Clamping
function Vec:clamp(max)
  if abs(self.x) > max then self.x = (self.x/abs(self.x)) * max end
  if abs(self.y) > max then self.y = (self.y/abs(self.y)) * max end
  return self
end

function Vec:ToGrid(snap)
  local x = math.floor((self.x+(snap/2))/snap)*snap
  local y = math.floor((self.y+(snap/2))/snap)*snap
  return Vector2.new(x, y)
end

return setmetatable(Vec, 
  {__call = function(self,...) 
    return Vec:new(...) 
end})