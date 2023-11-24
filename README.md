# 🐦 Boids - Flocking simulation in Lua Love2D
Love2D implementation of the Boids simulation.
https://en.wikipedia.org/wiki/Boids

- <kbd>Space</kbd> Pause/Unpause
- <kbd>Right Click</kbd> Spawn Boids
- <kbd>C</kbd> Remove all boids
- <kbd>A</kbd> Show/Hide viewing areas
- <kbd>T</kbd> Show/Hide trails
- <kbd>B</kbd> Enable/Disable turning on borders
- <kbd>M</kbd> Enable/Disable mouse follwing
- <kbd>O</kbd> Enable/Disable quadtree for collission checking (performance is worse though)
- <kbd>S</kbd> Change window scaling (pixelated look!). There are 3 scalings: Big, Medium (Default), Small.
- <kbd>D</kbd> Debug mode

![preview](images/preview_new.gif)

## Build
The project requires [Love2D](https://love2d.org/).
Simply run:
```
love .
```
on the project's root.

## References
- Boids simulation: https://vanhunteradams.com/Pico/Animal_Movement/Boids-algorithm.html
- Boids simulation in p5: https://p5js.org/examples/simulate-flocking.html
- Steering behaviour: https://code.tutsplus.com/understanding-steering-behaviors-seek--gamedev-849t
- Love2D sliders: https://love2d.org/forums/viewtopic.php?t=80711
- Love2D Wiki: https://love2d.org/wiki/Main_Page
- Spatial Hash: https://www.youtube.com/watch?v=i0OHeCj7SOw