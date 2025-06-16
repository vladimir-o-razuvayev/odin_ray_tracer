package main

import "core:fmt"
import "core:math"
import "core:os"

main :: proc() {
	// The floor is an extremely flattened sphere with a matte texture.
	floor := unit_sphere()
	floor.transform = scaling(10, 0.01, 10)
	floor.material = default_material()
	floor.material.color = color(1, 0.9, 0.9)
	floor.material.specular = 0
	// The wall needs to be scaled, then rotated in x, then rotated in y,
	// and lastly translated, so the transformations are multiplied in the reverse order
	left_wall := unit_sphere()
	left_wall.transform = matrix_multiply(
		matrix_multiply(
			matrix_multiply(translation(0, 0, 5), rotation_y(-math.PI / 4)),
			rotation_x(math.PI / 2),
		),
		scaling(10, 0.01, 10),
	)
	left_wall.material = floor.material
	// The wall on the right is identical to the left wall, but is rotated the opposite direction in y
	right_wall := unit_sphere()
	right_wall.transform = matrix_multiply(
		matrix_multiply(
			matrix_multiply(translation(0, 0, 5), rotation_y(math.PI / 4)),
			rotation_x(math.PI / 2),
		),
		scaling(10, 0.01, 10),
	)
	right_wall.material = floor.material
	// The large sphere in the middle is a unit sphere, translated upward slightly and colored green
	middle := unit_sphere()
	middle.transform = translation(-0.5, 1, 0.5)
	middle.material = default_material()
	middle.material.color = color(0.1, 1, 0.5)
	middle.material.diffuse = 0.7
	middle.material.specular = 0.3
	// The smaller green sphere on the right is scaled in half
	right := unit_sphere()
	right.transform = matrix_multiply(translation(1.5, 0.5, -0.5), scaling(0.5, 0.5, 0.5))
	right.material = default_material()
	right.material.color = color(0.5, 1, 0.1)
	right.material.diffuse = 0.7
	right.material.specular = 0.3
	// The smallest sphere is scaled by a third, before being translated
	left := unit_sphere()
	left.transform = matrix_multiply(translation(-1.5, 0.33, -0.75), scaling(0.33, 0.33, 0.33))
	left.material = default_material()
	left.material.color = color(1, 0.8, 0.1)
	left.material.diffuse = 0.7
	left.material.specular = 0.3
	// The light source is white, shining from above and to the left
	light := point_light(point(-10, 10, -10), color(1, 1, 1))
	world := World {
		objects = []Sphere{floor, left_wall, right_wall, middle, right, left},
		light   = light,
	}
	camera := camera(1000, 500, math.PI / 3)
	camera.transform = view_transform(point(0, 1.5, -5), point(0, 1, 0), vector(0, 1, 0))
	canvas := render(camera, world)
	ppm := canvas_to_ppm(canvas)
	defer delete(ppm)
	os.write_entire_file("world.ppm", transmute([]byte)ppm)
}
