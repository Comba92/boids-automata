require('simple-slider')

local config = {
  track = 'line',
  knob = 'circle'
}

local height = 28
local size = 120
local gap = size + 20

local avoidiginSlider = newSlider(
  100, height, size,
  Boid.avoiding, 0.01, 2, function(v) Boid.avoiding = v end, config
)
avoidiginSlider.name = "Avoidance"

local aligninSlider = newSlider(
  100 + gap, height, size,
  Boid.alignin, 0.0001, 0.01, function(v) Boid.alignin = v end, config
)
aligninSlider.name = "Aligning"

local cohesionSlider = newSlider(
  100 + gap*2, height, size,
  Boid.mass, 50, 15, function(v) Boid.mass = v end, config
)
cohesionSlider.name = "Cohesion"


local protectedrangeSlider = newSlider(
  Ctx.window_w - 100, height, size,
  Boid.protected_range, 2, 25, function(v) Boid.protected_range = v end, config
)
protectedrangeSlider.name = "Protection"

local viewrangeSlider = newSlider(
  Ctx.window_w - (100 + gap), height, size,
  Boid.viewing_range, 5, 35, function(v) Boid.viewing_range = v end, config
)
viewrangeSlider.name = "View"

local maxspeedSlider = newSlider(
  Ctx.window_w - (100 + gap * 2), height, size,
  Boid.max_vel, 50, 300, function(v)
    Boid.max_vel = v
  end, config
)
maxspeedSlider.name = "MaxSpeed"

local steeringSlider = newSlider(
  Ctx.window_w - (100 + gap * 3), height, size,
  Boid.max_steering, 50, 400, function(v)
    Boid.max_steering = v
  end, config
)
steeringSlider.name = "Steering"

local Sliders = {
  avoidiginSlider, aligninSlider, cohesionSlider,
  viewrangeSlider, protectedrangeSlider,
  maxspeedSlider, steeringSlider
}
Sliders.__index = Sliders

function Sliders:update()
  local mx, my = love.mouse.getPosition()
  for _, slider in ipairs(Sliders) do
    slider:update(mx, my - Ctx.window_h)
  end
end

function Sliders:drawNames()
  for _, slider in ipairs(self) do
    if slider.name then
      local x, y = slider.x - slider.length/2, Ctx.window_h + Ctx.sliders_h - slider.y - 6
      local value = math.floor( slider:getValue() * 1000000) / 1000000
      love.graphics.print(slider.name .. ": " ..value, x, y)
    end
  end
end

function Sliders:draw()
  for _, slider in ipairs(self) do
    slider:draw()
  end
end

return Sliders
