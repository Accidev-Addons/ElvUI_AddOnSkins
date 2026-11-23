local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")
local AS = E:GetModule("AddOnSkins")

if not AS:IsAddonLODorEnabled("MethodDungeonTools") then return end

local _G = _G
local ipairs = ipairs

local function ClearBackdropColor(frame)
	frame:SetBackdropColor(0, 0, 0, 0)
end

local function SkinTooltip(tooltip)
	if not tooltip then return end

	tooltip:SetTemplate("Transparent")
	S:ApplyElvUIFont(tooltip)
end

local function SkinPullButton(widget)
	local button = widget and widget.frame
	if not button or button.isSkinned then return end

	button:CreateBackdrop("Transparent")
	button.backdrop:SetInside(button, 2, 0)

	if widget.background then
		widget.background:SetAlpha(0)
	end

	local highlight = button:GetHighlightTexture()
	if highlight then
		S:HandleButtonHighlight(highlight)
		highlight:SetInside(button.backdrop)
	end

	S:HandleLockHighlight(button)
	button.selectedTex:SetInside(button.backdrop)
	S:ApplyElvUIFont(button)

	button.isSkinned = true
end

local function SkinPullButtons()
	local sidePanel = _G.MethodDungeonTools.main_frame.sidePanel

	for _, widget in ipairs(sidePanel.newPullButtons) do
		SkinPullButton(widget)
	end

	SkinPullButton(sidePanel.newPullButton)
end

local function SkinEnemyInfoFrame()
	local frame = _G.MethodDungeonTools.EnemyInfoFrame
	if not frame then return end

	if not frame.isSkinned then
		frame:SetTemplate("Transparent")

		if frame.closeBtn then
			S:HandleCloseButton(frame.closeBtn, frame)
		end

		S:ApplyElvUIFont(frame)
		frame.isSkinned = true
	end

	if frame.spellFrames then
		for _, spellFrame in ipairs(frame.spellFrames) do
			if spellFrame.icon and not spellFrame.icon.backdrop then
				S:HandleIcon(spellFrame.icon, true)
				S:ApplyElvUIFont(spellFrame)
			end
		end
	end
end

local function SkinMainFrame(frame)
	local topPanel, bottomPanel, sidePanel = frame.topPanel, frame.bottomPanel, frame.sidePanel

	for _, key in ipairs({"topPanelTex", "bottomPanelTex", "sidePanelTex"}) do
		if frame[key] then
			frame[key]:SetAlpha(0)
		end
	end

	frame:CreateBackdrop("Transparent")
	frame.backdrop:ClearAllPoints()
	frame.backdrop:Point("TOPLEFT", topPanel or frame, "TOPLEFT")
	frame.backdrop:Point("BOTTOMRIGHT", sidePanel or bottomPanel or frame, "BOTTOMRIGHT")

	if frame.scrollFrame then
		local border = CreateFrame("Frame", nil, frame)
		border.callbackBackdropColor = ClearBackdropColor
		border:SetTemplate()
		border:SetOutside(frame.scrollFrame)
	end

	if frame.closeButton and sidePanel then
		frame.closeButton:ClearAllPoints()
		S:HandleCloseButton(frame.closeButton, sidePanel)
	end

	for _, name in ipairs({"MDTDungeonSelectDropdown", "MDTDungeonSublevelDropdown", "MDTDungeonPresetDropdown"}) do
		local dropdown = _G[name]
		if dropdown then
			S:HandleDropDownBox(dropdown, dropdown:GetWidth())

			if dropdown:GetParent() == frame then
				local point, relativeTo, relativePoint, x, y = dropdown:GetPoint()
				dropdown:SetPoint(point, relativeTo, relativePoint, x, y - 3)
			end
		end
	end

	for _, key in ipairs({"sidePanelFortifiedCheckBox", "sidePanelTyrannicalCheckBox"}) do
		local image = frame[key] and frame[key].image
		if image then
			image:SetTexCoords()
		end
	end

	local bar = sidePanel and sidePanel.ProgressBar and sidePanel.ProgressBar.Bar
	if bar then
		S:HandleStatusBar(bar, {bar:GetStatusBarColor()})
	end

	if frame.GridToggle then
		S:HandleButton(frame.GridToggle)
	end

	S:ApplyElvUIFont(frame)
end

S:AddCallbackForAddon("MethodDungeonTools", "MethodDungeonTools", function()
	if not E.private.addOnSkins.MethodDungeonTools then return end

	local MDT = _G.MethodDungeonTools
	local frame = MDT and MDT.main_frame
	if not frame then return end

	AS:SkinLibrary("LibUIDropDownMenu")
	AS:SkinLibrary("LibDialog-1.0")

	SkinMainFrame(frame)
	SkinTooltip(_G.MethodDungeonToolsModelTooltip)
	SkinTooltip(MDT.pullTooltip)

	if frame.sidePanel and frame.sidePanel.newPullButtons then
		SkinPullButtons()

		if MDT.ReloadPullButtons then
			S:SecureHook(MDT, "ReloadPullButtons", SkinPullButtons)
		end
	end

	SkinEnemyInfoFrame()

	if MDT.ShowEnemyInfoFrame then
		S:SecureHook(MDT, "ShowEnemyInfoFrame", SkinEnemyInfoFrame)
	end
end)