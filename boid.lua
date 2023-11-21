local Boid = {}
Boid.__index = Boid

local Size = 10

local Triangle = {
  -1*Size,1*Size, -1*Size,-1*Size, 1*Size,0*Size
}

Boid.speed = 200

function Boid.new(_x, _y, angle)
  local x = _x or love.math.random(W)
  local y = _y or love.math.random(H)
  local boid = {
    pos = Vector(x, y),
    vel = Vector(1, 0),
    angle = angle or 0
  }
  return setmetatable(boid, Boid)
end

function Boid:update(dt)
  self.pos = self.pos + self.vel * Boid.speed * dt
  self.angle = self.vel.angle
end

function Boid:seek(target)
  local direction = (target - self.pos).normalized
  self.vel = direction
end

function Boid:draw()
  love.graphics.push()
  love.graphics.translate(self.pos.x, self.pos.y)
  love.graphics.rotate(self.angle)
  love.graphics.polygon('line', Triangle)
  love.graphics.pop()
end

return Boid