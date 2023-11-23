package.path = package.path .. ";./libs/?.lua;D:/code/love2d/libs/?.lua"
QuadTree = require('quadtree')
Vector = require('brinevector')

W, H = love.window.getMode()

local size = 400
local aabb = QuadTree.newAABB(W/2, H/2, size)
Q = QuadTree.newQuadTree(W/2, H/2, size)

Points = {}

function love.load()
end

function love.mousepressed()
  local mx, my = love.mouse.getPosition()
  Q:insert(Vector(mx, my))
end

function love.draw()
  local points = Q:query(aabb)

  for _, p in ipairs(points) do
    love.graphics.circle('fill', p.x, p.y, 10)
  end

  love.graphics.print(Q:length(), 10, 10)

  Q:debug()
  -- love.graphics.rectangle('line', Q.box.x-size, Q.box.y-size, size*2, size*2)

  local mx, my = love.mouse.getPosition()
  love.graphics.circle('line', mx, my, 50)
end