package main

import "core:fmt"
import "core:math"
import "core:os"
import "core:strings"

main :: proc() {
	canvas_size := 600
	radius := cast(f32)(canvas_size) * 3.0 / 8.0
	center := cast(f32)(canvas_size) / 2.0

	c := canvas(canvas_size, canvas_size)
	defer canvas_destroy(c)

	twelve := point(0, 0, 1)

	for hour in 0 ..< 12 {
		angle := cast(f32)(hour) * math.PI / 6.0
		rotation := rotation_y(angle)
		position := matrix_multiply_tuple(rotation, twelve)

		x := cast(int)(center + position.x * radius)
		y := cast(int)(center - position.z * radius) // z becomes canvas y; flip for top-down

		if in_bounds(x, y, canvas_size, canvas_size) {
			write_pixel(&c, x, y, color(1, 1, 1))
		}
	}

	ppm := canvas_to_ppm(c)
	defer delete(ppm)
	os.write_entire_file("projectile.ppm", transmute([]byte)ppm)
}
