local Spring = {}
Spring.__index = Spring
function Spring.new(x, k, d)
  local spring = {}
  -- x: starting position, k: stiffness, d: dampening
  spring.x = x or 1
  spring.k = k or 100
  -- if d is 0, the spring will go on forever
  spring.d = d or 10
  spring.target_x = spring.x
  spring.v = 0
  return setmetatable(spring, Spring)
end

function Spring:update(dt)
  local a = -self.k * (self.x - self.target_x) - self.d * self.v
  self.v = self.v + a * dt
  self.x = self.x + self.v * dt
end

function Spring:pull(f, k, d)
  -- f: force
  if k then self.k = k end
  if d then self.d = d end
  self.x = self.x + f
end

return Spring