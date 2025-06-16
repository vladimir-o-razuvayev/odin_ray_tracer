package main

import "core:math"
import "core:testing"

Camera :: struct {
	hsize:         int,
	vsize:         int,
	field_of_view: f32,
	transform:     Matrix4,
	pixel_size:    f32,
	half_width:    f32,
	half_height:   f32,
}

camera :: proc(hsize: int, vsize: int, field_of_view: f32) -> Camera {
	half_view := math.tan(field_of_view / 2.0)
	aspect := f32(hsize) / f32(vsize)

	half_width: f32
	half_height: f32

	if aspect >= 1.0 {
		half_width = half_view
		half_height = half_view / aspect
	} else {
		half_width = half_view * aspect
		half_height = half_view
	}

	pixel_size := (half_width * 2.0) / f32(hsize)

	return Camera {
		hsize = hsize,
		vsize = vsize,
		field_of_view = field_of_view,
		transform = identity_matrix(),
		pixel_size = pixel_size,
		half_width = half_width,
		half_height = half_height,
	}
}

//****************************************/
// Tests
//****************************************/

@(test)
camera_creation_test :: proc(t: ^testing.T) {
	hsize := 160
	vsize := 120
	fov: f32 = math.PI / 2
	c := camera(hsize, vsize, fov)

	testing.expect_value(t, c.hsize, hsize)
	testing.expect_value(t, c.vsize, vsize)
	testing.expect(t, equal(c.field_of_view, fov))
	testing.expect(t, equal(c.transform, identity_matrix()))
}

@(test)
pixel_size_horizontal_test :: proc(t: ^testing.T) {
	c := camera(200, 125, math.PI / 2)
	testing.expect(t, equal(c.pixel_size, 0.01))
}

@(test)
pixel_size_vertical_test :: proc(t: ^testing.T) {
	c := camera(125, 200, math.PI / 2)
	testing.expect(t, equal(c.pixel_size, 0.01))
}
