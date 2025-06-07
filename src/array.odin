package main

import "core:fmt"
import "core:testing"

concat_arrays :: proc(a, b: [3]int) -> [6]int {
	return [6]int{a[0], a[1], a[2], b[0], b[1], b[2]}
}

@(test)
concat_arrays_test :: proc(t: ^testing.T) {
	a := [3]int{1, 2, 3}
	b := [3]int{3, 4, 5}

	expected := [6]int{1, 2, 3, 3, 4, 5}
	result := concat_arrays(a, b)

	testing.expect(t, result == expected)
}
