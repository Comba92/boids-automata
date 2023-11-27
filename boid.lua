local Boid = {}
Boid.__index = Boid
local Trail = require('trail')

Boid.size    = 4
Boid.max_vel = 120
Boid.min_vel = 90
Boid.viewing_range   = 22
Boid.protected_range = 10

Boid.avoiding  = 1
Boid.alignin  = 0.001
-- unused
-- Boid.cohesion = 0.3
Boid.mass = 30
Boid.delay = 0.05

-- necessary for fluid steering, the higher the better
Boid.max_steering = 200

local Triangle = {
  -1 * Boid.size, 1 * Boid.size, -1 * Boid.size, -1 * Boid.size, 1 * Boid.size, 0 * Boid.size
}

function Boid.new(_x, _y, _vx, _vy, angle)
  local x = _x or love.math.random(Ctx.w)
  local y = _y or love.math.random(Ctx.h)

  local vx = _vx or love.math.random(-Boid.max_vel, Boid.max_vel)
  local vy = _vy or love.math.random(-Boid.max_vel, Boid.max_vel)

  local boid = {
    pos = Vector(x, y),
    vel = Vector(vx, vy),
    angle = angle or 0,
    trail = Trail.new(),
    timer = 0
  }
  return setmetatable(boid, Boid)
end


function Boid:wrapAroundBorders()
  local w, h = Ctx.w, Ctx.h
  local new = self.pos
  local radius = Boid.size * 1.25
  if self.pos.x + radius < 0 then
    new.x = w + radius
  elseif self.pos.x - radius > w then
    new.x = -radius
  end
  if self.pos.y + radius < 0 then
    new.y = h + radius
  elseif self.pos.y - radius > h then
    new.y = -radius
  end

  self.pos = new
end

function Boid:turnOnBorders()
  local w, h = Ctx.w, Ctx.h
  local radius = Boid.size * 1.25

  local border = 50
  if self.pos.x + radius < 0 + border or
    self.pos.x - radius > w - border or
    self.pos.y + radius < 0 + border or
    self.pos.y - radius > h - border then
      self:seek(Vector(w/2, h/2))
  end
end

function Boid:update(dt, flock)
  if not Ctx.trails and self.trail ~= nil then
    self.trail:clear()
  end

  if Ctx.trails and self.timer > Boid.delay then
    self.timer = 0
    local back = Vector(-1*Boid.size, 0):angled(self.angle)
    self.trail:update(self.pos - back)
  end
  self.timer = self.timer + dt

  self:separe(flock)
  self:align(flock)
  self:cohere(flock)

  self.pos = self.pos + self.vel * dt

  if Ctx.wrapping then self:wrapAroundBorders()
  else self:turnOnBorders() end

  if Ctx.follow then
    local mouse = Vector(getMouseToScaled())
    self:seek(mouse)
  end

  self.angle = self.vel.angle
  self.vel = self.vel:trim(Boid.max_vel)
  if self.vel.length < Boid.min_vel then
    self.vel = self.vel.normalized * Boid.min_vel
  end
end

function Boid:update_quadtree(dt, qt)
  local aabb = QuadTree.newAABB(self.pos.x, self.pos.y, Boid.viewing_range, Boid.viewing_range)
  local neighboring = qt:query(aabb)
  self:update(dt, neighboring)
end

-- https://code.tutsplus.com/understanding-steering-behaviors-seek--gamedev-849t
function Boid:seek(target)
  local desired = (target - self.pos).normalized * Boid.max_vel
  local steering = (desired - self.vel):trim(Boid.max_steering) / Boid.mass
  self.vel = (self.vel + steering):trim(Boid.max_vel)
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
    self.vel = self.vel + ((avg_vel - self.vel) * Boid.alignin)
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
    self:seek(avg_pos)
    -- self.vel = self.vel + ((avg_pos - self.pos) * Boid.cohesion)
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