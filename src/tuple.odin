package main

import "core:math"
import "core:testing"

// Tuple will be our internal type for maths
Tuple :: distinct [4]f32
// Vector and Point are the public types
Vector :: distinct Tuple
Point :: distinct Tuple
Color :: distinct Tuple

// Initialisers
color :: proc(r, g, b: f32) -> Color {return Color{r, g, b, 0}}
point :: proc(x, y, z: f32) -> Point {return Point{x, y, z, 1}}
vector :: proc(x, y, z: f32) -> Vector {return Vector{x, y, z, 0}}
zero_vector :: proc() -> Vector {return Vector{0, 0, 0, 0}}
// We don't need to call `is_point` or `is_vector` on typed `Point` and `Vector`
is_point :: proc(t: Tuple) -> bool {return abs(t.w - 1) < EPSILON}
is_vector :: proc(t: Tuple) -> bool {return abs(t.w) < EPSILON}

// add
// We want to enforce not adding a point to a point at compile time (w != 2)
add_cc :: proc(a, b: Color) -> Color {return Color(_add(a, b))}
add_vv :: proc(a, b: Vector) -> Vector {return Vector(_add(a, b))}
add_pv :: proc(a: Point, b: Vector) -> Point {return Point(_add(a, b))}
add_vp :: proc(a: Vector, b: Point) -> Point {return Point(_add(a, b))}
_add :: proc(a: $T1/Tuple, b: $T2/Tuple) -> Tuple {
	return Tuple{a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w}
}
add :: proc {
	add_cc,
	add_vv,
	add_pv,
	add_vp,
}

// sub
// We want to enforce not subtracting a point from a vector (w != -1)
sub_cc :: proc(a, b: Color) -> Color {return Color(_sub(a, b))}
sub_pp :: proc(a, b: Point) -> Vector {return Vector(_sub(a, b))}
sub_pv :: proc(a: Point, b: Vector) -> Point {return Point(_sub(a, b))}
sub_vv :: proc(a, b: Vector) -> Vector {return Vector(_sub(a, b))}
_sub :: proc(a: $T1/Tuple, b: $T2/Tuple) -> Tuple {
	return Tuple{a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w}
}
sub :: proc {
	sub_cc,
	sub_pp,
	sub_pv,
	sub_vv,
}

neg :: proc(a: $T/Tuple) -> T {return T{-a.x, -a.y, -a.z, -a.w}}

scale :: proc(a: $T/Tuple, scalar: f32) -> T {
	return T{a.x * scalar, a.y * scalar, a.z * scalar, a.w * scalar}
}

divide :: proc(a: $T/Tuple, scalar: f32) -> T {
	return T{a.x / scalar, a.y / scalar, a.z / scalar, a.w / scalar}
}

magnitude :: proc(v: $T/Tuple) -> f32 {return abs(sqrt(v.x * v.x + v.y * v.y + v.z * v.z))}
hadamard_product :: proc(a, b: Color) -> Color {return Color{a.r * b.r, a.g * b.g, a.b * b.b, 0}}
reflect :: proc(v: Vector, n: Vector) -> Vector {return sub(v, scale(n, 2 * dot(v, n)))}

normalize :: proc(v: Vector) -> Vector {
	m := magnitude(v)
	return Vector{v.x / m, v.y / m, v.z / m, 0}
}

sqrt :: proc(a: f32) -> f32 {return math.sqrt(a)}
dot :: proc(a, b: Vector) -> f32 {return a.x * b.x + a.y * b.y + a.z * b.z}

cross :: proc(a, b: Vector) -> Vector {
	return Vector{a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x, 0}
}

//****************************************/
// Tests
//****************************************/

@(test)
tuple_is_point_test :: proc(t: ^testing.T) {
	a := Tuple{4.3, -4.2, 3.1, 1}
	testing.expect_value(t, a.x, 4.3)
	testing.expect_value(t, a.y, -4.2)
	testing.expect_value(t, a.z, 3.1)
	testing.expect_value(t, a.w, 1)
	testing.expect(t, is_point(a))
	testing.expect(t, !is_vector(a))
}

@(test)
tuple_is_vector_test :: proc(t: ^testing.T) {
	a := Tuple{4.3, -4.2, 3.1, 0}
	testing.expect_value(t, a.x, 4.3)
	testing.expect_value(t, a.y, -4.2)
	testing.expect_value(t, a.z, 3.1)
	testing.expect_value(t, a.w, 0)
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

@(test)
tuple_negation_test :: proc(t: ^testing.T) {
	a := Tuple{1, -2, 3, -4}
	expected := Tuple{-1, 2, -3, 4}
	testing.expect(t, equal(neg(a), expected))
}

@(test)
tuple_scalar_multiply_test :: proc(t: ^testing.T) {
	a := Tuple{1, -2, 3, -4}
	expected := Tuple{3.5, -7, 10.5, -14}
	testing.expect(t, equal(scale(a, 3.5), expected))
}

@(test)
tuple_fraction_multiply_test :: proc(t: ^testing.T) {
	a := Tuple{1, -2, 3, -4}
	expected := Tuple{0.5, -1, 1.5, -2}
	testing.expect(t, equal(scale(a, 0.5), expected))
}

@(test)
tuple_scalar_divide_test :: proc(t: ^testing.T) {
	a := Tuple{1, -2, 3, -4}
	expected := Tuple{0.5, -1, 1.5, -2}
	testing.expect(t, equal(divide(a, 2), expected))
}

@(test)
magnitude_unit_test :: proc(t: ^testing.T) {
	x := vector(1, 0, 0)
	y := vector(0, 1, 0)
	z := vector(0, 0, 1)
	testing.expect(t, equal(magnitude(x), 1))
	testing.expect(t, equal(magnitude(y), 1))
	testing.expect(t, equal(magnitude(z), 1))
}

@(test)
magnitude_positive_vector_test :: proc(t: ^testing.T) {
	v := vector(1, 2, 3)
	expected := sqrt(14)
	testing.expect(t, equal(magnitude(v), expected))
}

@(test)
magnitude_negative_vector_test :: proc(t: ^testing.T) {
	v := vector(-1, -2, -3)
	expected := sqrt(14)
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
	expected := vector(1 / sqrt(14), 2 / sqrt(14), 3 / sqrt(14))
	testing.expect(t, equal(normalize(v), expected))
}

@(test)
normalize_magnitude_test :: proc(t: ^testing.T) {
	v := vector(1, 2, 3)
	norm := normalize(v)
	testing.expect(t, equal(magnitude(norm), 1))
}

@(test)
dot_product_test :: proc(t: ^testing.T) {
	a := vector(1, 2, 3)
	b := vector(2, 3, 4)
	testing.expect(t, equal(dot(a, b), 20.0))
}

@(test)
cross_product_test :: proc(t: ^testing.T) {
	a := vector(1, 2, 3)
	b := vector(2, 3, 4)
	expected_ab := vector(-1, 2, -1)
	expected_ba := vector(1, -2, 1)
	testing.expect(t, equal(cross(a, b), expected_ab))
	testing.expect(t, equal(cross(b, a), expected_ba))
}

@(test)
color_components_test :: proc(t: ^testing.T) {
	c := color(-0.5, 0.4, 1.7)
	testing.expect(t, equal(c.r, -0.5))
	testing.expect(t, equal(c.g, 0.4))
	testing.expect(t, equal(c.b, 1.7))
}

@(test)
color_addition_test :: proc(t: ^testing.T) {
	c1 := color(0.9, 0.6, 0.75)
	c2 := color(0.7, 0.1, 0.25)
	expected := color(1.6, 0.7, 1.0)
	testing.expect(t, equal(add(c1, c2), expected))
}

@(test)
color_subtraction_test :: proc(t: ^testing.T) {
	c1 := color(0.9, 0.6, 0.75)
	c2 := color(0.7, 0.1, 0.25)
	expected := color(0.2, 0.5, 0.5)
	testing.expect(t, equal(sub(c1, c2), expected))
}

@(test)
color_scalar_multiply_test :: proc(t: ^testing.T) {
	c := color(0.2, 0.3, 0.4)
	expected := color(0.4, 0.6, 0.8)
	testing.expect(t, equal(scale(c, 2.0), expected))
}

@(test)
hadamard_product_test :: proc(t: ^testing.T) {
	c1 := color(1, 0.2, 0.4)
	c2 := color(0.9, 1, 0.1)
	expected := color(0.9, 0.2, 0.04)
	testing.expect(t, equal(hadamard_product(c1, c2), expected))
}

@(test)
reflect_45_deg_test :: proc(t: ^testing.T) {
	v := vector(1, -1, 0)
	n := vector(0, 1, 0)
	r := reflect(v, n)
	testing.expect(t, equal(r, vector(1, 1, 0)))
}

@(test)
reflect_slanted_surface_test :: proc(t: ^testing.T) {
	v := vector(0, -1, 0)
	n := vector(sqrt(2.0) / 2.0, sqrt(2.0) / 2.0, 0)
	r := reflect(v, n)
	testing.expect(t, equal(r, vector(1, 0, 0)))
}
