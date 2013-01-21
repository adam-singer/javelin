attribute vec3 POSITION;
attribute vec3 TEXCOORD0;

uniform mat4 cameraView;
uniform mat4 cameraProjection;
uniform mat4 cameraProjectionView;
uniform mat4 cameraViewRotation;
uniform mat4 cameraProjectionViewRotation;
uniform mat4 objectTransform;

varying vec3 samplePoint;

void main(void)
{
	vec4 vPosition4 = vec4(POSITION.x*512.0,
			       POSITION.y*512.0,
			       POSITION.z*512.0,
			       1.0);
	gl_Position = cameraProjectionViewRotation*vPosition4;
	samplePoint = TEXCOORD0;
}
