shader_type canvas_item;

uniform float amplitude;
uniform float inv_wavelength; // wavelength^(-1), where wavelength is width of the sprite
uniform float frequency;

const float TWO_PI = 6.2832;

vec2 sine_wave( vec2 p, float time ) {
	float y = sin(p.x * inv_wavelength * TWO_PI) * amplitude * sin(frequency * TWO_PI * time);
	return vec2(p.x, p.y + y);
}

void fragment() {
	COLOR = texture(TEXTURE, sine_wave(UV, TIME));
}

/*
shader_type canvas_item;

vec2 sine_wave( vec2 p )
    {
    float x = sin(25.0 * p.y + 30.0 * p.x + 6.28) * 0.05;
    float y = sin(25.0 * p.y + 30.0 * p.x + 6.28) * 0.05;
    return vec2(p.x + x, p.y + y);
    }

void fragment() {
    COLOR = texture(TEXTURE, sine_wave(UV));
}
*/