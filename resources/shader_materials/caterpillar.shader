shader_type canvas_item;

void vertex() {
	VERTEX.x += (UV.x - 0.5) * sin(10.0 * TIME);
	VERTEX.y += (UV.y - 0.5) * cos(10.0 * TIME);
}