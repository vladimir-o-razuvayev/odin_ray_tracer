package main

import "core:fmt"

main :: proc() {
	p := Projectile {
		position = point(0, 1, 0),
		velocity = scale(normalize(vector(1, 1, 0)), 1), // Try 1.5 or 2.0
	}
	e := Environment {
		gravity = vector(0, -0.1, 0),
		wind    = vector(-0.01, 0, 0),
	}

	tick_count := 0
	for p.position.y > 0.0 {
		fmt.println("Tick:", tick_count, "Position:", p.position)
		p = tick(e, p)
		tick_count += 1
	}

	fmt.println("Hit the ground after", tick_count, "ticks.")
}
