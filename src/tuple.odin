package main

import "core:math"
import "core:testing"

// Tuple will be our internal type for maths
Tuple :: distinct [4]f64
// Vector and Point are the public types
Vector :: distinct Tuple
Point :: distinct Tuple

EPSILON: f64 : 2.2204460492503131e-016

// Initialisers
point :: proc(x, y, z: f64) -> Point {return Point{x, y, z, 1}}
vector :: proc(x, y, z: f64) -> Vector {return Vector{x, y, z, 0}}
zero_vector :: proc() -> Vector {return Vector{0, 0, 0, 0}}
// We don't need to call `is_point` or `is_vector` on typed `Point` and `Vector`
is_point :: proc(t: Tuple) -> bool {return equal(t.w, 1.0)}
is_vector :: proc(t: Tuple) -> bool {return equal(t.w, 0.0)}

// add
// We want to enforce not adding a point to a point at compile time (w != 2)
add_vv :: proc(a, b: Vector) -> Vector {return Vector(_add(a, b))}
add_pv :: proc(a: Point, b: Vector) -> Point {return Point(_add(a, b))}
add_vp :: proc(a: Vector, b: Point) -> Point {return Point(_add(a, b))}
_add :: proc(a: $T1/Tuple, b: $T2/Tuple) -> Tuple {
	return Tuple{a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w}
}
add :: proc {
	add_vv,
	add_pv,
	add_vp,
}

// sub
// We want to enforce not subtracting a point from a vector (w != -1)
sub_pp :: proc(a, b: Point) -> Vector {return Vector(_sub(a, b))}
sub_pv :: proc(a: Point, b: Vector) -> Point {return Point(_sub(a, b))}
sub_vv :: proc(a, b: Vector) -> Vector {return Vector(_sub(a, b))}
_sub :: proc(a: $T1/Tuple, b: $T2/Tuple) -> Tuple {
	return Tuple{a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w}
}
sub :: proc {
	sub_pp,
	sub_pv,
	sub_vv,
}

// equal
// A Vector should not be compared for equality with a Point (w == 0 or w == 1)
equal_pp :: proc(a, b: Point) -> bool {return _equal(a, b)}
equal_vv :: proc(a, b: Vector) -> bool {return _equal(a, b)}
equal_ff :: proc(a, b: f64) -> bool {return abs(a - b) < EPSILON}
_equal :: proc(a: $T1/Tuple, b: $T2/Tuple) -> bool {
	for i in 0 ..< 4 {
		if abs(a[i] - b[i]) > EPSILON {
			return false
		}
	}
	return true
}
equal :: proc {
	equal_pp,
	equal_vv,
	equal_ff,
}

neg :: proc(a: $T/Tuple) -> T {
	return T{-a.x, -a.y, -a.z, -a.w}
}

scale :: proc(a: $T/Tuple, scalar: f64) -> T {
	return T{a.x * scalar, a.y * scalar, a.z * scalar, a.w * scalar}
}

divide :: proc(a: $T/Tuple, scalar: f64) -> T {
	return T{a.x / scalar, a.y / scalar, a.z / scalar, a.w / scalar}
}

magnitude :: proc(v: $T/Tuple) -> f64 {
	return abs(sqrt(v.x * v.x + v.y * v.y + v.z * v.z))
}

normalize :: proc(v: Vector) -> Vector {
	m := magnitude(v)
	return Vector{v.x / m, v.y / m, v.z / m, 0}
}

sqrt :: proc(a: f64) -> f64 {return math.sqrt(a)}

//****************************************/
// Tests
//****************************************/

@(test)
tuple_is_point_test :: proc(t: ^testing.T) {
	a := Tuple{4.3, -4.2, 3.1, 1.0}
	testing.expect_value(t, a.x, 4.3)
	testing.expect_value(t, a.y, -4.2)
	testing.expect_value(t, a.z, 3.1)
	testing.expect_value(t, a.w, 1.0)
	testing.expect(t, is_point(a))
	testing.expect(t, !is_vector(a))
}

@(test)
tuple_is_vector_test :: proc(t: ^testing.T) {
	a := Tuple{4.3, -4.2, 3.1, 0.0}
	testing.expect_value(t, a.x, 4.3)
	testing.expect_value(t, a.y, -4.2)
	testing.expect_value(t, a.z, 3.1)
	testing.expect_value(t, a.w, 0.0)
	testing.expect(t, !is_point(a))
	testing.expect(t, is_vector(a))
}

@(test)
point_constructor_test :: proc(t: ^testing.T) {
	p := point(4, -4, 3)
	expected := Point{4, -4, 3, 1}
	testing.expect(t, equal(p, expected))
}

@(test)
vector_constructor_test :: proc(t: ^testing.T) {
	v := vector(4, -4, 3)
	expected := Vector{4, -4, 3, 0}
	testing.expect(t, equal(v, expected))
}

@(test)
vector_addition_test :: proc(t: ^testing.T) {
	a1 := vector(3, -2, 5)
	a2 := vector(-2, 3, 1)
	expected := vector(1, 1, 6)
	result := add(a1, a2)
	testing.expect(t, equal(result, expected))
}

@(test)
point_vector_addition_test :: proc(t: ^testing.T) {
	a1 := point(3, -2, 5)
	a2 := vector(-2, 3, 1)
	expected := point(1, 1, 6)
	result := add(a1, a2)
	testing.expect(t, equal(result, expected))
}

@(test)
point_minus_point_test :: proc(t: ^testing.T) {
	p1 := point(3, 2, 1)
	p2 := point(5, 6, 7)
	expected := vector(-2, -4, -6)
	testing.expect(t, equal(sub(p1, p2), expected))
}

@(test)
point_minus_vector_test :: proc(t: ^testing.T) {
	p := point(3, 2, 1)
	v := vector(5, 6, 7)
	expected := point(-2, -4, -6)
	testing.expect(t, equal(sub(p, v), expected))
}

@(test)
vector_minus_vector_test :: proc(t: ^testing.T) {
	v1 := vector(3, 2, 1)
	v2 := vector(5, 6, 7)
	expected := vector(-2, -4, -6)
	testing.expect(t, equal(sub(v1, v2), expected))
}

@(test)
zero_minus_vector_test :: proc(t: ^testing.T) {
	zero := zero_vector()
	v := vector(1, -2, 3)
	expected := vector(-1, 2, -3)
	testing.expect(t, equal(sub(zero, v), expected))
}

// When comparing `Tuple` we use the internal `_equal`
@(test)
tuple_negation_test :: proc(t: ^testing.T) {
	a := Tuple{1, -2, 3, -4}
	expected := Tuple{-1, 2, -3, 4}
	testing.expect(t, _equal(neg(a), expected))
}

@(test)
tuple_scalar_multiply_test :: proc(t: ^testing.T) {
	a := Tuple{1, -2, 3, -4}
	expected := Tuple{3.5, -7, 10.5, -14}
	testing.expect(t, _equal(scale(a, 3.5), expected))
}

@(test)
tuple_fraction_multiply_test :: proc(t: ^testing.T) {
	a := Tuple{1, -2, 3, -4}
	expected := Tuple{0.5, -1, 1.5, -2}
	testing.expect(t, _equal(scale(a, 0.5), expected))
}

@(test)
tuple_scalar_divide_test :: proc(t: ^testing.T) {
	a := Tuple{1, -2, 3, -4}
	expected := Tuple{0.5, -1, 1.5, -2}
	testing.expect(t, _equal(divide(a, 2.0), expected))
}

@(test)
magnitude_x_unit_test :: proc(t: ^testing.T) {
	v := vector(1, 0, 0)
	testing.expect(t, equal(magnitude(v), 1.0))
}

@(test)
magnitude_y_unit_test :: proc(t: ^testing.T) {
	v := vector(0, 1, 0)
	testing.expect(t, equal(magnitude(v), 1.0))
}

@(test)
magnitude_z_unit_test :: proc(t: ^testing.T) {
	v := vector(0, 0, 1)
	testing.expect(t, equal(magnitude(v), 1.0))
}

@(test)
magnitude_positive_vector_test :: proc(t: ^testing.T) {
	v := vector(1, 2, 3)
	expected := sqrt(14.0)
	testing.expect(t, equal(magnitude(v), expected))
}

@(test)
magnitude_negative_vector_test :: proc(t: ^testing.T) {
	v := vector(-1, -2, -3)
	expected := sqrt(14.0)
	testing.expect(t, equal(magnitude(v), expected))
}

@(test)
normalize_simple_test :: proc(t: ^testing.T) {
	v := vector(4, 0, 0)
	expected := vector(1, 0, 0)
	testing.expect(t, equal(normalize(v), expected))
}

@(test)
normalize_nontrivial_test :: proc(t: ^testing.T) {
	v := vector(1, 2, 3)
	expected := vector(1 / sqrt(14.0), 2 / sqrt(14.0), 3 / sqrt(14))
	testing.expect(t, equal(normalize(v), expected))
}

@(test)
normalize_magnitude_test :: proc(t: ^testing.T) {
	v := vector(1, 2, 3)
	norm := normalize(v)
	testing.expect(t, equal(magnitude(norm), 1.0))
}
