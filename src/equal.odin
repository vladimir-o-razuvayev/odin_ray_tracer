package main

EPSILON: f64 : 2.2204460492503131e-016

// equal
// A Vector should not be compared for equality with a Point (w == 0 or w == 1)
equal_cc :: proc(a, b: Color) -> bool {return _equal(a, b)}
equal_pp :: proc(a, b: Point) -> bool {return _equal(a, b)}
equal_vv :: proc(a, b: Vector) -> bool {return _equal(a, b)}
equal_ff :: proc(a, b: f64) -> bool {return abs(a - b) < EPSILON}
equal_m4 :: proc(a, b: Matrix4) -> bool {
	for row in 0 ..< 4 {
		for col in 0 ..< 4 {
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
	equal_cc,
	equal_pp,
	equal_vv,
	equal_ff,
	equal_m4,
}
