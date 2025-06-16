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

ray_for_pixel :: proc(c: Camera, px, py: int) -> Ray {
	// The offset from the edge of the canvas to the pixel's center
	xoffset := (f32(px) + 0.5) * c.pixel_size
	yoffset := (f32(py) + 0.5) * c.pixel_size

	// The untransformed coordinates of the pixel in world space
	// Remember that the camera looks toward -z, so +x is to the *left*
	world_x := c.half_width - xoffset
	world_y := c.half_height - yoffset

	// Using the camera matrix, transform the canvas point and the origin,
	// and then compute the ray's direction vector
	// Remember that the canvas is at z=-1
	inv := inverse(c.transform)
	pixel := transform(point(world_x, world_y, -1), inv)
	origin := transform(point(0, 0, 0), inv)
	direction := normalize(sub(pixel, origin))

	return ray(origin, direction)
}

render :: proc(camera: Camera, world: World) -> Canvas {
	image := canvas(camera.hsize, camera.vsize)

	for y in 0 ..< camera.vsize {
		for x in 0 ..< camera.hsize {
			r := ray_for_pixel(camera, x, y)
			color := color_at(world, r)
			write_pixel(&image, x, y, color)
		}
	}

	return image
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

@(test)
ray_through_center_test :: proc(t: ^testing.T) {
	c := camera(201, 101, math.PI / 2)
	r := ray_for_pixel(c, 100, 50)
	testing.expect(t, equal(r.origin, point(0, 0, 0)))
	testing.expect(t, equal(r.direction, vector(0, 0, -1)))
}

@(test)
ray_through_corner_test :: proc(t: ^testing.T) {
	c := camera(201, 101, math.PI / 2)
	r := ray_for_pixel(c, 0, 0)
	testing.expect(t, equal(r.origin, point(0, 0, 0)))
	testing.expect(t, equal(r.direction, vector(0.66519, 0.33259, -0.66851)))
}

@(test)
ray_with_transform_test :: proc(t: ^testing.T) {
	c := camera(201, 101, math.PI / 2)
	c.transform = matrix_multiply(rotation_y(math.PI / 4), translation(0, -2, 5))
	r := ray_for_pixel(c, 100, 50)
	testing.expect(t, equal(r.origin, point(0, 2, -5)))
	testing.expect(t, equal(r.direction, vector(0.70710678, 0, -0.70710678)))
}

@(test)
rendering_with_camera_test :: proc(t: ^testing.T) {
	w := default_world()
	defer delete(w.objects)
	c := camera(11, 11, math.PI / 2)

	from := point(0, 0, -5)
	to := point(0, 0, 0)
	up := vector(0, 1, 0)
	c.transform = view_transform(from, to, up)

	image := render(c, w)
	defer canvas_destroy(image)
	expected := color(0.38066, 0.47583, 0.2855)

	actual := pixel_at(image, 5, 5)
	testing.expect(t, equal(actual, expected))
}
