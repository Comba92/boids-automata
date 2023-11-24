local QuadTree = {}
QuadTree.__index = QuadTree

local AABB = {}
AABB.__index = AABB

function AABB.new(x, y, w, h)
  local aabb = {
    x = x,
    y = y,
    hw = w/2,
    hh = h/2
  }

  return setmetatable(aabb, AABB)
end

function AABB:contains(p)
  return
    p.x > self.x - self.hw and
    p.x < self.x + self.hw and
    p.y > self.y - self.hh and
    p.y < self.y + self.hh
end

function AABB:intersects(other)
  return
    other.x + other.hw > self.x - self.hw and
    other.x - other.hw < self.x + self.hw and
    other.y + other.hh > self.y - self.hh and
    other.y - other.hh < self.y + self.hh
end


QuadTree.capacity = 10
function QuadTree.new(aabb)
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

function QuadTree.newFromRect(x, y, w, h)
  local aabb = AABB.new(x, y, w, h)
  return QuadTree.new(aabb)
end

function QuadTree:subdivide()
  local nw =
    AABB.new(self.box.x - self.box.hw/2, self.box.y - self.box.hh/2, self.box.hw, self.box.hh)

  local ne =
    AABB.new(self.box.x + self.box.hw / 2, self.box.y - self.box.hh / 2, self.box.hw, self.box.hh)

  local sw =
    AABB.new(self.box.x - self.box.hw / 2, self.box.y + self.box.hh / 2, self.box.hw, self.box.hh)

  local se =
      AABB.new(self.box.x + self.box.hw / 2, self.box.y + self.box.hh / 2, self.box.hw, self.box.hh)

  self.nw = QuadTree.new(nw)
  self.ne = QuadTree.new(ne)
  self.sw = QuadTree.new(sw)
  self.se = QuadTree.new(se)
end

function QuadTree:insert(boid)
  if not self.box:contains(boid.pos.copy) then return false end

  if self.nw == nil and #self.points < QuadTree.capacity then
    table.insert(self.points, boid)
    return true
  end

  if self.nw == nil then
    self:subdivide()
  end

  return self.nw:insert(boid) or self.ne:insert(boid)
    or self.sw:insert(boid) or self.se:insert(boid)
end

local function concat(dst, src)
  for _, e in ipairs(src) do
    table.insert(dst, e)
  end
end

function QuadTree:query(aabb)
  if not self.box:intersects(aabb) then return {} end

  local points = {}
  for _,p in ipairs(self.points) do
    if aabb:contains(p.pos) then table.insert(points, p) end
  end

  if self.nw == nil then return points end

  concat(points, self.nw:query(aabb))
  concat(points, self.ne:query(aabb))
  concat(points, self.sw:query(aabb))
  concat(points, self.se:query(aabb))

  return points
end

function AABB:debug()
  love.graphics.rectangle('line', self.x - self.hw, self.y - self.hh, self.hw * 2, self.hh * 2)
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
