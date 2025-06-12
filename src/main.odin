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
	shape.material.color = color(1, 0.2, 1)

	light := point_light(point(-10, 10, -10), color(1, 1, 1))

	for y in 0 ..< canvas_pixels {
		world_y := half - pixel_size * f32(y)
		for x in 0 ..< canvas_pixels {
			world_x := -half + pixel_size * f32(x)

			world_position := point(world_x, world_y, wall_z)
			direction := normalize(sub(world_position, ray_origin))
			r := ray(ray_origin, direction)

			xs, count := intersect(&shape, r)
			hit_result := hit(xs[:])
			if hit_result != nil {
				point_hit := position(r, hit_result.t)
				normal_at_point := normal_at(hit_result.object, point_hit)
				eye := -r.direction
				lit_color := lighting(
					hit_result.object.material,
					light,
					point_hit,
					eye,
					normal_at_point,
				)
				write_pixel(&canvas, x, y, lit_color)
			}
		}
	}

	ppm := canvas_to_ppm(canvas)
	defer delete(ppm)
	os.write_entire_file("projectile.ppm", transmute([]byte)ppm)
}
