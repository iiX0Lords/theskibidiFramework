local function checkCollision(a, b)
    local a_left = a.Position.x
    local a_right = a.Position.x + a.Size.x
    local a_top = a.Position.y
    local a_bottom = a.Position.y + a.Size.y

    local b_left = b.Position.x
    local b_right = b.Position.x + b.Size.x
    local b_top = b.Position.y
    local b_bottom = b.Position.y + b.Size.y
    return  a_right > b_left
        and a_left < b_right
        and a_bottom > b_top
        and a_top < b_bottom
end
return checkCollision