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
  local scale = 2

  Ctx = {
    window_w = _W,
    window_h = _H,
    w = _W/scale,
    h = _H/scale,
    scale = scale,
    sliders_h = 40,

    debug = false,
    areas = false,
    trails = true,
    running = false,
    wrapping = false,
    follow = false,
    quadtree = false,
    quadtree_boids = nil
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
  Ctx.quadtree_boids = QuadTree.newQuadTree(Screen)

  Flock = {}
  for i = 1, 200 do
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

  elseif key == 'c' then
    Flock = {}

  elseif key == 'a' then
    Ctx.areas = not Ctx.areas

  elseif key == 't' then
    Ctx.trails = not Ctx.trails

  elseif key == 'b' then
    Ctx.wrapping = not Ctx.wrapping

  elseif key == 'm' then
    Ctx.follow = not Ctx.follow

  elseif key == 'o' then
    Ctx.quadtree = not Ctx.quadtree

  elseif key == 's' then
    Ctx.scale = (Ctx.scale+1) % 3
    if Ctx.scale == 0 then Ctx.scale = 3 end

    Ctx.w = Ctx.window_w/Ctx.scale
    Ctx.h = Ctx.window_h/Ctx.scale
    Ctx.canvas = love.graphics.newCanvas(Ctx.w, Ctx.h)
    Ctx.canvas:setFilter('nearest', 'nearest')

  elseif key == 'd' then
    if not Ctx.debug then
      Ctx.debug = true
      Ctx.areas = true
      Ctx.trails = false
      Ctx.quadtree = true
    else
      Ctx.debug = false
      Ctx.trails = true
      Ctx.areas = false
      Ctx.quadtree = false
    end
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
  else
    local qt = QuadTree.newQuadTree(Screen)
    for _, boid in ipairs(Flock) do
      qt:insert(boid)
    end

    for _, boid in ipairs(Flock) do
      boid:update_quadtree(dt, qt)
    end

    Ctx.quadtree_boids = qt
  end
end


function love.draw()
  love.graphics.print('Boids: ' .. #Flock, 10, 10)
  love.graphics.print('FPS: ' .. love.timer.getFPS(), 10, 22)

  if Ctx.quadtree then
    love.graphics.print("Quadtree ON: " .. Ctx.quadtree_boids:length(), 10, 40)
  end
  if Ctx.wrapping then
    love.graphics.print("Borders Wrapping ON", Ctx.window_w - 141, 10)
  end
  if Ctx.follow then
    love.graphics.print("Mouse follow ON", Ctx.window_w - 108, 22)
  end


  love.graphics.setCanvas(Ctx.canvas)
    love.graphics.clear()

    for _, boid in ipairs(Flock) do
      boid:draw()
    end
  
    if Ctx.debug then Ctx.quadtree_boids:debug() end

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