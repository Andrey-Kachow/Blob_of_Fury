shader_type canvas_item;

void fragment() {
	COLOR = textureLod(SCREEN_TEXTURE, UV, 0.0);
}