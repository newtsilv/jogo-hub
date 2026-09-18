shader_type canvas_item;

// Círculo "furo" transparente sobre um fundo preto. Anima-se o raio
// (via script) para fechar a tela até ficar tudo preto, ou abrir a
// partir do centro revelando a cena por trás.

uniform vec2 center = vec2(0.5, 0.5);
uniform float radius = 1.0;
uniform float aspect = 1.0;
uniform float softness = 0.02;
uniform vec4 wipe_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	vec2 uv = UV;
	uv.x *= aspect;

	vec2 corrected_center = vec2(center.x * aspect, center.y);
	float dist = distance(uv, corrected_center);

	float alpha = smoothstep(radius, radius + softness, dist);
	COLOR = vec4(wipe_color.rgb, wipe_color.a * alpha);
}
