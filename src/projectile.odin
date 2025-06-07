package main

import "core:fmt"
import "core:testing"

Projectile :: struct {
	position: Point,
	velocity: Vector,
}

Environment :: struct {
	gravity: Vector,
	wind:    Vector,
}

tick :: proc(env: Environment, proj: Projectile) -> Projectile {
	new_position := add(proj.position, proj.velocity)
	new_velocity := add(add(proj.velocity, env.gravity), env.wind)
	return Projectile{new_position, new_velocity}
}

//****************************************/
// Tests
//****************************************/

@(test)
tick_basic_motion_test :: proc(t: ^testing.T) {
	proj := Projectile {
		position = point(0, 1, 0),
		velocity = vector(1, 1, 0),
	}
	env := Environment {
		gravity = vector(0, -0.1, 0),
		wind    = vector(-0.01, 0, 0),
	}

	result := tick(env, proj)

	expected_position := point(1, 2, 0)
	expected_velocity := vector(0.99, 0.9, 0)

	testing.expect(t, equal(result.position, expected_position))
	testing.expect(t, equal(result.velocity, expected_velocity))
}

@(test)
tick_multiple_steps_test :: proc(t: ^testing.T) {
	p := Projectile {
		position = point(0, 0, 0),
		velocity = vector(1, 2, 0),
	}
	e := Environment {
		gravity = vector(0, -1, 0),
		wind    = vector(0, 0, 0),
	}

	// Step once
	p = tick(e, p)
	testing.expect(t, equal(p.position, point(1, 2, 0)))
	testing.expect(t, equal(p.velocity, vector(1, 1, 0)))

	// Step again
	p = tick(e, p)
	testing.expect(t, equal(p.position, point(2, 3, 0)))
	testing.expect(t, equal(p.velocity, vector(1, 0, 0)))
}
