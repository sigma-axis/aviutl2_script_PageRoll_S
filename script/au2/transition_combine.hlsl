Texture2D img_prev : register(t0);
Texture2D img_next : register(t1);
cbuffer constant0 : register(b0) {
	float2 dir, view_center;
	float shadow;
};
float4 blend(float4 col_base, float4 col_over)
{
	return (1 - col_over.a) * col_base + col_over;
}
float4 combine(float4 pos : SV_Position) : SV_Target
{
	const float l = dot(dir, pos.xy - view_center);
	float4 col = saturate(0.5 - 2 * l) * img_next[pos.xy];
	col.rgb *= 1 - shadow * saturate(1 + (2.0 / 3) * l);
	return blend(col, img_prev[pos.xy]);
}
