package main

import "core:testing"

Matrix2 :: distinct [2][2]f64
Matrix3 :: distinct [3][3]f64
Matrix4 :: distinct [4][4]f64

identity_matrix :: proc() -> Matrix4 {
	return {{1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}}
}

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

transpose :: proc(m: Matrix4) -> Matrix4 {
	result: Matrix4
	for i in 0 ..< 4 {for j in 0 ..< 4 {result[j][i] = m[i][j]}}
	return result
}

_determinant_2x2 :: proc(m: Matrix2) -> f64 {
	return m[0][0] * m[1][1] - m[0][1] * m[1][0]
}
_determinant_3x3 :: proc(m: Matrix3) -> f64 {
	return m[0][0] * cofactor(m, 0, 0) + m[0][1] * cofactor(m, 0, 1) + m[0][2] * cofactor(m, 0, 2)
}
_determinant_4x4 :: proc(m: Matrix4) -> f64 {
	return(
		m[0][0] * cofactor(m, 0, 0) +
		m[0][1] * cofactor(m, 0, 1) +
		m[0][2] * cofactor(m, 0, 2) +
		m[0][3] * cofactor(m, 0, 3) \
	)
}
determinant :: proc {
	_determinant_2x2,
	_determinant_3x3,
	_determinant_4x4,
}

_submatrix_3x3 :: proc(m: Matrix3, row, col: int) -> Matrix2 {
	result: Matrix2
	r := 0
	for i in 0 ..< 3 {
		if i == row do continue
		c := 0
		for j in 0 ..< 3 {
			if j == col do continue
			result[r][c] = m[i][j]
			c += 1
		}
		r += 1
	}
	return result
}
_submatrix_4x4 :: proc(m: Matrix4, row, col: int) -> Matrix3 {
	result: Matrix3
	r := 0
	for i in 0 ..< 4 {
		if i == row do continue
		c := 0
		for j in 0 ..< 4 {
			if j == col do continue
			result[r][c] = m[i][j]
			c += 1
		}
		r += 1
	}
	return result
}
submatrix :: proc {
	_submatrix_3x3,
	_submatrix_4x4,
}

_minor_3x3 :: proc(m: Matrix3, row, col: int) -> f64 {
	return determinant(submatrix(m, row, col))
}
_minor_4x4 :: proc(m: Matrix4, row, col: int) -> f64 {
	return determinant(submatrix(m, row, col))
}
minor :: proc {
	_minor_3x3,
	_minor_4x4,
}

_cofactor_3x3 :: proc(m: Matrix3, row, col: int) -> f64 {
	min := minor(m, row, col)
	if (row + col) % 2 != 0 do return -min
	else do return min
}
_cofactor_4x4 :: proc(m: Matrix4, row, col: int) -> f64 {
	min := minor(m, row, col)
	if (row + col) % 2 != 0 do return -min
	else do return min
}
cofactor :: proc {
	_cofactor_3x3,
	_cofactor_4x4,
}

//****************************************/
// Tests
//****************************************/

@(test)
matrix4_inspect_test :: proc(t: ^testing.T) {
	m := Matrix4{{1, 2, 3, 4}, {5.5, 6.5, 7.5, 8.5}, {9, 10, 11, 12}, {13.5, 14.5, 15.5, 16.5}}
	testing.expect_value(t, m[0][0], 1)
	testing.expect_value(t, m[0][3], 4)
	testing.expect_value(t, m[1][0], 5.5)
	testing.expect_value(t, m[1][2], 7.5)
	testing.expect_value(t, m[2][2], 11)
	testing.expect_value(t, m[3][0], 13.5)
	testing.expect_value(t, m[3][2], 15.5)
}

@(test)
matrix2_test :: proc(t: ^testing.T) {
	m := Matrix2{{-3, 5}, {1, -2}}
	testing.expect_value(t, m[0][0], -3)
	testing.expect_value(t, m[0][1], 5)
	testing.expect_value(t, m[1][0], 1)
	testing.expect_value(t, m[1][1], -2)
}

@(test)
matrix3_test :: proc(t: ^testing.T) {
	m := Matrix3{{-3, 5, 0}, {1, -2, -7}, {0, 1, 1}}
	testing.expect_value(t, m[0][0], -3)
	testing.expect_value(t, m[1][1], -2)
	testing.expect_value(t, m[2][2], 1)
}

@(test)
matrix4_equal_test :: proc(t: ^testing.T) {
	a := Matrix4{{1, 2, 3, 4}, {5, 6, 7, 8}, {9, 8, 7, 6}, {5, 4, 3, 2}}
	b := Matrix4{{1, 2, 3, 4}, {5, 6, 7, 8}, {9, 8, 7, 6}, {5, 4, 3, 2}}
	c := Matrix4{{2, 3, 4, 5}, {6, 7, 8, 9}, {8, 7, 6, 5}, {4, 3, 2, 1}}
	testing.expect(t, equal(a, b))
	testing.expect(t, !equal(a, c))
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

@(test)
matrix_multiply_identity_test :: proc(t: ^testing.T) {
	a := Matrix4{{0, 1, 2, 4}, {1, 2, 4, 8}, {2, 4, 8, 16}, {4, 8, 16, 32}}
	testing.expect(t, equal(matrix_multiply(a, identity_matrix()), a))
}

@(test)
identity_multiply_tuple_test :: proc(t: ^testing.T) {
	a := Tuple{1, 2, 3, 4}
	testing.expect(t, equal(matrix_multiply_tuple(identity_matrix(), a), a))
}

@(test)
transpose_test :: proc(t: ^testing.T) {
	a := Matrix4{{0, 9, 3, 0}, {9, 8, 0, 8}, {1, 8, 5, 3}, {0, 0, 5, 8}}
	expected := Matrix4{{0, 9, 1, 0}, {9, 8, 8, 0}, {3, 0, 5, 5}, {0, 8, 3, 8}}
	testing.expect(t, equal(transpose(a), expected))
}

@(test)
transpose_identity_test :: proc(t: ^testing.T) {
	a := transpose(identity_matrix())
	testing.expect(t, equal(a, identity_matrix()))
}

@(test)
determinant_2x2_test :: proc(t: ^testing.T) {
	m := Matrix2{{1, 5}, {-3, 2}}
	expected := 17.0
	testing.expect_value(t, determinant(m), expected)
}

@(test)
submatrix_3x3_to_2x2_test :: proc(t: ^testing.T) {
	m := Matrix3{{1, 5, 0}, {-3, 2, 7}, {0, 6, -3}}
	expected := Matrix2{{-3, 2}, {0, 6}}
	result := submatrix(m, 0, 2)
	testing.expect(t, equal(result, expected))
}

@(test)
submatrix_4x4_to_3x3_test :: proc(t: ^testing.T) {
	m := Matrix4{{-6, 1, 1, 6}, {-8, 5, 8, 6}, {-1, 0, 8, 2}, {-7, 1, -1, 1}}
	expected := Matrix3{{-6, 1, 6}, {-8, 8, 6}, {-7, -1, 1}}
	result := submatrix(m, 2, 1)
	testing.expect(t, equal(result, expected))
}

@(test)
minor_3x3_test :: proc(t: ^testing.T) {
	a := Matrix3{{3, 5, 0}, {2, -1, -7}, {6, -1, 5}}
	b := submatrix(a, 1, 0)
	testing.expect_value(t, determinant(b), 25)
	testing.expect_value(t, minor(a, 1, 0), 25)
}

@(test)
cofactor_3x3_test :: proc(t: ^testing.T) {
	a := Matrix3{{3, 5, 0}, {2, -1, -7}, {6, -1, 5}}
	testing.expect_value(t, minor(a, 0, 0), -12)
	testing.expect_value(t, cofactor(a, 0, 0), -12)
	testing.expect_value(t, minor(a, 1, 0), 25)
	testing.expect_value(t, cofactor(a, 1, 0), -25)
}

@(test)
determinant_3x3_test :: proc(t: ^testing.T) {
	a := Matrix3{{1, 2, 6}, {-5, 8, -4}, {2, 6, 4}}
	testing.expect_value(t, cofactor(a, 0, 0), 56)
	testing.expect_value(t, cofactor(a, 0, 1), 12)
	testing.expect_value(t, cofactor(a, 0, 2), -46)
	testing.expect_value(t, determinant(a), -196)
}

@(test)
determinant_4x4_test :: proc(t: ^testing.T) {
	a := Matrix4{{-2, -8, 3, 5}, {-3, 1, 7, 3}, {1, 2, -9, 6}, {-6, 7, 7, -9}}
	testing.expect_value(t, cofactor(a, 0, 0), 690)
	testing.expect_value(t, cofactor(a, 0, 1), 447)
	testing.expect_value(t, cofactor(a, 0, 2), 210)
	testing.expect_value(t, cofactor(a, 0, 3), 51)
	testing.expect_value(t, determinant(a), -4071)
}
