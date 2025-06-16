package main

import "core:math"
import "core:testing"

Computations :: struct {
	t:          f32,
	object:     ^Sphere,
	point:      Point,
	eyev:       Vector,
	normalv:    Vector,
	inside:     bool,
	over_point: Point,
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

	over_point := add(point, scale(normalv, EPSILON))

	return Computations {
		t = i.t,
		object = i.object,
		point = point,
		eyev = eyev,
		normalv = normalv,
		inside = inside,
		over_point = over_point,
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

@(test)
prepare_computations_offset_point_test :: proc(t: ^testing.T) {
	r := ray(point(0, 0, -5), vector(0, 0, 1))

	s := unit_sphere()
	s.transform = translation(0, 0, 1)

	i := intersection(5, &s)
	comps := prepare_computations(i, r)

	testing.expect(t, comps.over_point.z < -EPSILON / 2.0)
	testing.expect(t, comps.point.z > comps.over_point.z)
}
