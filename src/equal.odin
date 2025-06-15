package main

import "core:log"

EPSILON: f32 : 0.00005

// equal
// A Vector should not be compared for equality with a Point (w == 0 or w == 1)
_equal_mm :: proc(a, b: Material) -> bool {return a == b}
_equal_tt :: proc(a, b: Tuple) -> bool {return _equal(a, b)}
_equal_cc :: proc(a, b: Color) -> bool {return _equal(a, b)}
_equal_pp :: proc(a, b: Point) -> bool {return _equal(a, b)}
_equal_vv :: proc(a, b: Vector) -> bool {return _equal(a, b)}
_equal_ff :: proc(a, b: f32, loc := #caller_location) -> bool {
	if abs(a - b) < EPSILON {
		return true
	} else {
		log.errorf("%v Expected %.2f to be equal to %.2f", loc.procedure, a, b)
		return false
	}
}
_equal_m4 :: proc(a, b: Matrix4) -> bool {return _equal_matrix(a, b, 4)}
_equal_m3 :: proc(a, b: Matrix3) -> bool {return _equal_matrix(a, b, 3)}
_equal_m2 :: proc(a, b: Matrix2) -> bool {return _equal_matrix(a, b, 2)}
_equal_matrix :: proc(a, b: $M, size: int) -> bool {
	for row in 0 ..< size {
		for col in 0 ..< size {
			if abs(a[row][col] - b[row][col]) > EPSILON do return false
		}
	}
	return true
}
_equal :: proc(a: $T1/Tuple, b: $T2/Tuple) -> bool {
	for i in 0 ..< 4 {
		if abs(a[i] - b[i]) > EPSILON {
			return false
		}
	}
	return true
}
equal :: proc {
	_equal_mm,
	_equal_tt,
	_equal_cc,
	_equal_pp,
	_equal_vv,
	_equal_ff,
	_equal_m4,
	_equal_m3,
	_equal_m2,
}
