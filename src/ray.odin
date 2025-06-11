package main

import "core:testing"

Ray :: struct {
	origin:    Point,
	direction: Vector,
}

ray :: proc(origin: Point, direction: Vector) -> Ray {
	return Ray{origin, direction}
}

position :: proc(r: Ray, t: f32) -> Point {
	return add(r.origin, scale(r.direction, t))
}

_transform_r :: proc(r: Ray, m: Matrix4) -> Ray {
	return Ray{origin = transform(r.origin, m), direction = transform(r.direction, m)}
}
_transform_t :: proc(t: $T/Tuple, m: Matrix4) -> T {return matrix_multiply_tuple(m, t)}
transform :: proc {
	_transform_r,
	_transform_t,
}

//****************************************/
// Tests
//****************************************/

@(test)
ray_creation_test :: proc(t: ^testing.T) {
	origin := point(1, 2, 3)
	direction := vector(4, 5, 6)
	r := ray(origin, direction)
	testing.expect(t, equal(r.origin, origin))
	testing.expect(t, equal(r.direction, direction))
}

@(test)
ray_position_test :: proc(t: ^testing.T) {
	r := ray(point(2, 3, 4), vector(1, 0, 0))
	testing.expect(t, equal(position(r, 0), point(2, 3, 4)))
	testing.expect(t, equal(position(r, 1), point(3, 3, 4)))
	testing.expect(t, equal(position(r, -1), point(1, 3, 4)))
	testing.expect(t, equal(position(r, 2.5), point(4.5, 3, 4)))
}

@(test)
ray_translation_test :: proc(t: ^testing.T) {
	r := ray(point(1, 2, 3), vector(0, 1, 0))
	m := translation(3, 4, 5)
	r2 := transform(r, m)
	testing.expect(t, equal(r2.origin, point(4, 6, 8)))
	testing.expect(t, equal(r2.direction, vector(0, 1, 0)))
}

@(test)
ray_scaling_test :: proc(t: ^testing.T) {
	r := ray(point(1, 2, 3), vector(0, 1, 0))
	m := scaling(2, 3, 4)
	r2 := transform(r, m)
	testing.expect(t, equal(r2.origin, point(2, 6, 12)))
	testing.expect(t, equal(r2.direction, vector(0, 3, 0)))
}
