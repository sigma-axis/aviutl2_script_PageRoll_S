--[[
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
]]

--
-- VERSION: v1.10
--

--------------------------------

local GLShaderKit = require "GLShaderKit";
local obj, tonumber, math, unpack = obj, tonumber, math, unpack;

local function error_mod(message)
	message = "PageRoll_S.lua: "..message;
	debug_print(message);
	local function err_mes()
		obj.setfont("MS UI Gothic", 42, 3);
		obj.load("text", message);
		obj.draw();
	end
	return setmetatable({}, { __index = function(...) return err_mes end });
end
if not GLShaderKit.isInitialized() then return error_mod [=[このデバイスでは GLShaderKit が利用できません!]=];
else
	local function lexical_comp(a, b, ...)
		return a == nil and 0 or a < b and -1 or a > b and 1 or lexical_comp(...);
	end
	local version = GLShaderKit.version();
	local v1, v2, v3 = version:match("^(%d+)%.(%d+)%.(%d+)$");
	v1, v2, v3 = tonumber(v1), tonumber(v2), tonumber(v3);
	-- version must be at least v0.4.0.
	if not (v1 and v2 and v3) or lexical_comp(v1, 0, v2, 4, v3, 0) < 0 then
		debug_print([=[現在の GLShaderKit のバージョン: ]=]..version);
		return error_mod [=[この GLShaderKit のバージョンでは動作しません!]=];
	end
end

-- ref: https://github.com/Mr-Ojii/AviUtl-RotBlur_M-Script/blob/main/script/RotBlur_M.lua
local function script_path()
    return debug.getinfo(1).source:match("@?(.*[/\\])");
end
local shader_path = script_path().."PageRoll_S.frag";

-- remove redundant escape sequence from a file path.
local unescape_shiftjis do
	local char_pat, t_concat = "[\129-\159\224-\252]?.", table.concat;
	function unescape_shiftjis(s)
		if not s then return s end
		local i, n, ret = 1, 1, {};
		while i <= #s do
			local j, k = s:find(char_pat, i);
			if not j then break end
			i = k + 1;
			if j < k and k < #s and
				s:sub(k, k + 1) == [[\\]] then i = k + 2 end
			n, ret[n] = n + 1, s:sub(j, k);
		end
		return t_concat(ret);
	end
end

---applies an effect to roll the image like a piece of paper.
---@param distance number the distance of the roll from the edge of the image, in pixels.
---@param angle number the angle to roll up the page, in radians.
---@param width number the width of the rolled-up part, in pixels.
---@param X number the x-coodinate of the position of the camera, in pixels, origins at the center of the object.
---@param Y number the y-coodinate of the position of the camera, in pixels, origins at the center of the object.
---@param fov number the angle of the field of view, in radians.
---@param shadow number the intensity of the shadow, from 0 to 1.
---@param unbound boolean specifies if the size of the image expands as the rolled part goes out of the boundaries.
---@param backface integer specifies which image to show as the backside of the image. 0: current object, 1: specified file, 2: framebuffer, 3: tempbuffer.
---@param file_image string? the path to the image file to place on the backside of the object. ignored if `backface` is not 1.
---@param back_orient integer the orientation of the backside. 0: normal, 1: flip horizontally, 2: flip vertically, 3: rotate by 180 degree.
local function apply_effect(distance, angle, width, X, Y, fov, shadow, unbound, backface, file_image, back_orient)
	local w, h = obj.getpixel();

	distance = math.max(distance, 0);
	width = math.max(width, 8);
	X, Y = X + w / 2, Y + h / 2;
	fov = math.min(math.max(fov, 0), (2 / 3) * math.pi);
	shadow = math.min(math.max(shadow, 0), 1);
	backface = math.min(math.max(backface, 0), 3);
	file_image = unescape_shiftjis(file_image);
	if not file_image or #file_image < 4 then
		-- no valid file name.
		if backface == 1 then backface = 0 end
	else file_image = file_image:match[[^"?(.-)"?$]] end
	back_orient = math.min(math.max(back_orient, 0), 3);

	-- early return for trivial cases.
	if distance == 0 then return end

	-- further calculations.
	local c, s = math.cos(angle), math.sin(angle);
	local pos_x, pos_y =
		w / 2 - (s > 0 and 1 or -1) * w / 2 + s * distance,
		h / 2 + (c > 0 and 1 or -1) * h / 2 - c * distance;
	local d = c * (X - pos_x) + s * (Y - pos_y);
	pos_x, pos_y = pos_x + d * c, pos_y + d * s;
	local fov_rate = math.tan(fov / 2);
	local D = (w ^ 2 + h ^ 2) ^ 0.5;
	local tilt_z = (2 / D * fov_rate) ^ 0.5;
	local rad_rate = (width / D) * fov_rate;
	rad_rate = 1 / (rad_rate + (rad_rate ^ 2 + 1) ^ 0.5); -- 1/(tan(t)+cos(t)), where tan(t) = width * tan(fov/2).
	local radius = rad_rate * width / 2;

	-- calculate the extension of the region.
	local L, R, T, B = 0, 0, 0, 0;
	if unbound and distance > 0 then
		-- track the path of the rolled paper.
		local ts, u0 = {}, s * pos_x - c * pos_y;
		if u0 > 0 then ts[#ts + 1] = 0 end
		if u0 - s * w > 0 then ts[#ts + 1] = c * w end
		if u0 + c * h > 0 then ts[#ts + 1] = s * h end
		if u0 - s * w + c * h > 0 then ts[#ts + 1] = c * w + s * h end
		if s ~= 0 then
			local x = u0 / s;
			if 0 < x and x < w then ts[#ts + 1] = c * x end
			x = (c * h + u0) / s;
			if 0 < x and x < w then ts[#ts + 1] = c * x + s * h end
		end
		if c ~= 0 then
			local y = -u0 / c;
			if 0 < y and y < h then ts[#ts + 1] = s * y end
			y = (s * w - u0) / c;
			if 0 < y and y < h then ts[#ts + 1] = c * w + s * y end
		end

		if #ts > 0 then
			-- calculate the visible size of the rolled part.
			local tm, tM, t0, r =
				math.min(unpack(ts)), math.max(unpack(ts)), c * pos_x + s * pos_y,
				1 / (1 - 2 * ((1 - math.cos(math.min(math.pi, distance / radius))) * radius / D) * fov_rate);
			L, R, T, B =
				r * c * (tm - t0), r * c * (tM - t0),
				r * s * (tm - t0), r * s * (tM - t0);
			local width2 = math.min(width / 2, r * math.sin(math.min(math.pi / 2, distance / radius)) * radius);
			if L > R then L, R = R, L end
			if T > B then T, B = B, T end
			L, R, T, B =
				L - math.abs(s) * width2 + pos_x, R + math.abs(s) * width2 + pos_x,
				T - math.abs(c) * width2 + pos_y, B + math.abs(c) * width2 + pos_y;

			-- convert to the extension size.
			L, R, T, B =
				math.max(math.ceil(-L), 0),
				math.max(math.ceil(R - w), 0),
				math.max(math.ceil(-T), 0),
				math.max(math.ceil(B - h), 0);

			-- cap to the maximum size of image.
			local max_w, max_h = obj.getinfo("image_max");
			if L + w + R > max_w then
				local M = math.floor((max_w - w) / 2);
				if L < M then R = 2 * M - L;
				elseif R < M then L = 2 * M - R;
				else L, R = M, M end
			end
			if T + h + B > max_h then
				local M = math.floor((max_h - h) / 2);
				if T < M then B = 2 * M - T;
				elseif B < M then T = 2 * M - B;
				else T, B = M, M end
			end

		end
	end

	-- load the image if specified.
	local obj_props = { obj.ox, obj.oy, obj.oz, obj.cx, obj.cy, obj.cz, obj.rx, obj.ry, obj.rz, obj.zoom, obj.aspect, obj.alpha };
	local has_image, img_x, img_x0, img_y, img_y0 = backface > 0, 1, 0, 1, 0;
	if has_image then
		local cache_name = backface > 2 and "cache:pageroll_s/obj" or "tmp";
		obj.copybuffer(cache_name, "obj");

		-- try loading the specified image.
		if backface == 1 then
			obj.load("image", file_image);
			local W, H = obj.getpixel();
			has_image = W > 0 and H > 0;
		else
			has_image = obj.copybuffer("obj",
				backface == 2 and "frm" or "tmp");
			if cache_name ~= "tmp" then obj.copybuffer("tmp", cache_name) end
		end
		if not has_image then
			-- no valid image.
			obj.copybuffer("obj", "tmp");
		end
		img_x, img_y = obj.getpixel();

		-- crop to match the aspect ratio.
		if img_x * h < img_y * w then
			local dh = math.min(math.floor(0.5 + img_y - img_x * h / w), img_y - 1);
			if dh > 0 then
				local dh2 = math.floor(dh / 2);
				obj.effect("クリッピング", "上", dh - dh2, "下", dh2);
				img_y = img_y - dh;
			end
		else
			local dw = math.min(math.floor(0.5 + img_x - img_y * w / h), img_x - 1);
			if dw > 0 then
				local dw2 = math.floor(dw / 2);
				obj.effect("クリッピング", "左", dw - dw2, "右", dw2);
				img_x = img_x - dw;
			end
		end
		img_x, img_y = img_x / w, img_y / h;
	end

	-- handle the orientation.
	if back_orient % 2 == 1 then img_x, img_x0 = -img_x, w * img_x end
	if back_orient >= 2 then img_y, img_y0 = -img_y, h * img_y end

	-- prepare shader context.
	GLShaderKit.activate()
	GLShaderKit.setPlaneVertex(1);
	GLShaderKit.setShader(shader_path, false);

	-- send image buffer to gpu.
	local data, W, H = obj.getpixeldata();
	GLShaderKit.setTexture2D(1, data, W, H);
	if has_image then obj.copybuffer("obj", "tmp") end
	GLShaderKit.setTexture2D(0, obj.getpixeldata());

	-- send uniform variables.
	GLShaderKit.setInt("size", L + w + R, T + h + B);
	GLShaderKit.setInt("offset", L, T);
	GLShaderKit.setFloat("dir", s, -c);
	GLShaderKit.setFloat("tilt_z", tilt_z * c, tilt_z * s);
	GLShaderKit.setFloat("view_center", pos_x, pos_y);
	GLShaderKit.setInt("img_sz", w, h);
	GLShaderKit.setInt("back_sz", W, H);
	GLShaderKit.setFloat("back_x", img_x, img_x0);
	GLShaderKit.setFloat("back_y", img_y, img_y0);
	GLShaderKit.setFloat("radius", radius);
	GLShaderKit.setFloat("hf_width", width / 2);
	GLShaderKit.setFloat("tan_hf_roll", (width / D) * fov_rate * rad_rate);
	GLShaderKit.setFloat("shadow", shadow);

	-- prepare the canvas.
	if L > 0 or R > 0 or T > 0 or B > 0 then
		local L1, R1, T1, B1 = L, R, T, B;
		while L1 > 0 or R1 > 0 or T1 > 0 or B1 > 0 do
			-- can extend up to only 4000 pixels.
			local L2, R2, T2, B2 =
				math.min(L1, 4000), math.min(R1, 4000),
				math.min(T1, 4000), math.min(B1, 4000);
			L1, R1, T1, B1 = L1 - L2, R1 - R2, T1 - T2, B1 - B2;
			obj.effect("領域拡張","左", L2, "右", R2, "上", T2, "下", B2);
		end
	end

	-- invoke the shader.
	data = obj.getpixeldata("work");
	GLShaderKit.draw("TRIANGLES", data, L + w + R, T + h + B);

	-- close the shader context.
	GLShaderKit.deactivate();

	-- put back the result.
	obj.putpixeldata(data);

	-- adjust the center.
	obj.ox, obj.oy, obj.oz, obj.cx, obj.cy, obj.cz, obj.rx, obj.ry, obj.rz, obj.zoom, obj.aspect, obj.alpha = unpack(obj_props);
	obj.cx, obj.cy = obj.cx + (L - R) / 2, obj.cy + (T - B) / 2;
end

---applies the scene change effect of page roll.
---@param angle number the angle to roll up the page, in radians.
---@param width number the width of the rolled-up part, relative to the length of the diagonal line of the screen.
---@param X number the x-coodinate of the position of the camera, in pixels, origins at the center of the screen.
---@param Y number the y-coodinate of the position of the camera, in pixels, origins at the center of the screen.
---@param fov number the angle of the field of view, in radians.
---@param shadow number the intensity of the shadow, from 0 to 1.
---@param backface integer specifies which image to show as the backside of the image. 0: prevous scene, 1: next scene, 2: file_image, 3: tempbuffer.
---@param file_image string? the path to the image file to place on the backside of the object. ignored if `backface` is not 2.
---@param back_orient integer the orientation of the backside. 0: normal, 1: flip horizontally, 2: flip vertically, 3: rotate by 180 degree.
---@param phase number the phase of the scene change, from 0 to 1.
local function scene_change(angle, width, X, Y, fov, shadow, backface, file_image, back_orient, phase)
	width = math.min(math.max(width, 0), 1.5);
	fov = math.min(math.max(fov, 0), (2 / 3) * math.pi);
	shadow = math.min(math.max(shadow, 0), 1);
	backface = math.min(math.max(backface, 0), 3);
	back_orient = math.min(math.max(back_orient, 0), 3);
	phase = math.min(math.max(phase, 0), 1);

	local D = (obj.screen_w ^ 2 + obj.screen_h ^ 2) ^ 0.5;
	width = math.max(width * D, 8);

	-- further calculations.
	local c, s = math.cos(angle), math.sin(angle);
	local distance = phase * (width / 2 + math.abs(s) * obj.screen_w + math.abs(c) * obj.screen_h);

	-- shade the background image.
	if shadow > 0 then
		local grad_w = (3 / 4) * width;
		obj.copybuffer("tmp", "obj");
		obj.effect("グラデーション", "角度", 180 / math.pi * angle, "幅", grad_w,
			"中心X", -(s > 0 and 1 or -1) * obj.screen_w / 2 + s * (distance - grad_w / 2),
			"中心Y", (c > 0 and 1 or -1) * obj.screen_h / 2 - c * (distance - grad_w / 2),
			"color", 0x010101 * math.floor(255 * (1 - shadow)), "color2", 0xffffff);
		obj.setoption("blend", 3); -- multiply.
		obj.draw();
		obj.setoption("blend", 0);
		obj.copybuffer("obj", "tmp");
	end

	-- apply rolling deformation.
	apply_effect(distance, angle, width, X, Y, fov, shadow, false,
		backface == 0 and 0 or backface == 1 and 2 or backface == 2 and 1 or backface,
		file_image, back_orient);

	-- draw to framebuffer.
	obj.draw();
end

-- return the library table.
return {
	apply_effect = apply_effect,
	scene_change = scene_change,
};
