package main

import "core:math"
import "core:testing"

Computations :: struct {
	t:       f32,
	object:  ^Sphere,
	point:   Point,
	eyev:    Vector,
	normalv: Vector,
	inside:  bool,
}

prepare_computations :: proc(i: Intersection, r: Ray) -> Computations {
	point := position(r, i.t)
	eyev := -r.direction
	normalv := normal_at(i.object, point)
	inside := false

	if dot(normalv, eyev) < 0 {
		inside = true
		normalv = -normalv
	}

	return Computations {
		t = i.t,
		object = i.object,
		point = point,
		eyev = eyev,
		normalv = normalv,
		inside = inside,
	}
}

//****************************************/
// Tests
//****************************************/

@(test)
prepare_computations_outside_test :: proc(t: ^testing.T) {
	r := ray(point(0, 0, -5), vector(0, 0, 1))
	shape := unit_sphere()
	i := intersection(4, &shape)

	comps := prepare_computations(i, r)

	testing.expect(t, equal(comps.t, i.t))
	testing.expect(t, comps.object == i.object)
	testing.expect(t, equal(comps.point, point(0, 0, -1)))
	testing.expect(t, equal(comps.eyev, vector(0, 0, -1)))
	testing.expect(t, equal(comps.normalv, vector(0, 0, -1)))
	testing.expect(t, !comps.inside)
}

@(test)
prepare_computations_inside_test :: proc(t: ^testing.T) {
	r := ray(point(0, 0, 0), vector(0, 0, 1))
	shape := unit_sphere()
	i := intersection(1, &shape)

	comps := prepare_computations(i, r)

	testing.expect(t, equal(comps.point, point(0, 0, 1)))
	testing.expect(t, equal(comps.eyev, vector(0, 0, -1)))
	testing.expect(t, comps.inside)
	testing.expect(t, equal(comps.normalv, vector(0, 0, -1)))
}
