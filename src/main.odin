package main

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
	canvas_width := 900
	canvas_height := 550
	c := canvas(canvas_width, canvas_height)
	defer canvas_destroy(c)

	p := Projectile {
		position = point(0, 1, 0),
		velocity = scale(normalize(vector(1, 1.8, 0)), 11.25),
	}
	e := Environment {
		gravity = vector(0, -0.1, 0),
		wind    = vector(-0.01, 0, 0),
	}

	for p.position.y > 0 {
		x := int(p.position.x)
		y := canvas_height - int(p.position.y) // flip y-axis

		// Only plot points within the canvas bounds
		if x >= 0 && x < canvas_width && y >= 0 && y < canvas_height {
			write_pixel(&c, x, y, color(1, 0, 0))
		}

		p = tick(e, p)
	}

	ppm := canvas_to_ppm(c)
	defer delete(ppm)
	os.write_entire_file("projectile.ppm", transmute([]byte)ppm)
}
