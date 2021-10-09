shader_type canvas_item;
uniform float radius : hint_range(0.1, 1) = 0.5;
uniform bool invert = false;

void fragment(){
	vec2 center = UV.xy - vec2(0.5, 0.5);
	COLOR = texture(TEXTURE, UV);
	if(!invert)
		COLOR.rgb = vec3(COLOR.r * 0.2 + COLOR.b * 0.6 + COLOR.g * 0.2) + vec3(0.2);
	else
		COLOR.rgb = vec3(1) - vec3(COLOR.r * 0.2 + COLOR.b * 0.6 + COLOR.g * 0.2) + vec3(0.2);		
	if(center.x * center.x + center.y * center.y > radius * radius)
		COLOR.a = 0.0;
}