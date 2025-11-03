shader_type canvas_item;

uniform sampler2D noise:repeat_enable;
uniform sampler2D noise2:repeat_enable;
uniform vec2 scroll1 = vec2(0.03,0.03);
uniform vec2 scroll2 = vec2(-0.03,-0.03);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float distortion_str: hint_range(-1, 1) = 0.2;
uniform vec4 water_color:source_color;

void fragment() {
	vec4 noise_col1 = texture(noise,SCREEN_UV+TIME*scroll1);
	vec4 noise_col2 = texture(noise2,SCREEN_UV+TIME*scroll2);
	vec4 screen_col = texture(
		SCREEN_TEXTURE,
		SCREEN_UV
			+distortion_str*noise_col1.rr*0.1
			-distortion_str*noise_col2.rr*0.1
		);
	COLOR = screen_col*water_color;
}
