package main

import "core:testing"

Sphere :: struct {
	center: Point,
	radius: f32,
}

unit_sphere :: proc() -> Sphere {
	return Sphere{point(0, 0, 0), 1}
}
