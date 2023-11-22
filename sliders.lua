require('simple-slider')

local config = {
  track = 'line',
  knob = 'circle'
}

local height = Ctx.h - 5

local avoidiginSlider = newSlider(
  30, height, 50,
  Boid.avoiding, 0.01, 2, function(v) Boid.avoiding = v end, config
)
avoidiginSlider.name = "Avoidance"

local aligninSlider = newSlider(
  90, height, 50,
  Boid.alignin, 0.0001, 0.01, function(v) Boid.alignin = v end, config
)
aligninSlider.name = "Aligning"

local cohesionSlider = newSlider(
  150, height, 50,
  Boid.cohesion, 0.001, 1, function(v) Boid.cohesion = v end, config
)
cohesionSlider.name = "Cohesion"


local protectedrangeSlider = newSlider(
  Ctx.w - 30, height, 50,
  Boid.protected_range, 2, 25, function(v) Boid.protected_range = v end, config
)
protectedrangeSlider.name = "Protection"

local viewrangeSlider = newSlider(
  Ctx.w - 90, height, 50,
  Boid.viewing_range, 5, 35, function(v) Boid.viewing_range = v end, config
)
viewrangeSlider.name = "View"

local maxspeedSlider = newSlider(
  Ctx.w - 160, height, 50,
  Boid.max_vel, 50, 300, function(v)
    Boid.max_vel = v
  end, config
)
maxspeedSlider.name = "MaxSpeed"

local steeringSlider = newSlider(
  Ctx.w - 220, height, 50,
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

function Sliders:update(mx, my)
  for _, slider in ipairs(Sliders) do
    slider:update(mx, my)
  end
end

function Sliders:drawNames()
  for _, slider in ipairs(self) do
    if slider.name then
      local x, y = scaledToWorld(slider.x - slider.length/2, slider.y - 12)
      love.graphics.print(slider.name .. ": " .. slider:getValue(), x, y)
    end
  end
end

function Sliders:draw()
  for _, slider in ipairs(self) do
    slider:draw()
  end
end

return Sliders
