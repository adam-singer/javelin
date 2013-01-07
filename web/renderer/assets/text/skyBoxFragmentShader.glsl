precision highp float;
varying vec3 samplePoint;
uniform samplerCube skyBoxCubeMap;

void main(void)
{
	vec4 color = textureCube(skyBoxCubeMap, samplePoint);
	//gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
	gl_FragColor = vec4(color.xyz, 1.0);
}
