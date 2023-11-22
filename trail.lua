local Trail = {}
Trail.__index = Trail

Trail.size = 2
Trail.length = 4

function Trail.new()
  local trail = {
    head = 0,
    history = {}
  }

  return setmetatable(trail, Trail)
end

function Trail:update(vec)
  self.history[self.head] = vec
  self.head = ((self.head + 1) % Trail.length)
end

function Trail:draw()
  love.graphics.setColor(1, 1, 1, 0.7)
  for _, particle in ipairs(self.history) do
    love.graphics.points(particle.x, particle.y)
  end
  love.graphics.setColor(1, 1, 1)
end

function Trail:clear()
  self.history = {}
end

return Trail