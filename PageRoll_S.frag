/*
MIT License
Copyright (c) 2025 sigma-axis

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

https://mit-license.org/
*/

//
// VERSION: v1.00
//

////////////////////////////////
#version 460 core

in vec2 TexCoord;

layout(location = 0) out vec4 FragColor;

uniform sampler2D texture0;
uniform ivec2 size;
uniform vec2 dir;
uniform vec2 tilt_z;
uniform vec2 view_center;
uniform float radius;
uniform float hf_width;
uniform float tan_hf_roll;
uniform float shadow;

vec4 thicken(vec4 col, float density)
{
	return vec4(col.rgb, 1 - pow(max(1 - col.a, 0), density));
}
vec4 blend(vec4 col_base, vec4 col_over)
{
	const float a_base = (1 - col_over.a) * col_base.a,
		a = a_base + col_over.a;
	return a > 0 ? vec4((a_base * col_base.rgb + col_over.a * col_over.rgb) / a, a) : vec4(0.0);
}

vec4 pick(vec2 pos)
{
	vec4 col = texture(texture0, pos / size);
	const vec2 t = clamp(min(pos, size - pos) + 0.5, 0, 1);
	col.a *= t.x * t.y;
	return col;
}

bvec2 sel(bvec2 c, bvec2 t, bvec2 f)
{
	// vectorized c ? t : f.
	return (c && t) || (not(c) && f);
}

void main()
{
	const vec2 pos = TexCoord * size;
	const float l = dot(dir, pos - view_center);
	vec4 col = l >= 0 ? pick(pos) : vec4(0.0);
	if (-hf_width <= l && l <= hf_width) {
		const float pi = 3.141592653589793;
		const float r = abs(l / radius), s = r * tan_hf_roll,
			a00 = atan(s), a01 = acos(min((r - s) / sqrt(1 + s * s), 1)),
			a1 = l < 0 ? pi / 2 + a00 - a01 : 1.5 * pi - a00 + a01,
			a2 = l < 0 ? pi / 2 + a00 + a01 : 1.5 * pi - a00 - a01,
			z1 = radius * (1 - cos(a1)), z2 = radius * (1 - cos(a2)),
			h = sqrt(max(1 - l * l / (hf_width * hf_width), 0)),
			sh = 1 - (1 - h) * shadow,
			density = 1 / max(h, 1.0 / 1024);

		const vec2 pt0 = pos - l * dir,
			tilt_z0 = dot(tilt_z, pos - view_center) * tilt_z,
			roll = -2 * pi * radius * dir;
		vec4 col_b = vec4(0.0), col_f = vec4(0.0);
		for (vec2 pt = pt0 - a1 * radius * dir - z1 * tilt_z0;
			all(sel(lessThan(roll, vec2(0.0)), greaterThanEqual(pt, vec2(-0.5)), lessThan(pt, size + 0.5)));
			pt += roll)
			col_b = blend(col_b, thicken(pick(pt), density));
		for (vec2 pt = pt0 - a2 * radius * dir - z2 * tilt_z0;
			all(sel(lessThan(roll, vec2(0.0)), greaterThanEqual(pt, vec2(-0.5)), lessThan(pt, size + 0.5)));
			pt += roll)
			col_f = blend(thicken(pick(pt), density), col_f);

		col_b.rgb *= sh;
		col_b = blend(col_b, col_f);
		col_b.rgb *= sh;
		col_b.a *= clamp(hf_width - abs(l), 0, 1);
		col = blend(col, col_b);
	}
	FragColor = col;
}
