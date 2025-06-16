package main

import "core:math"
import "core:testing"

Material :: struct {
	color:     Color,
	ambient:   f32,
	diffuse:   f32,
	specular:  f32,
	shininess: f32,
}

default_material :: proc() -> Material {
	return Material {
		color = color(1, 1, 1),
		ambient = 0.1,
		diffuse = 0.9,
		specular = 0.9,
		shininess = 200.0,
	}
}

lighting :: proc(
	material: Material,
	light: PointLight,
	point: Point,
	eye_vector: Vector,
	normal_vector: Vector,
	in_shadow: bool,
) -> Color {
	// combine the surface color with the light's color/intensity
	effective_color := hadamard_product(material.color, light.intensity)
	// find the direction to the light source
	light_vector := normalize(sub(light.position, point))
	// compute the ambient contribution
	ambient := scale(effective_color, material.ambient)
	if in_shadow {return ambient}
	// light_dot_normal represents the cosine of the angle between the
	// light vector and the normal vector. A negative number means the
	// light is on the other side of the surface.
	light_dot_normal := dot(light_vector, normal_vector)

	diffuse, specular: Color

	if light_dot_normal < 0 {
		diffuse = color(0, 0, 0)
		specular = color(0, 0, 0)
	} else {
		// compute the diffuse contribution
		diffuse = scale(effective_color, material.diffuse * light_dot_normal)
		// reflect_dot_eye represents the cosine of the angle between the
		// reflection vector and the eye vector. A negative number means the
		// light reflects away from the eye.
		reflect_vector := reflect(neg(light_vector), normal_vector)
		reflect_dot_eye := dot(reflect_vector, eye_vector)

		if reflect_dot_eye <= 0 {
			specular = color(0, 0, 0)
		} else {
			// compute the specular contribution
			factor := math.pow(reflect_dot_eye, material.shininess)
			specular = scale(light.intensity, material.specular * factor)
		}
	}
	// add the three contributions together to get the final shading
	return add(add(ambient, diffuse), specular)
}

is_shadowed :: proc(w: World, p: Point) -> bool {
	// Measure the distance from point to the light source
	v := sub(w.light.position, p)
	distance := magnitude(v)
	direction := normalize(v)
	// Create a ray from point toward the light source and intersect the world
	r := ray(p, direction)
	xs, count := intersect_world(w, r)

	// If hit lies between point and the light source then point is in shadow
	h := hit(xs[:count])
	return h != nil && h.t < distance
}

//****************************************/
// Tests
//****************************************/

@(test)
default_material_test :: proc(t: ^testing.T) {
	m := default_material()
	testing.expect(t, equal(m.color, color(1, 1, 1)))
	testing.expect_value(t, m.ambient, 0.1)
	testing.expect_value(t, m.diffuse, 0.9)
	testing.expect_value(t, m.specular, 0.9)
	testing.expect_value(t, m.shininess, 200.0)
}

@(test)
lighting_eye_between_light_and_surface_test :: proc(t: ^testing.T) {
	m := default_material()
	position := point(0, 0, 0)
	eyev := vector(0, 0, -1)
	normalv := vector(0, 0, -1)
	light := point_light(point(0, 0, -10), color(1, 1, 1))
	result := lighting(m, light, position, eyev, normalv, false)
	testing.expect(t, equal(result, color(1.9, 1.9, 1.9)))
}

@(test)
lighting_eye_offset_45_degrees_test :: proc(t: ^testing.T) {
	m := default_material()
	position := point(0, 0, 0)
	eyev := vector(0, sqrt(2) / 2, -sqrt(2) / 2)
	normalv := vector(0, 0, -1)
	light := point_light(point(0, 0, -10), color(1, 1, 1))
	result := lighting(m, light, position, eyev, normalv, false)
	testing.expect(t, equal(result, color(1.0, 1.0, 1.0)))
}

@(test)
lighting_light_offset_45_degrees_test :: proc(t: ^testing.T) {
	m := default_material()
	position := point(0, 0, 0)
	eyev := vector(0, 0, -1)
	normalv := vector(0, 0, -1)
	light := point_light(point(0, 10, -10), color(1, 1, 1))
	result := lighting(m, light, position, eyev, normalv, false)
	testing.expect(t, equal(result, color(0.7364, 0.7364, 0.7364)))
}

@(test)
lighting_eye_in_reflection_path_test :: proc(t: ^testing.T) {
	m := default_material()
	position := point(0, 0, 0)
	eyev := vector(0, -sqrt(2) / 2, -sqrt(2) / 2)
	normalv := vector(0, 0, -1)
	light := point_light(point(0, 10, -10), color(1, 1, 1))
	result := lighting(m, light, position, eyev, normalv, false)
	testing.expect(t, equal(result, color(1.6364, 1.6364, 1.6364)))
}

@(test)
lighting_light_behind_surface_test :: proc(t: ^testing.T) {
	m := default_material()
	position := point(0, 0, 0)
	eyev := vector(0, 0, -1)
	normalv := vector(0, 0, -1)
	light := point_light(point(0, 0, 10), color(1, 1, 1))
	result := lighting(m, light, position, eyev, normalv, false)
	testing.expect(t, equal(result, color(0.1, 0.1, 0.1)))
}

@(test)
lighting_in_shadow_test :: proc(t: ^testing.T) {
	m := default_material()
	position := point(0, 0, 0)
	eyev := vector(0, 0, -1)
	normalv := vector(0, 0, -1)
	light := point_light(point(0, 0, -10), color(1, 1, 1))
	in_shadow := true

	result := lighting(m, light, position, eyev, normalv, in_shadow)
	testing.expect(t, equal(result, color(0.1, 0.1, 0.1)))
}

@(test)
no_shadow_when_nothing_collinear_test :: proc(t: ^testing.T) {
	w := default_world()
	p := point(0, 10, 0)
	testing.expect(t, is_shadowed(w, p) == false)
}

@(test)
shadow_when_object_between_point_and_light_test :: proc(t: ^testing.T) {
	w := default_world()
	p := point(10, -10, 10)
	testing.expect(t, is_shadowed(w, p) == true)
}

@(test)
no_shadow_when_object_behind_light_test :: proc(t: ^testing.T) {
	w := default_world()
	p := point(-20, 20, -20)
	testing.expect(t, is_shadowed(w, p) == false)
}

@(test)
no_shadow_when_object_behind_point_test :: proc(t: ^testing.T) {
	w := default_world()
	p := point(-2, 2, -2)
	testing.expect(t, is_shadowed(w, p) == false)
}
