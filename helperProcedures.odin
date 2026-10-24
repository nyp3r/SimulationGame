package main

import rl "vendor:raylib"
import "core:math/noise"

DirectionTo :: proc(from: rl.Vector2, to: rl.Vector2) -> rl.Vector2 {
  return rl.Vector2Normalize(to - from)
}
DistanceTo :: proc(from: rl.Vector2, to: rl.Vector2) -> f32 {
  return rl.Vector2Length(to - from);
}
RunnigSkillToMovementSpeed :: proc(running: int) -> f32 {
  return f32((running + 10) * 5)
}

IndexToCoordinatesRaylib :: proc(
	i: int,
) -> (
	coordinates: rl.Vector2,
	error: string,
) {
	if i < 0 || i >= WORLD_WIDTH * WORLD_HEIGHT {
		error = "index too high or negative"
		return
	}

	coordinates.x = f32(i % WORLD_WIDTH) * f32(TILE_SIZE)
	coordinates.y =
		f32((i / WORLD_WIDTH) % WORLD_HEIGHT) *
		f32(TILE_SIZE)
	return
}
IndexToCoordinatesNoise :: proc(
	i: int,
) -> (
	coordinates: noise.Vec2,
	error: string,
) {
	if i < 0 || i >= WORLD_WIDTH * WORLD_HEIGHT {
		error = "index too high or negative"
		return
	}

	coordinates.x = f64(i % WORLD_WIDTH) * f64(TILE_SIZE)
	coordinates.y =
		f64((i / WORLD_WIDTH) % WORLD_HEIGHT) *
		f64(TILE_SIZE)
	return
}
