package main

import "core:math"
import "core:testing"

Sphere :: struct {
	center:    Point,
	radius:    f32,
	transform: Matrix4,
}

unit_sphere :: proc() -> Sphere {
	return Sphere{point(0, 0, 0), 1, identity_matrix()}
}

normal_at :: proc(s: ^Sphere, world_point: Point) -> Vector {
	local_point := transform(world_point, inverse(s^.transform))
	object_normal := sub(local_point, s^.center)
	world_normal := matrix_multiply_tuple(transpose(inverse(s^.transform)), object_normal)
	return normalize(world_normal)
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

@(test)
normal_x_axis_test :: proc(t: ^testing.T) {
	s := unit_sphere()
	n := normal_at(&s, point(1, 0, 0))
	testing.expect(t, equal(n, vector(1, 0, 0)))
}

@(test)
normal_y_axis_test :: proc(t: ^testing.T) {
	s := unit_sphere()
	n := normal_at(&s, point(0, 1, 0))
	testing.expect(t, equal(n, vector(0, 1, 0)))
}

@(test)
normal_z_axis_test :: proc(t: ^testing.T) {
	s := unit_sphere()
	n := normal_at(&s, point(0, 0, 1))
	testing.expect(t, equal(n, vector(0, 0, 1)))
}

@(test)
normal_nonaxial_test :: proc(t: ^testing.T) {
	s := unit_sphere()
	root3_over_3 := sqrt(3.0) / 3.0
	p := point(root3_over_3, root3_over_3, root3_over_3)
	n := normal_at(&s, p)
	expected := vector(root3_over_3, root3_over_3, root3_over_3)
	testing.expect(t, equal(n, expected))
}

@(test)
normal_is_normalized_test :: proc(t: ^testing.T) {
	s := unit_sphere()
	p := point(sqrt(3.0) / 3.0, sqrt(3.0) / 3.0, sqrt(3.0) / 3.0)
	n := normal_at(&s, p)
	testing.expect(t, equal(n, normalize(n))) // test is trivial but confirms behavior
}

@(test)
normal_translated_sphere_test :: proc(t: ^testing.T) {
	s := unit_sphere()
	s.transform = translation(0, 1, 0)
	p := point(0, 1.70711, -0.70711)
	n := normal_at(&s, p)
	testing.expect(t, equal(n, vector(0, 0.70711, -0.70711)))
}

@(test)
normal_transformed_sphere_test :: proc(t: ^testing.T) {
	s := unit_sphere()
	s.transform = matrix_multiply(scaling(1, 0.5, 1), rotation_z(math.PI / 5))
	p := point(0, sqrt(2.0) / 2.0, -sqrt(2.0) / 2.0)
	n := normal_at(&s, p)
	testing.expect(t, equal(n, vector(0, 0.97014, -0.24254)))
}
