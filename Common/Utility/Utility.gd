class_name PPUtil


const DEBUG_BUILD : bool = true


enum CollisionLayers {
	entities = 0,
	player = 1,
	world = 15,
}


class Groups:
	const enemies := &"Enemies"


class Math:
	static func rotateVectorOntoPlain(input: Vector3, normal: Vector3) -> Vector3:
		return (input - input.dot(normal) * normal).normalized() * input.length()

	static func flatLength(vec: Vector3) -> float:
		return sqrt(vec.x * vec.x + vec.z * vec.z)

	static func flatLengthSquared(vec: Vector3) -> float:
		return vec.x * vec.x + vec.z * vec.z


	static func toRangeNormalized(n: float, first: float, second: float) -> float:
		return n / first - 1.0 if n < first else (n - first) / (second - first)


	static func toFlatVec3(vec : Vector3, y : float = 0.0) -> Vector3:
		return Vector3(vec.x, y, vec.z)
	
	static func toFlatVec2(vec : Vector3) -> Vector2:
		return Vector2(vec.x, vec.z)
	
	static func flatToVec3(vec : Vector2, y : float = 0.0) -> Vector3:
		return Vector3(vec.x, y, vec.y)
