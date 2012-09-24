precision highp float;

attribute vec3 vPosition;
attribute vec3 vNormal;
attribute vec2 vTexCoord;

uniform mat4 projectionViewTransform;
uniform mat4 projectionTransform;
uniform mat4 viewTransform;
uniform mat4 normalTransform;
uniform mat4 objectTransform;

uniform vec3 lightDirection;

varying vec3 surfaceNormal;
varying vec2 samplePoint;
varying vec3 lightDir;

void main() {
	// TexCoord
	samplePoint = vTexCoord;
    // Normal
    //mat4 LM = normalTransform*objectTransform;
    vec3 N = (objectTransform*vec4(vNormal, 0.0)).xyz;
    N = normalize(N);
    N = (normalTransform*vec4(N, 0.0)).xyz;
    surfaceNormal = normalize(N);
    lightDir = (normalTransform*vec4(lightDirection, 0.0)).xyz;
    //lightDir = lightDirection;
    // Position
    vec4 vPosition4 = vec4(vPosition.x, vPosition.y, vPosition.z, 1.0);
    mat4 M = projectionViewTransform*objectTransform;
    gl_Position = M*vPosition4;
}
