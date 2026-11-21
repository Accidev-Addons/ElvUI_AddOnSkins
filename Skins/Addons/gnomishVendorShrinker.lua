local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")
local AS = E:GetModule("AddOnSkins")

if not AS:IsAddonLODorEnabled("GnomishVendorShrinker") then return end

local ipairs, select, unpack = ipairs, select, unpack

local GetItemInfo = GetItemInfo
local hooksecurefunc = hooksecurefunc

local function SkinAltCurrency(row)
	for i = row.altframesSkinned + 1, #row.altframes do
		S:HandleIcon(row.altframes[i].icon)
	end
	row.altframesSkinned = #row.altframes
end

local function UpdateIconBorder(row)
	local quality = row.link and select(3, GetItemInfo(row.link))
	if quality and quality > 1 then
		row.icon.backdrop:SetBackdropBorderColor(E:GetItemQualityColor(quality))
	else
		row.icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end
end

local function SkinRow(row)
	S:HandleIcon(row.icon, true)
	UpdateIconBorder(row)
	hooksecurefunc(row, "SetID", UpdateIconBorder)

	local highlight = row:GetHighlightTexture()
	S:HandleButtonHighlight(highlight)
	highlight:SetTexCoord(0, 1, 0, 1)

	S:HandleNextPrevButton(row.popout, "right", nil, true)
	row.popout:Size(17)
	row.popout:SetHitRectInsets(0, 0, -2, -2)

	row.altframesSkinned = 0
	SkinAltCurrency(row)
	hooksecurefunc(row, "AddAltCurrency", SkinAltCurrency)
end

local function SkinScrollBar(slider)
	for _, child in ipairs({slider:GetChildren()}) do
		if child:IsObjectType("Button") then
			if child:GetPoint() == "BOTTOM" then
				slider.ScrollUpButton = child
			else
				slider.ScrollDownButton = child
			end
		else
			child:SetBackdrop(nil)
		end
	end

	S:HandleSirusScrollBar(slider)
	slider:Point("TOPRIGHT", -4, -16)
	slider:Point("BOTTOMRIGHT", -4, 16)
end

local function SkinChildren(GVS)
	for _, child in ipairs({GVS:GetChildren()}) do
		if not child.isSkinned then
			local objType = child:GetObjectType()

			if objType == "Button" and child.popout then
				SkinRow(child)
			elseif objType == "CheckButton" then
				S:HandleCheckBox(child)
			elseif objType == "EditBox" then
				for _, region in ipairs({child:GetRegions()}) do
					if region:GetDrawLayer() == "BORDER" then
						region:SetTexture(nil)
					end
				end

				child:Height(18)
				child:Point("TOPLEFT", GVS, "BOTTOMLEFT", 1, -61)
				S:HandleEditBox(child)
			elseif objType == "Slider" then
				SkinScrollBar(child)
			end

			child.isSkinned = true
		end
	end
end

S:AddCallbackForAddon("GnomishVendorShrinker", "GnomishVendorShrinker", function()
	if not E.private.addOnSkins.GnomishVendorShrinker then return end
	if GVSEditBox then
		GVSEditBox:StripTextures()
		S:HandleEditBox(GVSEditBox)
		GVSEditBox:Size(135, 19)
		GVSEditBox:SetScale(1)

		GVSMerchantFrame:CreateBackdrop("Transparent")
		S:HandleButton(GVSScrollButton1)
		S:HandleButton(GVSScrollButton2)
		GVSScrollFrame:StripTextures()
		S:HandleSliderFrame(GVSScrollBar)

		return
	end

	local GVS = GVSFrame or AS:FindChildFrameByPoint(MerchantFrame, "Frame", "TOPLEFT", MerchantFrame, "TOPLEFT", 21, -77)
	if not GVS then return end

	GVS:CreateBackdrop("Transparent")
	GVS.backdrop:SetOutside(GVS, 3, 3)

	local EMP = WindTools and WindTools[1]:GetModule("ExtendMerchantPages", true)
	if not (EMP and EMP.initialized) then
		MerchantBuyBackItem:ClearAllPoints()
		MerchantBuyBackItem:Point("BOTTOMLEFT", 176, 33)
	end

	SkinChildren(GVS)

	if GVS.SetNumColumns then
		hooksecurefunc(GVS, "SetNumColumns", SkinChildren)
	end
end)