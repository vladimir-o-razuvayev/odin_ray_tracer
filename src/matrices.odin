package main

import "core:testing"

Matrix1 :: distinct [1][1]f32
Matrix2 :: distinct [2][2]f32
Matrix3 :: distinct [3][3]f32
Matrix4 :: distinct [4][4]f32

identity_matrix :: proc() -> Matrix4 {
	return {{1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}}
}

matrix_multiply :: proc(a, b: Matrix4) -> (res: Matrix4) {
	for x in 0 ..< 4 {
		for y in 0 ..< 4 {
			res[x][y] =
				a[x][0] * b[0][y] + a[x][1] * b[1][y] + a[x][2] * b[2][y] + a[x][3] * b[3][y]
		}
	}
	return res
}

matrix_multiply_tuple :: proc(m: Matrix4, t: $T/Tuple) -> T {
	return T {
		m[0][0] * t.x + m[0][1] * t.y + m[0][2] * t.z + m[0][3] * t.w,
		m[1][0] * t.x + m[1][1] * t.y + m[1][2] * t.z + m[1][3] * t.w,
		m[2][0] * t.x + m[2][1] * t.y + m[2][2] * t.z + m[2][3] * t.w,
		m[3][0] * t.x + m[3][1] * t.y + m[3][2] * t.z + m[3][3] * t.w,
	}
}

transpose :: proc(m: Matrix4) -> (res: Matrix4) {
	for i in 0 ..< 4 {for j in 0 ..< 4 {res[j][i] = m[i][j]}}
	return res
}

_determinant_1x1 :: proc(m: Matrix1) -> f32 {return m[0][0]}
_determinant_2x2 :: proc(m: Matrix2) -> f32 {
	return m[0][0] * m[1][1] - m[0][1] * m[1][0]
}
_determinant_3x3 :: proc(m: Matrix3) -> f32 {
	return m[0][0] * cofactor(m, 0, 0) + m[0][1] * cofactor(m, 0, 1) + m[0][2] * cofactor(m, 0, 2)
}
_determinant_4x4 :: proc(m: Matrix4) -> f32 {
	return(
		m[0][0] * cofactor(m, 0, 0) +
		m[0][1] * cofactor(m, 0, 1) +
		m[0][2] * cofactor(m, 0, 2) +
		m[0][3] * cofactor(m, 0, 3) \
	)
}
determinant :: proc {
	_determinant_1x1,
	_determinant_2x2,
	_determinant_3x3,
	_determinant_4x4,
}

is_invertible :: proc(m: $M) -> bool {return !equal(determinant(m), 0.0)}

_submatrix_2x2 :: proc(m: Matrix2, row, col: int) -> (res: Matrix1) {
	_submatrix(m, &res, row, col, 3)
	return res
}
_submatrix_3x3 :: proc(m: Matrix3, row, col: int) -> (res: Matrix2) {
	_submatrix(m, &res, row, col, 3)
	return res
}
_submatrix_4x4 :: proc(m: Matrix4, row, col: int) -> (res: Matrix3) {
	_submatrix(m, &res, row, col, 4)
	return res
}
_submatrix :: proc(m: $M1, rm: $M2, row, col, size: int) {
	r := 0
	for i in 0 ..< size {
		if i == row do continue
		c := 0
		for j in 0 ..< size {
			if j == col do continue
			rm^[r][c] = m[i][j]
			c += 1
		}
		r += 1
	}
}
submatrix :: proc {
	_submatrix_2x2,
	_submatrix_3x3,
	_submatrix_4x4,
}

_minor_2x2 :: proc(m: Matrix2, row, col: int) -> f32 {
	return determinant(submatrix(m, row, col))
}
_minor_3x3 :: proc(m: Matrix3, row, col: int) -> f32 {
	return determinant(submatrix(m, row, col))
}
_minor_4x4 :: proc(m: Matrix4, row, col: int) -> f32 {
	return determinant(submatrix(m, row, col))
}
minor :: proc {
	_minor_2x2,
	_minor_3x3,
	_minor_4x4,
}

_cofactor_2x2 :: proc(m: Matrix2, row, col: int) -> f32 {return _cofactor(m, row, col)}
_cofactor_3x3 :: proc(m: Matrix3, row, col: int) -> f32 {return _cofactor(m, row, col)}
_cofactor_4x4 :: proc(m: Matrix4, row, col: int) -> f32 {return _cofactor(m, row, col)}
_cofactor :: proc(m: $M, row, col: int) -> f32 {
	min := minor(m, row, col)
	if (row + col) % 2 != 0 do return -min
	else do return min
}
cofactor :: proc {
	_cofactor_2x2,
	_cofactor_3x3,
	_cofactor_4x4,
}

_inverse_2x2 :: proc(m: Matrix2) -> (res: Matrix2, ok: bool) #optional_ok {
	return _inverse(m, 2)
}
_inverse_3x3 :: proc(m: Matrix3) -> (res: Matrix3, ok: bool) #optional_ok {
	return _inverse(m, 3)
}
_inverse_4x4 :: proc(m: Matrix4) -> (res: Matrix4, ok: bool) #optional_ok {
	return _inverse(m, 4)
}
_inverse :: proc(m: $M, size: int) -> (res: M, ok: bool) #optional_ok {
	if is_invertible(m) {
		for i in 0 ..< size {
			for j in 0 ..< size {
				c := cofactor(m, i, j)
				// note that "col, row" here, instead of "row, col",
				// accomplishes the transpose operation!
				res[j][i] = c / determinant(m)
			}
		}
		return res, true
	} else {
		return res, false
	}
}
inverse :: proc {
	_inverse_2x2,
	_inverse_3x3,
	_inverse_4x4,
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
	testing.expect_value(t, determinant(m), 17.0)
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

@(test)
invertible_matrix_test :: proc(t: ^testing.T) {
	a := Matrix4{{6, 4, 4, 4}, {5, 5, 7, 6}, {4, -9, 3, -7}, {9, 1, 7, -6}}
	testing.expect_value(t, determinant(a), -2120)
	testing.expect(t, is_invertible(a))
}

@(test)
noninvertible_matrix_test :: proc(t: ^testing.T) {
	a := Matrix4{{-4, 2, -2, -3}, {9, 6, 2, 6}, {0, -5, 1, -5}, {0, 0, 0, 0}}
	testing.expect_value(t, determinant(a), 0)
	testing.expect(t, !is_invertible(a))
}

@(test)
inverse_matrix_test :: proc(t: ^testing.T) {
	a := Matrix4{{-5, 2, 6, -8}, {1, -5, 1, 8}, {7, 7, -6, -7}, {1, -3, 7, 4}}
	b := inverse(a)
	testing.expect_value(t, determinant(a), 532)
	testing.expect_value(t, cofactor(a, 2, 3), -160)
	testing.expect(t, equal(b[3][2], -160.0 / 532.0))
	testing.expect_value(t, cofactor(a, 3, 2), 105)
	testing.expect(t, equal(b[2][3], 105.0 / 532.0))
	expected := Matrix4 {
		{0.21805, 0.45113, 0.24060, -0.04511},
		{-0.80827, -1.45677, -0.44361, 0.52068},
		{-0.07895, -0.22368, -0.05263, 0.19737},
		{-0.52256, -0.81391, -0.30075, 0.30639},
	}
	testing.expect(t, equal(b, expected))
}

@(test)
inverse_matrix_2_test :: proc(t: ^testing.T) {
	a := Matrix4{{8, -5, 9, 2}, {7, 5, 6, 1}, {-6, 0, 9, 6}, {-3, 0, -9, -4}}
	expected := Matrix4 {
		{-0.15385, -0.15385, -0.28205, -0.53846},
		{-0.07692, 0.12308, 0.02564, 0.03077},
		{0.35897, 0.35897, 0.43590, 0.92308},
		{-0.69231, -0.69231, -0.76923, -1.92308},
	}
	b := inverse(a)
	testing.expect(t, equal(b, expected))
}

@(test)
inverse_matrix_3_test :: proc(t: ^testing.T) {
	a := Matrix4{{9, 3, 0, 9}, {-5, -2, -6, -3}, {-4, 9, 6, 4}, {-7, 6, 6, 2}}
	expected := Matrix4 {
		{-0.04074, -0.07778, 0.14444, -0.22222},
		{-0.07778, 0.03333, 0.36667, -0.33333},
		{-0.02901, -0.14630, -0.10926, 0.12963},
		{0.17778, 0.06667, -0.26667, 0.33333},
	}
	b := inverse(a)
	testing.expect(t, equal(b, expected))
}

@(test)
product_inverse_multiplication_test :: proc(t: ^testing.T) {
	a := Matrix4{{3, -9, 7, 3}, {3, -8, 2, -9}, {-4, 4, 4, 1}, {-6, 5, -1, 1}}
	b := Matrix4{{8, 2, 2, 2}, {3, -1, 7, 0}, {7, 0, 5, 4}, {6, -2, 0, 5}}
	c := matrix_multiply(a, b)
	B_inv := inverse(b)
	result := matrix_multiply(c, B_inv)
	testing.expect(t, equal(result, a))
}
