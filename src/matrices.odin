package main

import "core:testing"

Matrix2 :: distinct [2][2]f64
Matrix3 :: distinct [3][3]f64
Matrix4 :: distinct [4][4]f64

@(test)
matrix4_inspect_test :: proc(t: ^testing.T) {
	M := Matrix4{{1, 2, 3, 4}, {5.5, 6.5, 7.5, 8.5}, {9, 10, 11, 12}, {13.5, 14.5, 15.5, 16.5}}
	testing.expect_value(t, M[0][0], 1)
	testing.expect_value(t, M[0][3], 4)
	testing.expect_value(t, M[1][0], 5.5)
	testing.expect_value(t, M[1][2], 7.5)
	testing.expect_value(t, M[2][2], 11)
	testing.expect_value(t, M[3][0], 13.5)
	testing.expect_value(t, M[3][2], 15.5)
}

@(test)
matrix2_test :: proc(t: ^testing.T) {
	M := Matrix2{{-3, 5}, {1, -2}}
	testing.expect_value(t, M[0][0], -3)
	testing.expect_value(t, M[0][1], 5)
	testing.expect_value(t, M[1][0], 1)
	testing.expect_value(t, M[1][1], -2)
}

@(test)
matrix3_test :: proc(t: ^testing.T) {
	M := Matrix3{{-3, 5, 0}, {1, -2, -7}, {0, 1, 1}}
	testing.expect_value(t, M[0][0], -3)
	testing.expect_value(t, M[1][1], -2)
	testing.expect_value(t, M[2][2], 1)
}

@(test)
matrix4_equal_test :: proc(t: ^testing.T) {
	A := Matrix4{{1, 2, 3, 4}, {5, 6, 7, 8}, {9, 8, 7, 6}, {5, 4, 3, 2}}
	B := Matrix4{{1, 2, 3, 4}, {5, 6, 7, 8}, {9, 8, 7, 6}, {5, 4, 3, 2}}
	C := Matrix4{{2, 3, 4, 5}, {6, 7, 8, 9}, {8, 7, 6, 5}, {4, 3, 2, 1}}

	testing.expect(t, equal(A, B))
	testing.expect(t, !equal(A, C))
}
