local QuadTree = {}
QuadTree.__index = QuadTree

local AABB = {}
AABB.__index = AABB

function AABB.new(x, y, dimension)
  local aabb = {
    x = x,
    y = y,
    halfSize = dimension/2,
  }

  return setmetatable(aabb, AABB)
end

function AABB:contains(p)
  return
    p.x > self.x - self.halfSize and
    p.x < self.x + self.halfSize and
    p.y > self.y - self.halfSize and
    p.y < self.y + self.halfSize
end

function AABB:intersects(other)
  return
    other.x + other.halfSize > self.x - self.halfSize and
    other.x - other.halfSize < self.x + self.halfSize and
    other.y + other.halfSize > self.y - self.halfSize and
    other.y - other.halfSize < self.y + self.halfSize
end


QuadTree.capacity = 4
function QuadTree.new(x, y, size)
  local aabb = AABB.new(x, y, size)
  local qt = {
    nw = nil,
    ne = nil,
    sw = nil,
    se = nil,
    box = aabb,
    points = {}
  }

  return setmetatable(qt, QuadTree)
end

function QuadTree:subdivide()
  self.nw =
    QuadTree.new(self.box.x - self.box.halfSize/2, self.box.y - self.box.halfSize/2, self.box.halfSize)

  self.ne =
    QuadTree.new(self.box.x + self.box.halfSize / 2, self.box.y - self.box.halfSize / 2, self.box.halfSize)

  self.sw =
    QuadTree.new(self.box.x - self.box.halfSize / 2, self.box.y + self.box.halfSize / 2, self.box.halfSize)

  self.se =
      QuadTree.new(self.box.x + self.box.halfSize / 2, self.box.y + self.box.halfSize / 2, self.box.halfSize)
end

function QuadTree:insert(p)
  if not self.box:contains(p) then return false end

  if self.nw == nil and #self.points < QuadTree.capacity then
    table.insert(self.points, p)
    return true
  end

  if self.nw == nil then
    self:subdivide()
  end

  return self.nw:insert(p) or self.ne:insert(p)
    or self.sw:insert(p) or self.se:insert(p)
end

local function concat(t1, t2)
  local new = {}

  for _, e in ipairs(t1) do
    table.insert(new, e)
  end
  for _, e in ipairs(t2) do
    table.insert(new, e)
  end

  return new
end

function QuadTree:query(aabb)
  local points = {}

  if not self.box:intersects(aabb) then return points end

  for _,p in ipairs(self.points) do
    if aabb:contains(p) then table.insert(points, p) end
  end

  if self.nw == nil then return points end

  points = concat(points, self.nw:query(aabb))
  points = concat(points, self.ne:query(aabb))
  points = concat(points, self.sw:query(aabb))
  points = concat(points, self.se:query(aabb))

  return points
end

function AABB:debug()
  love.graphics.rectangle('line', self.x - self.halfSize, self.y - self.halfSize, self.halfSize * 2, self.halfSize * 2)
end

function QuadTree:debug()
  self.box:debug()

  if self.nw == nil then return end

  self.nw:debug()
  self.ne:debug()
  self.sw:debug()
  self.se:debug()
end

function QuadTree:length()
  local count = 0
  count = count + #self.points
  if self.nw == nil then return count end

  count = count + self.nw:length()
  count = count + self.ne:length()
  count = count + self.sw:length()
  count = count + self.se:length()

  return count
end

return {newQuadTree = QuadTree.new, newAABB = AABB.new}
