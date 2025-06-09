package main

import "core:testing"

Matrix2 :: distinct [2][2]f64
Matrix3 :: distinct [3][3]f64
Matrix4 :: distinct [4][4]f64


matrix_multiply :: proc(a, b: Matrix4) -> Matrix4 {
	result: Matrix4
	for x in 0 ..< 4 {
		for y in 0 ..< 4 {
			result[x][y] =
				a[x][0] * b[0][y] + a[x][1] * b[1][y] + a[x][2] * b[2][y] + a[x][3] * b[3][y]
		}
	}
	return result
}

matrix_multiply_tuple :: proc(m: Matrix4, t: $T/Tuple) -> Tuple {
	return Tuple {
		m[0][0] * t.x + m[0][1] * t.y + m[0][2] * t.z + m[0][3] * t.w,
		m[1][0] * t.x + m[1][1] * t.y + m[1][2] * t.z + m[1][3] * t.w,
		m[2][0] * t.x + m[2][1] * t.y + m[2][2] * t.z + m[2][3] * t.w,
		m[3][0] * t.x + m[3][1] * t.y + m[3][2] * t.z + m[3][3] * t.w,
	}
}

//****************************************/
// Tests
//****************************************/

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

@(test)
matrix_multiply_test :: proc(t: ^testing.T) {
	a := Matrix4{{1, 2, 3, 4}, {5, 6, 7, 8}, {9, 8, 7, 6}, {5, 4, 3, 2}}
	b := Matrix4{{-2, 1, 2, 3}, {3, 2, 1, -1}, {4, 3, 6, 5}, {1, 2, 7, 8}}
	expected := Matrix4{{20, 22, 50, 48}, {44, 54, 114, 108}, {40, 58, 110, 102}, {16, 26, 46, 42}}
	testing.expect(t, equal(matrix_multiply(a, b), expected))
}

@(test)
matrix_multiply_tuple_test :: proc(t: ^testing.T) {
	a := Matrix4{{1, 2, 3, 4}, {2, 4, 4, 2}, {8, 6, 4, 1}, {0, 0, 0, 1}}
	b := Tuple{1, 2, 3, 1}
	expected := Tuple{18, 24, 33, 1}
	result := matrix_multiply_tuple(a, b)
	testing.expect(t, equal(result, expected))
}
