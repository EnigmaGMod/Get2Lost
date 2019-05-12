-- by DJTB
-- (music provided by IXXE)
-- v1.0 (2019-12-05)
-- Read LICENSE before making changes

local sW, sH = ScrW(), ScrH()

local prevFrame = {}
local prevValue = 1

surface.CreateFont("Get2Lost", {
	font = "Open Sans",
	size = 500,
	weight = 1000,
	antialias = true,
	scanlines = 2.5,
})

surface.CreateFont("Get2LostBlurred", {
	font = "Open Sans",
	size = 500,
	weight = 1000,
	antialias = true,
	blursize = 10
})

surface.SetFont("Get2Lost")
local tW, tH = surface.GetTextSize("ΣNIGMA")

local audio
local function AudioVizualier()
	if not audio then return end
	local tbl = {}
	audio:FFT(tbl, FFT_4096)

	prevValue = Lerp(5 * FrameTime(), prevValue, math.Rand(0, 1))
	local h = CurTime() * 250 % 360
	surface.SetDrawColor(ColorAlpha(HSVToColor(360 - h, 1, prevValue), 125))
	surface.DrawRect(0, 0, sW, sH)

	local color = HSVToColor(h, 1, prevValue)
	
	surface.SetFont("Get2LostBlurred")
	surface.SetTextColor(ColorAlpha(color_white, math.random(225, 255)))
	surface.SetTextPos(sW / 2 - tW / 2, sH / 2 - tH / 2)
	surface.DrawText("ΣNIGMA")

	surface.SetFont("Get2Lost")
	surface.SetTextColor(color)
	surface.SetTextPos(sW / 2 - tW / 2, sH / 2 - tH / 2)
	surface.DrawText("ΣNIGMA")

	surface.SetDrawColor(color)
	for i = 0, sW, 20 do
		local avg = 0
		for j = 1, 30 do
			avg = avg + tbl[i + j]
		end
		if not prevFrame[i] then prevFrame[i] = 0 end
		prevFrame[i] = Lerp(30 * FrameTime(), prevFrame[i], avg * 5000)
		
		surface.DrawRect(i, sH - prevFrame[i] + 1, 20, prevFrame[i])
		surface.DrawRect(sW - i - 20, sH - prevFrame[i] + 1, 20, prevFrame[i])

		surface.DrawRect(i, 0, 20, prevFrame[i])
		surface.DrawRect(sW - i - 20, 0, 20, prevFrame[i])
	end
end

sound.PlayURL("https://instaud.io/_/3FvL.mp3", "noblock", function(s)
	if not IsValid(s) then return end
	audio = s
	
	local oldhooks = {}
	for k, v in pairs(hook.GetTable().HUDPaint) do
		oldhooks[k] = v
		hook.Remove("HUDPaint", k)
	end

	hook.Add("HUDShouldDraw", "Get2Lost", function(n)
		if n == "CHudGMod" then return end
		return false
	end)

	hook.Add("HUDPaint", "Get2Lost", AudioVizualier)

	local intensity = 1
	timer.Create("ScreenShake", 5, 0, function()
		util.ScreenShake(vector_origin, 7 * intensity, 10, 5, 0)
		intensity = intensity + 1
	end)

	local function stop()
		audio = nil
		timer.Remove("ScreenShake")
		hook.Remove("HUDPaint", "Get2Lost")
		hook.Remove("HUDShouldDraw", "Get2Lost")
		for k, v in pairs(oldhooks) do
			hook.Add("HUDPaint", k, v)
			oldhooks[k] = nil
		end
		s:Stop()
	end
	timer.Simple(60, stop)
	concommand.Add("lelstop", stop)
end)
