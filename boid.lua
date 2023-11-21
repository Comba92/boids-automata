local Boid = {}
Boid.__index = Boid

Boid.size = 5
Boid.max_speed = 100
Boid.min_speed = 10
Boid.view      = 25
Boid.space     = 5

Boid.avoiding  = 1
Boid.matching  = 1
Boid.centering = 1

local Triangle = {
  -1 * Boid.size, 1 * Boid.size, -1 * Boid.size, -1 * Boid.size, 1 * Boid.size, 0 * Boid.size
}

function randomSign()
  local signs = {-1, 1, -1, 1}
  return signs[math.random(#signs)]
end

function Boid.new(_x, _y, _vx, _vy, angle)
  local x = _x or love.math.random(W)
  local y = _y or love.math.random(H)

  local vx = _vx or randomSign() * love.math.random(
    Boid.min_speed, Boid.max_speed
  )
  local vy = _vy or randomSign() * love.math.random(
    Boid.min_speed, Boid.max_speed
  )

  local boid = {
    pos = Vector(x, y),
    vel = Vector(vx, vy),
    angle = angle or 0
  }
  return setmetatable(boid, Boid)
end

function wrap_around(vec)
  local new = vec.copy
  local radius = Boid.size*1.25
  if vec.x + radius < 0 then new.x = W + radius
  elseif vec.x - radius > W then new.x = -radius
  end
  if vec.y + radius < 0 then new.y = H + radius
  elseif vec.y - radius > H then new.y = -radius
  end

  return new
end

function Boid:update(dt)
  -- TODO: speed clamping
  self.pos = self.pos + self.vel * dt
  self.pos = wrap_around(self.pos)
  self.angle = self.vel.angle
end

function Boid:seek(target)
  local direction = (target - self.pos).angle
  self.vel = self.vel:angled(direction)
end

function Boid:separe(flock)
  local close = Vector()

  for _, other in ipairs(flock) do
    local dist = (other.pos - self.pos).length2
    if dist ~= 0 and dist < Boid.space * Boid.space then
      close = close + (self.pos - other.pos)
    end
  end

  self.vel = close * Boid.avoiding
end

function Boid:align(flock)
  local neighboring = 0
  local avg_vel = Vector()

  for _, other in ipairs(flock) do
    local dist = (other.pos - self.pos).length2
    if other ~= self and dist < Boid.view * Boid.view then
      avg_vel = avg_vel + other.vel
      neighboring = neighboring + 1
    end
  end

  if neighboring > 0 then
    avg_vel = avg_vel / neighboring
    self.vel = (avg_vel - self.vel) * Boid.matching
  end
end

function Boid:cohere(flock)
  local neighboring = 0
  local avg_pos = Vector()

  for _, other in ipairs(flock) do
    local dist = (other.pos - self.pos).length2
    if dist ~= 0 and dist < Boid.view * Boid.view then
      avg_pos = avg_pos + other.pos
      neighboring = neighboring + 1
    end
  end

  if neighboring > 0 then
    avg_pos = avg_pos / neighboring
    self.vel = (avg_pos - self.pos) * Boid.centering
  end
end

function Boid:draw()
  --love.graphics.circle('line', self.pos.x, self.pos.y, Boid.view)

  love.graphics.push()
  love.graphics.translate(self.pos.x, self.pos.y)
  love.graphics.rotate(self.angle)
  love.graphics.polygon('line', Triangle)

  love.graphics.pop()
end

function Boid:copy()
  return Boid.new(self.pos.x, self.pos.y, self.vel.x, self.vel.y, self.angle)
end


return Boid