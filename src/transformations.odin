package main

import "core:math"
import "core:testing"

translation :: proc(x, y, z: f32) -> Matrix4 {
	return Matrix4{{1, 0, 0, x}, {0, 1, 0, y}, {0, 0, 1, z}, {0, 0, 0, 1}}
}

scaling :: proc(x, y, z: f32) -> Matrix4 {
	return Matrix4{{x, 0, 0, 0}, {0, y, 0, 0}, {0, 0, z, 0}, {0, 0, 0, 1}}
}

rotation_x :: proc(r: f32) -> Matrix4 {
	return Matrix4 {
		{1, 0, 0, 0},
		{0, math.cos(r), -math.sin(r), 0},
		{0, math.sin(r), math.cos(r), 0},
		{0, 0, 0, 1},
	}
}

rotation_y :: proc(r: f32) -> Matrix4 {
	return Matrix4 {
		{math.cos(r), 0, math.sin(r), 0},
		{0, 1, 0, 0},
		{-math.sin(r), 0, math.cos(r), 0},
		{0, 0, 0, 1},
	}
}

rotation_z :: proc(r: f32) -> Matrix4 {
	return Matrix4 {
		{math.cos(r), -math.sin(r), 0, 0},
		{math.sin(r), math.cos(r), 0, 0},
		{0, 0, 1, 0},
		{0, 0, 0, 1},
	}
}

shearing :: proc(xy, xz, yx, yz, zx, zy: f32) -> Matrix4 {
	return Matrix4{{1, xy, xz, 0}, {yx, 1, yz, 0}, {zx, zy, 1, 0}, {0, 0, 0, 1}}
}


//****************************************/
// Tests
//****************************************/

@(test)
translation_matrix_point_test :: proc(t: ^testing.T) {
	transform := translation(5, -3, 2)
	p := point(-3, 4, 5)
	expected := point(2, 1, 7)
	result := matrix_multiply_tuple(transform, p)
	testing.expect(t, equal(result, expected))
}

@(test)
inverse_translation_matrix_point_test :: proc(t: ^testing.T) {
	transform := translation(5, -3, 2)
	inv := inverse(transform)
	p := point(-3, 4, 5)
	expected := point(-8, 7, 3)
	result := matrix_multiply_tuple(inv, p)
	testing.expect(t, equal(result, expected))
}

@(test)
translation_does_not_affect_vectors_test :: proc(t: ^testing.T) {
	transform := translation(5, -3, 2)
	v := vector(-3, 4, 5)
	// translation should not affect vectors
	result := matrix_multiply_tuple(transform, v)
	testing.expect(t, equal(result, v))
}

@(test)
scaling_matrix_point_test :: proc(t: ^testing.T) {
	transform := scaling(2, 3, 4)
	p := point(-4, 6, 8)
	expected := point(-8, 18, 32)
	testing.expect(t, equal(matrix_multiply_tuple(transform, p), expected))
}

@(test)
scaling_matrix_vector_test :: proc(t: ^testing.T) {
	transform := scaling(2, 3, 4)
	v := vector(-4, 6, 8)
	expected := vector(-8, 18, 32)
	testing.expect(t, equal(matrix_multiply_tuple(transform, v), expected))
}

@(test)
inverse_scaling_matrix_vector_test :: proc(t: ^testing.T) {
	transform := scaling(2, 3, 4)
	inv := inverse(transform)
	v := vector(-4, 6, 8)
	expected := vector(-2, 2, 2)
	testing.expect(t, equal(matrix_multiply_tuple(inv, v), expected))
}

@(test)
reflection_is_negative_scaling_test :: proc(t: ^testing.T) {
	transform := scaling(-1, 1, 1)
	p := point(2, 3, 4)
	expected := point(-2, 3, 4)
	testing.expect(t, equal(matrix_multiply_tuple(transform, p), expected))
}

@(test)
rotation_x_point_test :: proc(t: ^testing.T) {
	p := point(0, 1, 0)
	half := rotation_x(math.PI / 4)
	full := rotation_x(math.PI / 2)

	expected_half := point(0, sqrt(2) / 2, sqrt(2) / 2)
	expected_full := point(0, 0, 1)

	testing.expect(t, equal(matrix_multiply_tuple(half, p), expected_half))
	testing.expect(t, equal(matrix_multiply_tuple(full, p), expected_full))
}

@(test)
inverse_rotation_x_test :: proc(t: ^testing.T) {
	p := point(0, 1, 0)
	half := rotation_x(math.PI / 4)
	inv := inverse(half)
	expected := point(0, sqrt(2) / 2, -sqrt(2) / 2)

	testing.expect(t, equal(matrix_multiply_tuple(inv, p), expected))
}

@(test)
rotation_y_point_test :: proc(t: ^testing.T) {
	p := point(0, 0, 1)
	half := rotation_y(math.PI / 4)
	full := rotation_y(math.PI / 2)

	expected_half := point(sqrt(2) / 2, 0, sqrt(2) / 2)
	expected_full := point(1, 0, 0)

	testing.expect(t, equal(matrix_multiply_tuple(half, p), expected_half))
	testing.expect(t, equal(matrix_multiply_tuple(full, p), expected_full))
}

@(test)
rotation_z_point_test :: proc(t: ^testing.T) {
	p := point(0, 1, 0)
	half := rotation_z(math.PI / 4)
	full := rotation_z(math.PI / 2)

	expected_half := point(-sqrt(2) / 2, sqrt(2) / 2, 0)
	expected_full := point(-1, 0, 0)

	testing.expect(t, equal(matrix_multiply_tuple(half, p), expected_half))
	testing.expect(t, equal(matrix_multiply_tuple(full, p), expected_full))
}

@(test)
shearing_x_in_proportion_to_y_test :: proc(t: ^testing.T) {
	transform := shearing(1, 0, 0, 0, 0, 0)
	p := point(2, 3, 4)
	expected := point(5, 3, 4)
	testing.expect(t, equal(matrix_multiply_tuple(transform, p), expected))
}

@(test)
shearing_x_in_proportion_to_z_test :: proc(t: ^testing.T) {
	transform := shearing(0, 1, 0, 0, 0, 0)
	p := point(2, 3, 4)
	expected := point(6, 3, 4)
	testing.expect(t, equal(matrix_multiply_tuple(transform, p), expected))
}

@(test)
shearing_y_in_proportion_to_x_test :: proc(t: ^testing.T) {
	transform := shearing(0, 0, 1, 0, 0, 0)
	p := point(2, 3, 4)
	expected := point(2, 5, 4)
	testing.expect(t, equal(matrix_multiply_tuple(transform, p), expected))
}

@(test)
shearing_y_in_proportion_to_z_test :: proc(t: ^testing.T) {
	transform := shearing(0, 0, 0, 1, 0, 0)
	p := point(2, 3, 4)
	expected := point(2, 7, 4)
	testing.expect(t, equal(matrix_multiply_tuple(transform, p), expected))
}

@(test)
shearing_z_in_proportion_to_x_test :: proc(t: ^testing.T) {
	transform := shearing(0, 0, 0, 0, 1, 0)
	p := point(2, 3, 4)
	expected := point(2, 3, 6)
	testing.expect(t, equal(matrix_multiply_tuple(transform, p), expected))
}

@(test)
shearing_z_in_proportion_to_y_test :: proc(t: ^testing.T) {
	transform := shearing(0, 0, 0, 0, 0, 1)
	p := point(2, 3, 4)
	expected := point(2, 3, 7)
	testing.expect(t, equal(matrix_multiply_tuple(transform, p), expected))
}

@(test)
chained_individual_transforms_test :: proc(t: ^testing.T) {
	p := point(1, 0, 1)
	a := rotation_x(math.PI / 2)
	b := scaling(5, 5, 5)
	c := translation(10, 5, 7)
	p2 := matrix_multiply_tuple(a, p)
	testing.expect(t, equal(p2, point(1, -1, 0)))
	p3 := matrix_multiply_tuple(b, p2)
	testing.expect(t, equal(p3, point(5, -5, 0)))
	p4 := matrix_multiply_tuple(c, p3)
	testing.expect(t, equal(p4, point(15, 0, 7)))
}

@(test)
chained_transforms_reverse_order_test :: proc(t: ^testing.T) {
	p := point(1, 0, 1)
	a := rotation_x(math.PI / 2)
	b := scaling(5, 5, 5)
	c := translation(10, 5, 7)
	trans := matrix_multiply(matrix_multiply(c, b), a)
	result := matrix_multiply_tuple(trans, p)
	testing.expect(t, equal(result, point(15, 0, 7)))
}
