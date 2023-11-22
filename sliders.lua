require('simple-slider')

local config = {
  track = 'line',
  knob = 'circle'
}

local height = Ctx.h - 5
local font = love.graphics.getFont()

local avoidiginSlider = newSlider(
  30, height, 50,
  1.5, 0.01, 3, function(v) Boid.avoiding = v end, config
)
avoidiginSlider.name = love.graphics.newText(font, "Avoidance")

local aligninSlider = newSlider(
  90, height, 50,
  0.5, 0.001, 1.5, function(v) Boid.matching = v end, config
)
aligninSlider.name = love.graphics.newText(font, "Aligning")

local cohesionSlider = newSlider(
  150, height, 50,
  0.3, 0.001, 1.5, function(v) Boid.centering = v end, config
)
cohesionSlider.name = love.graphics.newText(font, "Cohesion")


local protectedrangeSlider = newSlider(
  Ctx.w - 30, height, 50,
  10, 2, 25, function(v) Boid.protected_range = v end, config
)
protectedrangeSlider.name = love.graphics.newText(font, "Protected Range")

local viewrangeSlider = newSlider(
  Ctx.w - 90, height, 50,
  20, 5, 35, function(v) Boid.viewing_range = v end, config
)
viewrangeSlider.name = love.graphics.newText(font, "Viewing Range")

local maxspeedSlider = newSlider(
  Ctx.w - 160, height, 50,
  150, 50, 300, function(v)
    Boid.max_vel = v
    Boid.max_speed2 = 2 * Boid.max_vel * Boid.max_vel
  end, config
)
maxspeedSlider.name = love.graphics.newText(font, "MaxSpeed")

local minspeedSlider = newSlider(
  Ctx.w - 220, height, 50,
  100, 20, 250, function(v)
    Boid.min_vel = v
    Boid.min_speed2 = 2 * Boid.min_vel * Boid.min_vel
  end, config
)
minspeedSlider.name = love.graphics.newText(font, "MinSpeed")

local Sliders = {
  avoidiginSlider, aligninSlider, cohesionSlider,
  viewrangeSlider, protectedrangeSlider,
  maxspeedSlider, minspeedSlider
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
      local x, y = scaledToWorld(slider.x - slider.name:getWidth()/4, slider.y - 12)
      love.graphics.draw(slider.name, x, y)
    end
  end
end

function Sliders:draw()
  for _, slider in ipairs(self) do
    slider:draw()
  end
end

return Sliders
