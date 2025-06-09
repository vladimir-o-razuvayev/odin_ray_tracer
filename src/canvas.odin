package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:testing"

// Canvas structure
Canvas :: struct {
	width:  int,
	height: int,
	pixels: [][]Color,
}

canvas :: proc(width, height: int) -> Canvas {
	pixels := make([][]Color, width)
	for w in 0 ..< width {
		pixels[w] = make([]Color, height)
		for h in 0 ..< height {
			pixels[w][h] = color(0, 0, 0)
		}
	}
	return Canvas{width, height, pixels}
}

canvas_destroy :: proc(c: Canvas) {
	for i in 0 ..< len(c.pixels) {
		delete(c.pixels[i])
	}
	delete(c.pixels)
}

pixel_at :: proc(c: Canvas, x, y: int) -> Color {
	return c.pixels[x][y]
}

write_pixel :: proc(c: ^Canvas, x, y: int, col: Color) {
	c.pixels[x][y] = col
}

canvas_to_ppm :: proc(c: Canvas) -> (res: string) {
	builder := strings.builder_make()

	strings.write_string(&builder, "P3\n")
	strings.write_int(&builder, c.width)
	strings.write_byte(&builder, ' ')
	strings.write_int(&builder, c.height)
	strings.write_byte(&builder, '\n')
	strings.write_int(&builder, 255)
	strings.write_byte(&builder, '\n')

	for y in 0 ..< c.height {
		line_length := 0
		for x in 0 ..< c.width {

			col := c.pixels[x][y]
			pixel := [3]int{clamp_color(col.r), clamp_color(col.g), clamp_color(col.b)}
			// Adding a 0-255 subpixel char value will add either 2, 3, or 4 bytes.
			// 2 chars: space + 0-9
			// 3 chars: space + 10-99
			// 4 chars: space + 100-255
			// We also need to remember we need room for a newline out of the 70 bytes.
			// We only support 1 byte unix-like newlines.
			// Updates the line_length. If it's a new line, then 0.
			for sub_pixel in pixel {
				if line_length < 66 {
					// Handle common case where we can add any length sub_pixel to the line
					// Don't add space at beginning of a line
					if line_length > 0 do line_length += strings.write_byte(&builder, ' ')
					line_length += strings.write_int(&builder, sub_pixel)
				} else if (line_length < 65 && sub_pixel > 9) || (line_length < 66) {
					// Handle other cases where we can add the int and have enough space for a newline
					line_length += strings.write_byte(&builder, ' ')
					line_length += strings.write_int(&builder, sub_pixel)
				} else {
					// Handle cases where we don't have enough characters left
					strings.write_byte(&builder, '\n')
					line_length = strings.write_int(&builder, sub_pixel)
				}
			}
		}
		strings.write_byte(&builder, '\n')
	}

	return strings.to_string(builder)
}

clamp_color :: proc(val: f64) -> int {
	scaled := int(val * 255.0 + 0.5)
	if scaled < 0 do return 0
	if scaled > 255 do return 255
	return scaled
}

save_ppm :: proc(ppm: string, filename: string) -> bool {
	return os.write_entire_file(filename, transmute([]byte)ppm)
}

@(test)
canvas_creation_test :: proc(t: ^testing.T) {
	c := canvas(10, 20)
	defer canvas_destroy(c)
	testing.expect_value(t, c.width, 10)
	testing.expect_value(t, c.height, 20)
	for y in 0 ..< 20 {
		for x in 0 ..< 10 {
			testing.expect(t, equal(pixel_at(c, x, y), color(0, 0, 0)))
		}
	}
}

@(test)
canvas_write_pixel_test :: proc(t: ^testing.T) {
	c := canvas(10, 20)
	defer canvas_destroy(c)
	red := color(1, 0, 0)
	write_pixel(&c, 2, 3, red)
	testing.expect(t, equal(pixel_at(c, 2, 3), red))
}

@(test)
canvas_ppm_header_test :: proc(t: ^testing.T) {
	c := canvas(5, 3)
	defer canvas_destroy(c)
	ppm := canvas_to_ppm(c)
	defer delete(ppm)
	lines := strings.split_lines(ppm)
	defer delete(lines)
	testing.expect(t, lines[0] == "P3")
	testing.expect(t, lines[1] == "5 3")
	testing.expect(t, lines[2] == "255")
}

@(test)
canvas_ppm_pixel_data_test :: proc(t: ^testing.T) {
	c := canvas(5, 3)
	defer canvas_destroy(c)
	write_pixel(&c, 0, 0, color(1.5, 0, 0))
	write_pixel(&c, 2, 1, color(0, 0.5, 0))
	write_pixel(&c, 4, 2, color(-0.5, 0, 1))
	ppm := canvas_to_ppm(c)
	defer delete(ppm)
	lines := strings.split_lines(ppm)
	defer delete(lines)
	testing.expect(t, lines[3] == "255 0 0 0 0 0 0 0 0 0 0 0 0 0 0")
	testing.expect(t, lines[4] == "0 0 0 0 0 0 0 128 0 0 0 0 0 0 0")
	testing.expect(t, lines[5] == "0 0 0 0 0 0 0 0 0 0 0 0 0 0 255")
}

@(test)
canvas_ppm_line_splitting_test :: proc(t: ^testing.T) {
	c := canvas(10, 2)
	defer canvas_destroy(c)
	color_val := color(1, 0.8, 0.6)
	for y in 0 ..< 2 {
		for x in 0 ..< 10 {
			write_pixel(&c, x, y, color_val)
		}
	}
	ppm := canvas_to_ppm(c)
	defer delete(ppm)
	lines := strings.split_lines(ppm)
	defer delete(lines)
	testing.expect(
		t,
		lines[3] == "255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204",
	)
	testing.expect(t, lines[4] == "153 255 204 153 255 204 153 255 204 153 255 204 153")
	testing.expect(
		t,
		lines[5] == "255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204",
	)
	testing.expect(t, lines[6] == "153 255 204 153 255 204 153 255 204 153 255 204 153")
}

@(test)
canvas_ppm_trailing_newline_test :: proc(t: ^testing.T) {
	c := canvas(5, 3)
	defer canvas_destroy(c)
	ppm := canvas_to_ppm(c)
	defer delete(ppm)
	testing.expect(t, ppm[len(ppm) - 1] == '\n')
}
