package main

import "core:testing"

PointLight :: struct {
	position:  Point,
	intensity: Color,
}

point_light :: proc(position: Point, intensity: Color) -> PointLight {
	return PointLight{position, intensity}
}

//****************************************/
// Tests
//****************************************/

@(test)
point_light_creation_test :: proc(t: ^testing.T) {
	position := point(0, 0, 0)
	intensity := color(1, 1, 1)
	light := point_light(position, intensity)
	testing.expect(t, equal(light.position, position))
	testing.expect(t, equal(light.intensity, intensity))
}
