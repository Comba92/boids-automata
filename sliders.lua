require('simple-slider')

local config = {
  track = 'line',
  knob = 'circle'
}

local avoidiginSlider = newSlider(
  30, Ctx.h - 10, 50,
  1.5, 0.01, 3, function(v) Boid.avoiding = v end, config
)
local aligninSlider = newSlider(
  90, Ctx.h - 10, 50,
  0.5, 0.001, 1.5, function(v) Boid.matching = v end, config
)
local cohesionSlider = newSlider(
  150, Ctx.h - 10, 50,
  0.3, 0.001, 1.5, function(v) Boid.centering = v end, config
)
local viewrangeSlider = newSlider(
  Ctx.w - 90, Ctx.h - 10, 50,
  20, 5, 35, function(v) Boid.viewing_range = v end, config
)
local protectedrangeSlider = newSlider(
  Ctx.w - 30, Ctx.h - 10, 50,
  10, 2, 25, function(v) Boid.protected_range = v end, config
)

local Sliders = {
  avoidiginSlider, aligninSlider, cohesionSlider,
  viewrangeSlider, protectedrangeSlider
}
return Sliders
