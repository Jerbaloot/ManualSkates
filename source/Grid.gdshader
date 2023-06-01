shader_type spatial;

uniform float density = 1.0;
uniform vec4 line_color : source_color = vec4(0.0);
uniform vec4 plane_color : source_color = vec4(1.0);

void fragment() {
	float is_grid_x = fract(UV.x*density);
	is_grid_x = step(.95,is_grid_x);
	float is_grid_y = fract(UV.y*density);
	is_grid_y = step(.95,is_grid_y);
	float is_grid = min((is_grid_y + is_grid_x),1.);
	
	
	ALBEDO = is_grid * line_color.rgb + (1.0-is_grid) * plane_color.rgb;
	
}
