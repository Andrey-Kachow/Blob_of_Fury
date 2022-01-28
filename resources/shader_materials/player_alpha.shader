shader_type canvas_item;

uniform bool invulnerable;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if (invulnerable == true && COLOR.a > 0.0) {
		COLOR.a = 0.6 + 0.2 * sin(10.0 * TIME);		
	}
}