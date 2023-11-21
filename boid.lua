local Boid = {}
Boid.__index = Boid

local Size = 5

local Triangle = {
  -1*Size,1*Size, -1*Size,-1*Size, 1*Size,0*Size
}

Boid.max_speed = 100
Boid.min_speed = 20
Boid.view      = 25
Boid.space     = 5

Boid.avoiding  = 1
Boid.matching  = 1
Boid.centering = 1

function randomSign()
  local signs = {-1, 1}
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
  if vec.x + Size < 0 then new.x = W + Size
  elseif vec.x - Size > W then new.x = -Size
  elseif vec.y + Size < 0 then new.y = H + Size
  elseif vec.y - Size > W then new.y = -Size
  end

  return new
end

function Boid:speed()
  return self.vel.length
end

function Boid:update(dt)
  self.pos = self.pos + self.vel * dt
  self.pos = wrap_around(self.pos)
  self.angle = self.vel.angle
end

function Boid:seek(target)
  local direction = (target - self.pos).normalized
  self.vel = direction
end

function Boid:separe(flock)
  local close = Vector()

  for _, other in ipairs(flock) do
    local dist = (other.pos - self.pos).length
    if dist ~= 0 and dist < Boid.space then
      close = close + (self.pos - other.pos)
    end
  end

  self.vel = close * Boid.avoiding
end

function Boid:align(flock)
  local neighboring = 0
  local avg_vel = Vector()

  for _, other in ipairs(flock) do
    local dist = (other.pos - self.pos).length
    if other ~= self and dist < Boid.view then
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
    local dist = (other.pos - self.pos).length
    if dist ~= 0 and dist < Boid.view then
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
  love.graphics.circle('line', self.pos.x, self.pos.y, Boid.view)

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