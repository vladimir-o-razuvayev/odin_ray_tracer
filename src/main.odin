package main

import "core:fmt"
import "core:math"
import "core:os"

main :: proc() {
	canvas_pixels := 100
	wall_size: f32 = 7.0
	pixel_size := wall_size / f32(canvas_pixels)
	half := wall_size / 2.0

	ray_origin := point(0, 0, -5)
	wall_z: f32 = 10.0
	red := color(1, 0, 0)

	canvas := canvas(canvas_pixels, canvas_pixels)
	shape := unit_sphere()

	for y in 0 ..< canvas_pixels {
		world_y := half - pixel_size * f32(y)
		for x in 0 ..< canvas_pixels {
			world_x := -half + pixel_size * f32(x)

			position := point(world_x, world_y, wall_z)
			direction := normalize(sub(position, ray_origin))
			r := ray(ray_origin, direction)

			xs, count := intersect(&shape, r)
			if hit(xs[:]) != nil do write_pixel(&canvas, x, y, red)
		}
	}

	ppm := canvas_to_ppm(canvas)
	defer delete(ppm)
	os.write_entire_file("projectile.ppm", transmute([]byte)ppm)
}
