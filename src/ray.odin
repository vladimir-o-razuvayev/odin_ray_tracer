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
