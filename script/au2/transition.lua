--information:PageRoll_S(シーンチェンジ) ${PACKAGE_VERSION} by ${AUTHOR}
--label:シーンチェンジ
--require:${LEAST_AVIUTL_VERSION}
---$track:角度, min = -3600, max = 3600, step = 0.01, scale = 0.1
local angle = -90

---$track:太さ, min = 2, max = 150, step = 0.01, scale = 0.33334
local width = 20

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

--group:裏地設定,false
---$select:裏地
---上側 = 0
---下側 = 1
---指定画像 = 2
local backface = 0

---$file:裏地画像
local file_image = ""

---$select:裏地向き
---通常 = 0
---左右反転 = 1
---上下反転 = 2
---180°反転 = 3
local back_orient = 0

--group
---$checksection:反転
local reverse = false

--group:その他,false
---$value:PI
local PI = {}

--[[pixelshader@combine:
---$include "transition_combine.hlsl"
]]
local obj, math, tonumber, type = obj, math, tonumber, type;

-- set anchors.
obj.setanchor("X,Y", 0, "line");

-- take parameters.
--[==[
	PI = {
		angle:			number?,
		width:			number?,
		X:				number?,
		Y:				number?,
		fov:			number?,
		shadow:			number?,
		backface:		string?,
		file_image:		string?,
		back_orient:	string?,
		reverse:		boolean|number|nil,
		phase:			number?,
	}
]==]
local function as_bool(t, v)
	if type(t) == "boolean" then return t;
	elseif type(t) == "number" then return t ~= 0;
	else return v end
end
angle = tonumber(PI.angle) or angle;
width = tonumber(PI.width) or width;
X = tonumber(PI.X) or X;
Y = tonumber(PI.Y) or Y;
fov = tonumber(PI.fov) or fov;
shadow = tonumber(PI.shadow) or shadow;
if PI.backface then
	local name2num = {
		[0] = 0, 1, 2; -- legacy compatibility.
		["上側"] = 0, ["下側"] = 1, ["指定画像"] = 2
	};
	backface = name2num[PI.backface] or backface;
end
file_image = type(PI.file_image) == "string" and PI.file_image or file_image;
if type(PI.back_orient) == "string" then back_orient = PI.back_orient;
else
	-- legacy compatibility.
	back_orient = tonumber(PI.back_orient) or back_orient;
end
reverse = as_bool(PI.reverse, reverse);
local phase = tonumber(PI.phase) or obj.getvalue("scenechange");

-- normalize parameters.
angle = math.pi / 180 * angle;
width = math.max(width / 100 * (obj.screen_w ^ 2 + obj.screen_h ^ 2) ^ 0.5, 8);
fov = math.min(math.max(math.pi / 180 * fov, 0), (2 / 3) * math.pi);
shadow = math.min(math.max(shadow / 100, 0), 1);
backface = math.min(math.max(math.floor(0.5 + backface), 0), 3); -- 3: tempbuffer.
if #file_image < 4 then
	-- no valid file name.
	if backface == 2 then backface = 0 end
end
if type(back_orient) ~= "string" then
	back_orient = ({
		[0] = "通常", "左右反転", "上下反転", "180°反転"
	})[back_orient] or "通常";
end
phase = math.min(math.max(phase, 0), 1);

-- further calculations.
local c, s = math.cos(angle), math.sin(angle);
if reverse then
	phase = 1 - phase;
	local cache_name = backface == 3 and "cache:pageroll_s/obj" or "tempbuffer";
	obj.copybuffer(cache_name, "object");
	obj.copybuffer("object", "framebuffer");
	obj.copybuffer("framebuffer", cache_name);
end
local distance = phase * (width / 2 + math.abs(s) * obj.screen_w + math.abs(c) * obj.screen_h);

-- apply rolling deformation.
obj.effect("PageRoll_S", "PI",
	("distance=%s,angle=%s,width=%s,X=%s,Y=%s,fov=%s,shadow=%s,unbound=false,backface=%d,back_orient=%q,file_image=%q"):format(
		distance, 180 / math.pi * angle, width, X, Y, 180 / math.pi * fov, 100 * shadow,
		backface == 0 and 0 or backface == 1 and 2 or backface == 2 and 1 or backface,
		back_orient, file_image));

-- shade and combine.
obj.pixelshader("combine", "framebuffer", { "object", "framebuffer" },
{
	2 * s / width, -2 * c / width;
	(s > 0 and 0 or obj.screen_w) + s * distance,
	(c > 0 and obj.screen_h or 0) - c * distance;
	shadow,
});
