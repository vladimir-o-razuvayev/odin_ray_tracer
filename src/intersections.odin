package main

import "core:fmt"
import "core:testing"

Intersection :: struct {
	t:      f32,
	object: ^Sphere,
}

intersection :: proc(t: f32, object: ^Sphere) -> Intersection {
	return Intersection{t, object}
}

intersections :: proc(i1, i2: Intersection) -> (res: [2]Intersection, count: int) {
	res[0] = i1
	res[1] = i2
	return res, 2
}

intersect :: proc(s: ^Sphere, r: Ray) -> (res: [2]Intersection, count: int = 0) {
	sphere_to_ray := sub(r.origin, s^.center)
	a := dot(r.direction, r.direction)
	b := 2 * dot(r.direction, sphere_to_ray)
	c := dot(sphere_to_ray, sphere_to_ray) - s^.radius * s^.radius
	discriminant := b * b - 4 * a * c
	if discriminant >= 0 {
		sqrt_disc := sqrt(discriminant)
		res[0] = intersection((-b - sqrt_disc) / (2 * a), s)
		res[1] = intersection((-b + sqrt_disc) / (2 * a), s)
		count = 2
	}
	return res, count
}

//****************************************/
// Tests
//****************************************/

@(test)
intersection_creation_test :: proc(t: ^testing.T) {
	s := unit_sphere()
	i := intersection(3.5, &s)
	testing.expect_value(t, i.t, 3.5)
	testing.expect(t, i.object == &s)
}

@(test)
intersections_aggregation_test :: proc(t: ^testing.T) {
	s := unit_sphere()
	i1 := intersection(1.0, &s)
	i2 := intersection(2.0, &s)
	xs, count := intersections(i1, i2)
	testing.expect_value(t, count, 2)
	testing.expect_value(t, xs[0].t, 1.0)
	testing.expect_value(t, xs[1].t, 2.0)
	testing.expect(t, xs[0].object == &s)
	testing.expect(t, xs[1].object == &s)
}

@(test)
intersect_two_points_test :: proc(t: ^testing.T) {
	r := ray(point(0, 0, -5), vector(0, 0, 1))
	s := unit_sphere()
	xs, count := intersect(&s, r)
	testing.expect_value(t, count, 2)
	testing.expect_value(t, xs[0].t, 4.0)
	testing.expect_value(t, xs[1].t, 6.0)
}

@(test)
intersect_tangent_test :: proc(t: ^testing.T) {
	r := ray(point(0, 1, -5), vector(0, 0, 1))
	s := unit_sphere()
	xs, count := intersect(&s, r)
	testing.expect_value(t, count, 2)
	testing.expect_value(t, xs[0].t, 5.0)
	testing.expect_value(t, xs[1].t, 5.0)
}

@(test)
intersect_miss_test :: proc(t: ^testing.T) {
	r := ray(point(0, 2, -5), vector(0, 0, 1))
	s := unit_sphere()
	xs, count := intersect(&s, r)
	testing.expect_value(t, count, 0)
}

@(test)
intersect_inside_test :: proc(t: ^testing.T) {
	r := ray(point(0, 0, 0), vector(0, 0, 1))
	s := unit_sphere()
	xs, count := intersect(&s, r)
	testing.expect_value(t, count, 2)
	testing.expect_value(t, xs[0].t, -1.0)
	testing.expect_value(t, xs[1].t, 1.0)
}

@(test)
intersect_behind_test :: proc(t: ^testing.T) {
	r := ray(point(0, 0, 5), vector(0, 0, 1))
	s := unit_sphere()
	xs, count := intersect(&s, r)
	testing.expect_value(t, count, 2)
	testing.expect_value(t, xs[0].t, -6.0)
	testing.expect_value(t, xs[1].t, -4.0)
}
