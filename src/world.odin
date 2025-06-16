package main

import "core:log"
import "core:slice"
import "core:testing"

World :: struct {
	objects: []Sphere,
	light:   PointLight,
}

world :: proc() -> World {
	return World{objects = make([]Sphere, 0), light = point_light(point(0, 0, 0), color(0, 0, 0))}
}

default_world :: proc() -> World {
	light := point_light(point(-10, 10, -10), color(1, 1, 1))

	s1 := unit_sphere()
	s1.material.color = color(0.8, 1.0, 0.6)
	s1.material.diffuse = 0.7
	s1.material.specular = 0.2

	s2 := unit_sphere()
	s2.transform = scaling(0.5, 0.5, 0.5)
	objects := make([]Sphere, 2)
	objects[0] = s1
	objects[1] = s2
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

shade_hit :: proc(world: World, comps: Computations) -> Color {
	return lighting(
		comps.object.material,
		world.light,
		comps.point,
		comps.eyev,
		comps.normalv,
		false,
	)
}

color_at :: proc(w: World, r: Ray) -> Color {
	xs, count := intersect_world(w, r)
	defer delete(xs)
	log.debug(xs)

	if count == 0 {
		return color(0, 0, 0)
	} else {
		h := hit(xs[:])
		if h == nil {
			return color(0, 0, 0)
		} else {
			comps := prepare_computations(h^, r)
			return shade_hit(w, comps)
		}
	}
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

@(test)
shade_hit_outside_test :: proc(t: ^testing.T) {
	w := default_world()
	defer delete(w.objects)

	r := ray(point(0, 0, -5), vector(0, 0, 1))
	shape := &w.objects[0]
	i := intersection(4, shape)
	comps := prepare_computations(i, r)
	result := shade_hit(w, comps)
	expected := color(0.38066, 0.47583, 0.2855)
	testing.expect(t, equal(result, expected))
}

@(test)
shade_hit_inside_test :: proc(t: ^testing.T) {
	w := default_world()
	defer delete(w.objects)

	w.light = point_light(point(0, 0.25, 0), color(1, 1, 1))
	r := ray(point(0, 0, 0), vector(0, 0, 1))
	shape := &w.objects[1]
	i := intersection(0.5, shape)
	comps := prepare_computations(i, r)
	result := shade_hit(w, comps)
	expected := color(0.90498, 0.90498, 0.90498)
	testing.expect(t, equal(result, expected))
}

@(test)
color_when_ray_misses_test :: proc(t: ^testing.T) {
	w := default_world()
	defer delete(w.objects)

	r := ray(point(0, 0, -5), vector(0, 1, 0))
	c := color_at(w, r)
	testing.expect(t, equal(c, color(0, 0, 0)))
}

@(test)
color_when_ray_hits_test :: proc(t: ^testing.T) {
	w := default_world()
	defer delete(w.objects)

	r := ray(point(0, 0, -5), vector(0, 0, 1))
	c := color_at(w, r)
	expected := color(0.38066, 0.47583, 0.2855)
	testing.expect(t, equal(c, expected))
}

@(test)
color_with_intersection_behind_ray_test :: proc(t: ^testing.T) {
	w := default_world()
	defer delete(w.objects)

	outer := &w.objects[0]
	outer.material.ambient = 1

	inner := &w.objects[1]
	inner.material.ambient = 1

	r := ray(point(0, 0, 0.75), vector(0, 0, -1))
	c := color_at(w, r)
	testing.expect(t, equal(c, inner.material.color))
}
