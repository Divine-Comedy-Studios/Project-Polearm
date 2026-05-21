class_name PPUtil


const DEBUG_BUILD : bool = true


enum CollisionLayers {
	entities = 0,
	player = 1,
	world = 15,
}


class Groups:
	const agents := &"Agents"


enum ObjectType {
	none = 0,

	entity = 1 << 0,
	player = entity + (1 << 1),

	enemies = entity + (1 << 4),
	testEnemy = enemies + (1 << 5),
}


class Math:
	static func rotateVectorOntoPlain(input: Vector3, normal: Vector3) -> Vector3:
		return (input - input.dot(normal) * normal).normalized() * input.length()

	static func flatLength(vec: Vector3) -> float:
		return sqrt(vec.x * vec.x + vec.z * vec.z)

	static func flatLengthSquared(vec: Vector3) -> float:
		return vec.x * vec.x + vec.z * vec.z


	static func toRangeNormalized(n: float, first: float, second: float) -> float:
		return n / first - 1.0 if n < first else (n - first) / (second - first)
