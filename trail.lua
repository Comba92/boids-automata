local Trail = {}
Trail.__index = Trail

Trail.size = 1
Trail.length = 8

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
  for _, particle in ipairs(self.history) do
    love.graphics.points(particle.x, particle.y)
  end
end

return Trail