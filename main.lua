package.path = package.path .. ";./libs/?.lua"
Vector = require('brinevector')

function worldToScaled(x, y)
  return x/ctx.scale, y/ctx.scale
end

function getMouseToScaled()
  return worldToScaled(love.mouse.getPosition())
end

function love.load()
  local _W, _H = love.window.getMode()
  local scale = 2

  local ctx = {
    w = _W/scale,
    h = _H/scale,
    scale = scale,
  }
  local canvas = love.graphics.newCanvas(ctx.w, ctx.h)
  canvas:setFilter('nearest', 'nearest')
  ctx.canvas = canvas
  _G.ctx = ctx

  Sliders = require('sliders')
  Boid = require('boid')
  Flock = {}
  for i = 1, 100 do
    table.insert(Flock, Boid.new())
  end

  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.graphics.setLineStyle('rough')
  print("Dimensions: " .. ctx.w .. " " .. ctx.h)
end


function love.keypressed(key)
  if key == 'q' or key == 'escape' then
    love.event.quit()
  end
end

function love.update(dt)
  local mx, my = getMouseToScaled()

  if love.mouse.isDown(2) then
    table.insert(Flock, Boid.new(mx, my))
  end

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
  love.graphics.setCanvas(ctx.canvas)
    love.graphics.clear()

    for _, boid in ipairs(Flock) do
      boid:draw()
    end

    for _, slider in ipairs(Sliders) do
      slider:draw()
    end

    local mx, my = love.mouse.getPosition()
    love.graphics.circle('line', mx/ctx.scale, my/ctx.scale, 10)
  love.graphics.setCanvas()
  love.graphics.draw(ctx.canvas, 0, 0, 0, ctx.scale, ctx.scale)
end