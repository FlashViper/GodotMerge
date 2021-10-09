shader_type canvas_item;
uniform bool invert = false;

void fragment(){
	COLOR = texture(TEXTURE, UV);

	if(!invert)
		COLOR.rgb = vec3(COLOR.r * 0.2 + COLOR.b * 0.6 + COLOR.g * 0.2) + vec3(0.2);
	else
		COLOR.rgb = vec3(1) - vec3(COLOR.r * 0.2 + COLOR.b * 0.6 + COLOR.g * 0.2) + vec3(0.2);		
}