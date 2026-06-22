--information:PageRoll_S ${PACKAGE_VERSION} by ${AUTHOR}
--label:変形
--filter
--require:${LEAST_AVIUTL_VERSION}
---$track:距離, min = 0, max = 4000, step = 0.01, scale = 0.5
local distance = 0

---$track:角度, min = -3600, max = 3600, step = 0.01, scale = 0.1
local angle = -90

---$track:太さ, min = 8, max = 4000, step = 0.01, scale = 0.125
local width = 80

--group:カメラ設定,false
---$track:視点X, min = -4000, max = 4000, step = 0.01, scale = 0.25
local X = 0

---$track:視点Y, min = -4000, max = 4000, step = 0.01, scale = 0.25
local Y = 0

--trackgroup@X,Y:camera_pos
---$track:視野角, min = 0, max = 120, step = 0.01
local fov = 70

--group
---$track:陰影, min = 0, max = 100, step = 0.01
local shadow = 50

---$checksection:領域外も描画
local unbound = true

--group:裏地設定,false
---$select:裏地種類
---元画像/画像ファイル = 1
---フレームバッファ = 2
---仮想バッファ = 3
local backface = 1

---$file:裏地画像
local file_image = ""

---$select:裏地向き
---通常 = 0
---左右反転 = 1
---上下反転 = 2
---180°反転 = 3
local back_orient = 0

--group:その他,false
---$value:PI
local PI = {}

--[[pixelshader@apply:
---$include "effect_apply.hlsl"
]]
local obj, math, tonumber, type, unpack = obj, math, tonumber, type, unpack;

-- set anchors.
obj.setanchor("X,Y", 0, "line");

-- take parameters.
--[==[
	PI = {
		distance:		number?,
		angle:			number?,
		width:			number?,
		X:				number?,
		Y:				number?,
		fov:			number?,
		shadow:			number?,
		unbound:		boolean|number|nil,
		backface:		number?,
		file_image:		string?,
		back_orient:	number?,
	}
]==]
local function as_bool(t, v)
	if type(t) == "boolean" then return t;
	elseif type(t) == "number" then return t ~= 0;
	else return v end
end
distance = tonumber(PI.distance) or distance;
angle = tonumber(PI.angle) or angle;
width = tonumber(PI.width) or width;
X = tonumber(PI.X) or X;
Y = tonumber(PI.Y) or Y;
fov = tonumber(PI.fov) or fov;
shadow = tonumber(PI.shadow) or shadow;
unbound = as_bool(PI.unbound, unbound) and not obj.getinfo("filter");
if PI.backface then
	local name2num = {
		[0] = 0, 1, 2, 3; -- legacy compatibility.
		["元画像"] = 0, ["元画像/画像ファイル"] = 1, ["フレームバッファ"] = 2, ["仮想バッファ"] = 3
	};
	backface = name2num[PI.backface] or backface;
end
file_image = type(PI.file_image) == "string" and PI.file_image or file_image;
if PI.back_orient then
	local name2num = {
		[0] = 0, 1, 2, 3; -- legacy compatibility.
		["通常"] = 0, ["左右反転"] = 1, ["上下反転"] = 2, ["180°反転"] = 3
	};
	back_orient = name2num[PI.back_orient] or back_orient;
end

-- normalize parameters.
distance = math.max(distance, 0);
angle = math.pi / 180 * angle;
width = math.max(width, 8);
X, Y = X + obj.w / 2, Y + obj.h / 2;
fov = math.min(math.max(math.pi / 180 * fov, 0), (2 / 3) * math.pi);
shadow = math.min(math.max(shadow / 100, 0), 1);
backface = math.min(math.max(math.floor(0.5 + backface), 0), 3); -- 0: object, 1: file_image, 2: framebuffer, 3: tempbuffer.
if #file_image < 4 then
	-- no valid file name.
	if backface == 1 then backface = 0 end
end
back_orient = math.min(math.max(math.floor(0.5 + back_orient), 0), 3);

-- early return for trivial cases.
if distance == 0 then return end

-- further calculations.
local w, h = obj.w, obj.h;
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
local cache_name = "cache:pageroll_s/obj";
local img_x, img_x0, img_y, img_y0 = 1, 0, 1, 0;
if backface > 0 then
	obj.copybuffer(cache_name, "object");

	-- try loading the specified image.
	local has_image = true;
	if backface == 1 then
		local obj_props = { obj.ox, obj.oy, obj.oz, obj.cx, obj.cy, obj.cz, obj.rx, obj.ry, obj.rz, obj.sx, obj.sy, obj.sz, obj.alpha };
		has_image = obj.load("image", file_image);
		obj.ox, obj.oy, obj.oz, obj.cx, obj.cy, obj.cz, obj.rx, obj.ry, obj.rz, obj.sx, obj.sy, obj.sz, obj.alpha = unpack(obj_props);
	else
		has_image = obj.copybuffer("object",
			backface == 2 and "framebuffer" or "tempbuffer");
	end
	if not has_image then
		-- no valid image.
		obj.copybuffer("object", cache_name);
		backface = 0;
	end

	-- crop to match the aspect ratio.
	if obj.w * h < obj.h * w then
		local top = math.min(math.floor(0.5 + obj.h - obj.w * h / w), obj.h - 1);
		local btm = math.floor(top / 2);
		top = top - btm;
		while top > 0 or btm > 0 do
			local t, b = math.min(top, 4000), math.min(btm, 4000);
			top, btm = top - t, btm - b;
			obj.effect("クリッピング", "上", t, "下", b, "中心の位置を変更", 1);
		end
	else
		local lft = math.min(math.floor(0.5 + obj.w - obj.h * w / h), obj.w - 1);
		local rit = math.floor(lft / 2);
		lft = lft - rit;
		while lft > 0 or rit > 0 do
			local l, r = math.min(lft, 4000), math.min(rit, 4000);
			lft, rit = lft - l, rit - r;
			obj.effect("クリッピング", "左", l, "右", r, "中心の位置を変更", 1);
		end
	end
end

-- handle the orientation.
if back_orient % 2 == 1 then img_x, img_x0 = -1, 1 end
if back_orient >= 2 then img_y, img_y0 = -1, 1 end

-- draw by shader.
obj.clearbuffer("tempbuffer", L + w + R, T + h + B);
obj.pixelshader("apply", "tempbuffer", { backface > 0 and cache_name or "object", "object" }, {
	w, h; L, T;
	s, -c; tilt_z * c, tilt_z * s;
	pos_x, pos_y;
	img_x / w, img_y / h; img_x0, img_y0;
	radius, width / 2, (width / D) * fov_rate * rad_rate, shadow,
}, "copy", "clip");
obj.copybuffer("object", "tempbuffer");

-- adjust the center.
obj.cx, obj.cy = obj.cx + (L - R) / 2, obj.cy + (T - B) / 2;
