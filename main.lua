package.path = package.path .. ";D:/code/love2d/libs/?.lua"
local Boid = require('boid')
require('slider')
Vector = require('brinevector')

love.graphics.setDefaultFilter('nearest', 'nearest')
love.graphics.setLineStyle('rough')

_W, _H = love.window.getMode()
Scale = 2
W, H = _W/Scale, _H/Scale
Canvas = love.graphics.newCanvas(W, H)

local speedSlider = newSlider(W/2, H - 20, 200, 50, 50, 500, 
  function(v) Boid.max_vel = v end, {
  track = 'line',
  knob = 'circle'
})
local Sliders = { }

function worldToScaled(x, y)
  return x/Scale, y/Scale
end

function getMouseToScaled()
  return worldToScaled(love.mouse.getPosition())
end

local Flock = {}
for i=1,20 do
  table.insert(Flock, Boid.new())
end

function love.load()
  print("dimensions: " .. W .. " " .. H)
end

function love.keypressed(key)
  if key == 'q' or key == 'escape' then
    love.event.quit()
  end
end

function love.update(dt)
  require('lurker').update()
  local mx, my = getMouseToScaled()
  local m = Vector(mx, my)

  local new_flock = {}
  for _, boid in ipairs(Flock) do
    local new_boid = boid:copy()
    new_boid:separe(Flock)
    new_boid:align(Flock)
    new_boid:cohere(Flock)
    new_boid:update(dt)
    table.insert(new_flock, new_boid)
  end
  Flock = new_flock

  for _, slider in ipairs(Sliders) do
    slider:update(mx, my)
  end
end

function love.draw()
  love.graphics.setCanvas(Canvas)
    love.graphics.clear()

    for _, boid in ipairs(Flock) do
      boid:draw()
    end

    for _, slider in ipairs(Sliders) do
      slider:draw()
    end

    local mx, my = love.mouse.getPosition()
    love.graphics.circle('line', mx/Scale, my/Scale, 10)

  love.graphics.setCanvas()
  love.graphics.draw(Canvas, 0, 0, 0, Scale, Scale)
end