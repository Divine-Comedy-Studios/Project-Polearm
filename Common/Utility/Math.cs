using Godot;
using System;


public partial class PPUtil_Math {
	public static Vector3 rotateVectorOntoPlane(Vector3 input, Vector3 normal) => RotateVectorOntoPlane(input, normal);
	public static Vector3 RotateVectorOntoPlane(Vector3 input, Vector3 normal) {
		return (input - input.Dot(normal) * normal).Normalized() * input.Length();
	}
}
