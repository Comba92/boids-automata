local Boid = {}
Boid.__index = Boid
local Trail = require('trail')

Boid.size    = 3
Boid.max_vel = 150
Boid.min_vel = 100
Boid.max_speed2 = 2 * Boid.max_vel * Boid.max_vel
Boid.min_speed2 = 2 * Boid.min_vel * Boid.min_vel
Boid.viewing_range   = 20
Boid.protected_range = 10

Boid.avoiding  = 1.5
Boid.matching  = 0.2
Boid.centering = 0.5

local Triangle = {
  -1 * Boid.size, 1 * Boid.size, -1 * Boid.size, -1 * Boid.size, 1 * Boid.size, 0 * Boid.size
}

Boid.delay = 0.05

function Boid.new(_x, _y, _vx, _vy, angle)
  local x = _x or love.math.random(Ctx.w)
  local y = _y or love.math.random(Ctx.h)

  local vx = _vx or love.math.random(-Boid.max_vel, Boid.max_vel)
  local vy = _vy or love.math.random(-Boid.max_vel, Boid.max_vel)

  local boid = {
    pos = Vector(x, y),
    vel = Vector(vx, vy),
    acc = Vector(),
    angle = angle or 0,
    trail = Trail.new(),
    timer = 0
  }
  return setmetatable(boid, Boid)
end


local function wrapAround(vec)
  local w, h = Ctx.w, Ctx.h
  local new = vec.copy
  local radius = Boid.size * 1.25
  if vec.x + radius < 0 then
    new.x = w + radius
  elseif vec.x - radius > w then
    new.x = -radius
  end
  if vec.y + radius < 0 then
    new.y = h + radius
  elseif vec.y - radius > h then
    new.y = -radius
  end

  return new
end

function Boid:update(dt, flock)
  if Ctx.trails and self.timer > Boid.delay then
    self.timer = 0
    local back = Vector(-1*Boid.size, 0):angled(self.angle)
    self.trail:update(self.pos - back)
  end
  self.timer = self.timer + dt

  self:separe(flock)
  self:align(flock)
  self:cohere(flock)

  self.vel = self.vel + self.acc
  self.pos = self.pos + self.vel * dt
  self.pos = wrapAround(self.pos)
  self.angle = self.vel.angle
  self.acc = self.acc * 0

  if self.vel.length2 > Boid.max_speed2 then
    self.vel = self.vel:trim(Boid.max_vel)
  end
  if self.vel.length2 < Boid.min_speed2 then
    self.vel = self.vel.normalized * Boid.min_vel
  end
end

function Boid:seek(target)
  local direction = (target - self.pos).angle
  self.vel = self.vel:angled(direction)
end

function Boid:separe(flock)
  local close = Vector()

  for _, other in ipairs(flock) do
    local dist = (other.pos - self.pos).length2
    if dist ~= 0 and dist < Boid.protected_range * Boid.protected_range then
      close = close + (self.pos - other.pos)
    end
  end

  self.vel = self.vel + close * Boid.avoiding
end

function Boid:align(flock)
  local neighboring = 0
  local avg_vel = Vector()

  for _, other in ipairs(flock) do
    local dist = (other.pos - self.pos).length2
    if other ~= self and dist < Boid.viewing_range * Boid.viewing_range then
      avg_vel = avg_vel + other.vel
      neighboring = neighboring + 1
    end
  end

  if neighboring > 0 then
    avg_vel = avg_vel / neighboring
    self.vel = self.vel + ((avg_vel - self.vel) * Boid.matching)
  end
end

function Boid:cohere(flock)
  local neighboring = 0
  local avg_pos = Vector()

  for _, other in ipairs(flock) do
    local dist = (other.pos - self.pos).length2
    if dist ~= 0 and dist < Boid.viewing_range * Boid.viewing_range then
      avg_pos = avg_pos + other.pos
      neighboring = neighboring + 1
    end
  end

  if neighboring > 0 then
    avg_pos = avg_pos / neighboring
    self.vel = self.vel + ((avg_pos - self.pos) * Boid.centering)
  end
end

function Boid:draw()
  if Ctx.trails then self.trail:draw() end
  if Ctx.areas then self:drawAreas() end

  love.graphics.push()
  love.graphics.setColor(1, 1, 1)
  love.graphics.translate(self.pos.x, self.pos.y)
  love.graphics.rotate(self.angle)
  love.graphics.polygon('line', Triangle)

  love.graphics.pop()
end

function Boid:drawAreas()
  love.graphics.setColor(134 / 255, 121 / 255, 121 / 255, 0.7)
  love.graphics.circle('line', self.pos.x, self.pos.y, Boid.viewing_range)

  love.graphics.setColor(61 / 255, 41 / 255, 41 / 255)
  love.graphics.circle('line', self.pos.x, self.pos.y, Boid.protected_range)
end

function Boid:copy()
  return Boid.new(self.pos.x, self.pos.y, self.vel.x, self.vel.y, self.angle)
end

return Boid