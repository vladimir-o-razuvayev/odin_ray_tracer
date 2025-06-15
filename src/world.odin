package main

import "core:log"
import "core:slice"
import "core:testing"

World :: struct {
	objects: [dynamic]Sphere,
	light:   PointLight,
}

world :: proc() -> World {
	return World {
		objects = make([dynamic]Sphere),
		light = point_light(point(0, 0, 0), color(0, 0, 0)),
	}
}

default_world :: proc() -> World {
	light := point_light(point(-10, 10, -10), color(1, 1, 1))

	s1 := unit_sphere()
	s1.material.color = color(0.8, 1.0, 0.6)
	s1.material.diffuse = 0.7
	s1.material.specular = 0.2

	s2 := unit_sphere()
	s2.transform = scaling(0.5, 0.5, 0.5)
	objects := make([dynamic]Sphere)
	append(&objects, s1, s2)
	return World{objects, light}
}

intersect_world :: proc(w: World, r: Ray) -> ([]Intersection, int) {
	result := make([dynamic]Intersection)
	for &obj in w.objects[:] {
		xs, count := intersect(&obj, r)
		for i in 0 ..< count {
			append(&result, xs[i])
		}
	}
	log.debug(result)
	slice.sort_by(result[:], proc(i, j: Intersection) -> bool {return i.t < j.t})
	return result[:], len(result)
}

//****************************************/
// Tests
//****************************************/

@(test)
world_creation_test :: proc(t: ^testing.T) {
	w := world()
	testing.expect_value(t, len(w.objects), 0)
	testing.expect(t, equal(w.light.intensity, color(0, 0, 0)))
	testing.expect(t, equal(w.light.position, point(0, 0, 0)))
}

@(test)
default_world_test :: proc(t: ^testing.T) {
	w := default_world()
	defer delete(w.objects)

	light := point_light(point(-10, 10, -10), color(1, 1, 1))
	s1 := unit_sphere()
	s1.material.color = color(0.8, 1.0, 0.6)
	s1.material.diffuse = 0.7
	s1.material.specular = 0.2

	s2 := unit_sphere()
	s2.transform = scaling(0.5, 0.5, 0.5)

	testing.expect(t, equal(w.light.position, light.position))
	testing.expect(t, equal(w.light.intensity, light.intensity))
	testing.expect(t, len(w.objects) == 2)
	testing.expect(t, equal(w.objects[0].material.color, s1.material.color))
	testing.expect(t, equal(w.objects[0].material.diffuse, s1.material.diffuse))
	testing.expect(t, equal(w.objects[0].material.specular, s1.material.specular))
	testing.expect(t, equal(w.objects[1].transform, s2.transform))
}

@(test)
intersect_world_test :: proc(t: ^testing.T) {
	w := default_world()
	defer delete(w.objects)

	r := ray(point(0, 0, -5), vector(0, 0, 1))
	xs, count := intersect_world(w, r)
	defer delete(xs)
	testing.expect_value(t, count, 4)
	testing.expect(t, equal(xs[0].t, 4.0))
	testing.expect(t, equal(xs[1].t, 4.5))
	testing.expect(t, equal(xs[2].t, 5.5))
	testing.expect(t, equal(xs[3].t, 6.0))
}
