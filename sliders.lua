require('simple-slider')

local config = {
  track = 'line',
  knob = 'circle'
}

local avoidiginSlider = newSlider(
  30, ctx.h, 20,
  1.5,0, 2, function(v) Boid.avoiding = v end, config
)

local viewrangeSlider = newSlider(
  30, ctx.h - 10, 50,
  20, 5, 30, function(v) Boid.viewing_range = v end, config
)

local Sliders = {viewrangeSlider}
return Sliders
