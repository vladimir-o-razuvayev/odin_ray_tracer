package main

import "core:testing"

Sphere :: struct {
	center:    Point,
	radius:    f32,
	transform: Matrix4,
}

unit_sphere :: proc() -> Sphere {
	return Sphere{point(0, 0, 0), 1, identity_matrix()}
}

//****************************************/
// Tests
//****************************************/

@(test)
sphere_default_transform_test :: proc(t: ^testing.T) {
	s := unit_sphere()
	testing.expect(t, equal(s.transform, identity_matrix()))
}

@(test)
sphere_set_transform_test :: proc(t: ^testing.T) {
	s := unit_sphere()
	trans := translation(2, 3, 4)
	s.transform = trans
	testing.expect(t, equal(s.transform, trans))
}

@(test)
intersect_scaled_sphere_test :: proc(t: ^testing.T) {
	r := ray(point(0, 0, -5), vector(0, 0, 1))
	s := unit_sphere()
	s.transform = scaling(2, 2, 2)
	xs, count := intersect(&s, r)
	testing.expect_value(t, count, 2)
	testing.expect_value(t, xs[0].t, 3.0)
	testing.expect_value(t, xs[1].t, 7.0)
}

@(test)
intersect_translated_sphere_test :: proc(t: ^testing.T) {
	r := ray(point(0, 0, -5), vector(0, 0, 1))
	s := unit_sphere()
	s.transform = translation(5, 0, 0)
	xs, count := intersect(&s, r)
	testing.expect_value(t, count, 0)
}
