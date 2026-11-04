using Godot;
using System;


public static class PPUtil {
	public static bool DEBUG_BUILD = true;


	public static class Math {	
		public static Vector3 RotateVectorOntoPlane(Vector3 input, Vector3 normal) {
			return (input - input.Dot(normal) * normal).Normalized() * input.Length();
		}

		public static float FlatLength(Vector3 vec) {
			return Mathf.Sqrt(vec.X * vec.X + vec.Z * vec.Z);
		}

		public static float FlatLengthSquared(Vector3 vec) {
			return vec.X * vec.X + vec.Z * vec.Z;
		}

		public static float NormalizeRange(float n, float first, float second) {
			if (n < first) return n / first - 1.0f;
			return (n - first) / (second - first);
		}
	}
}
