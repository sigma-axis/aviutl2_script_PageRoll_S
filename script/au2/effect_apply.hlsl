Texture2D img : register(t0);
Texture2D back : register(t1);
SamplerState smp : register(s0);
cbuffer constant0 : register(b0) {
	float2 size, offset, dir, tilt_z, view_center,
		back_1, back_0;
	float radius, hf_width, tan_hf_roll, shadow;
};
static const float pi = 3.141592653589793;

float4 thicken(float4 col, float density)
{
	const float r = col.a < 1.0 / 1024 ? density * (1 - col.a) :
		(1 - pow(max(1 - col.a, 0), density)) / col.a;
	return r * col;
}
float4 blend(float4 col_base, float4 col_over)
{
	return (1 - col_over.a) * col_base + col_over;
}
float4 apply(float4 pos : SV_Position) : SV_Target
{
	const float2 pos0 = pos.xy - offset;
	const float l = dot(dir, pos0 - view_center);
	float4 col = l >= 0 ? img.Load(int3(floor(pos0), 0)) : 0;

	if (-hf_width <= l && l <= hf_width) {
		const float r = abs(l / radius), s = r * tan_hf_roll,
			a00 = atan(s), a01 = acos(min((r - s) / sqrt(1 + s * s), 1)),
			a1 = l < 0 ? pi / 2 + a00 - a01 : 1.5 * pi - a00 + a01,
			a2 = l < 0 ? pi / 2 + a00 + a01 : 1.5 * pi - a00 - a01,
			z1 = radius * (1 - cos(a1)), z2 = radius * (1 - cos(a2)),
			h = sqrt(max(1 - l * l / (hf_width * hf_width), 0)),
			sh = 1 - (1 - h) * shadow,
			density = 1 / max(h, 1.0 / 1024);

		const float2 pt0 = pos0 - l * dir,
			tilt_z0 = dot(tilt_z, pos0 - view_center) * tilt_z,
			roll = -2 * pi * radius * dir;
		float4 col_b = 0, col_f = 0;
		for (float2 pt = pt0 - a1 * radius * dir - z1 * tilt_z0;
			all(roll < 0 ? pt >= -0.5 : pt < size + 0.5);
			pt += roll)
			col_b = blend(col_b, thicken(img.SampleLevel(smp, pt / size, 0), density));
		for (pt = pt0 - a2 * radius * dir - z2 * tilt_z0;
			all(roll < 0 ? pt >= -0.5 : pt < size + 0.5);
			pt += roll)
			col_f = blend(thicken(back.SampleLevel(smp, back_1 * pt + back_0, 0), density), col_f);

		col_b.rgb *= sh;
		col_b = blend(col_b, col_f);
		col_b.rgb *= sh;
		col_b *= saturate(hf_width - abs(l));
		col = blend(col, col_b);
	}
	return col;
}
