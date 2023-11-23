package.path = package.path .. ";./libs/?.lua;D:/code/love2d/libs/?.lua"
Vector = require('brinevector')
QuadTree = require('quadtree')

function scaledToWorld(x, y)
  return x*Ctx.scale, y*Ctx.scale
end

function worldToScaled(x, y)
  return x/Ctx.scale, y/Ctx.scale
end

function getMouseToScaled()
  return worldToScaled(love.mouse.getPosition())
end

function love.load()
  _W, _H = love.window.getMode()
  local scale = 1

  Ctx = {
    window_w = _W,
    window_h = _H,
    w = _W/scale,
    h = _H/scale,
    scale = scale,
    sliders_h = 40,

    areas = false,
    trails = true,
    running = false,
    turning = false,
    follow = false,
    quadtree = false,

    quadtree_boids = 0
  }
  love.window.setMode(_W, _H + Ctx.sliders_h)

  local canvas = love.graphics.newCanvas(Ctx.w, Ctx.h)
  canvas:setFilter('nearest', 'nearest')
  local slidersCanvas = love.graphics.newCanvas(Ctx.window_w, Ctx.sliders_h)
  slidersCanvas:setFilter('nearest', 'nearest')
  Ctx.canvas = canvas
  Ctx.sliders_canvas = slidersCanvas

  Boid = require('boid')
  -- Boids outside the quadtree box aren't saved! 
  Screen = QuadTree.newAABB(Ctx.w / 2, Ctx.h / 2, Ctx.w + Boid.size*4, Ctx.h + Boid.size*4)

  Flock = {}
  for i = 1, 1000 do
    table.insert(Flock, Boid.new())
  end

  Sliders = require('sliders')
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.graphics.setLineStyle('rough')
  print("Dimensions: ", Ctx.w, Ctx.h)
end


function love.keypressed(key)
  if key == 'q' or key == 'escape' then
    love.event.quit()

  elseif key == 'space' then
    Ctx.running = not Ctx.running

  elseif key == 'a' then
    Ctx.areas = not Ctx.areas

  elseif key == 't' then
    Ctx.trails = not Ctx.trails

  elseif key == 'b' then
    Ctx.turning = not Ctx.turning

  elseif key == 'm' then
    Ctx.follow = not Ctx.follow

  elseif key == 'o' then
    Ctx.quadtree = not Ctx.quadtree
  end
end


function love.update(dt)
  Sliders:update()

  local mx, my = getMouseToScaled()
  if love.mouse.isDown(2) then
    table.insert(Flock, Boid.new(mx, my))
  end

  if not Ctx.running then return end

  if not Ctx.quadtree then
    for _, boid in ipairs(Flock) do
      boid:update(dt, Flock)
    end
    return
  end

  local qt = QuadTree.newQuadTree(Screen)
  for _, boid in ipairs(Flock) do
    qt:insert(boid)
  end

  for _, boid in ipairs(Flock) do
    boid:update_quadtree(dt, qt)
  end

  Ctx.quadtree_boids = qt:length()
end


function love.draw()
  love.graphics.print('Boids: ' .. #Flock, 10, 10)
  if Ctx.quadtree then 
    love.graphics.print("Quadtree ON: " .. Ctx.quadtree_boids, 10, 40)
  end
  love.graphics.print('FPS: ' .. love.timer.getFPS(), 10, 22)

  love.graphics.setCanvas(Ctx.canvas)
    love.graphics.clear()

    for _, boid in ipairs(Flock) do
      boid:draw()
    end

    -- local mx, my = getMouseToScaled()
    -- love.graphics.circle('line', mx, my, 5)

  love.graphics.setCanvas(Ctx.sliders_canvas)
    love.graphics.setColor(46/255, 46/255, 46/255)
    love.graphics.rectangle('fill', 0, 0, Ctx.window_w, Ctx.sliders_h)
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.line(0, 1, Ctx.window_w, 1)
    Sliders:draw()
    love.graphics.setColor(1, 1, 1)

  love.graphics.setCanvas()
  love.graphics.draw(Ctx.canvas, 0, 0, 0, Ctx.scale, Ctx.scale)
  love.graphics.draw(Ctx.sliders_canvas, 0, Ctx.window_h)
  Sliders:drawNames()
end