-- 4tt3nti0n cr1ng3
local tag = "DNDD"
local bin = "xyi/bin.png"
local w, h, imageSize = ScrW(), ScrH(), ScreenScale(256)
local sizeX, sizeY = w*0.5, h*0.5

hook.Add("OnScreenSizeChanged", "ResHandle", function()
    w, h, imageSize = ScrW(), ScrH(), ScreenScale(256)
    sizeX, sizeY = w*0.05, h*0.1
end)

for k, v in pairs(player.GetAll()) do
    v:SetNoDraw(false)
end

local binX, binY = 0, 0
local selected_ply, bin_pnl

local function Stop()
    hook.Remove("HUDPaint", tag)
    hook.Remove("PlayerButtonUp", tag)
    hook.Remove("PlayerButtonDown", tag)

    if IsValid(selected_ply) then
        local x, y = input.GetCursorPos()
        local newX, newY = x - sizeX*0.5, y - sizeY*0.9
        if IsValid(bin_pnl) then 
            local bin_posx, bin_posy = bin_pnl:GetPos()
            local bin_sizex, bin_sizey = bin_pnl:GetSize() 
            if (newX > bin_posx and newY > bin_posy) and (bin_posx-newX < bin_sizex and bin_posy-newY < bin_sizey) then
                net.Start("PlayerInBin")
                    net.WriteEntity(selected_ply)
                net.SendToServer()
            end
            
            selected_ply:SetNoDraw(false)
            bin_pnl:Remove()
        end
    elseif IsValid(bin_pnl) then
        bin_pnl:Remove()
    end
end

hook.Add("OnContextMenuOpen", tag, function()
    local binX, binY = (ScrW()-imageSize)/2, ScrH()*0.9-imageSize/2
    bin_pnl = vgui.Create("Material")
    bin_pnl:SetPos(binX, binY)
    bin_pnl:SetMaterial(bin)

    local localplayer = LocalPlayer()
    
    hook.Add("PlayerButtonDown", tag, function(ply, key)
        if key == MOUSE_LEFT and IsFirstTimePredicted() then
            local tr = ply:GetEyeTrace()
            if tr.Hit then
                selected_ply = tr.Entity
                if IsValid(selected_ply) and selected_ply:IsPlayer() then
                    selected_ply:SetNoDraw(true)

                    hook.Add("HUDPaint", tag, function()
                        local x, y = input.GetCursorPos()
                        cam.Start3D(EyePos(), EyeAngles(), localplayer:GetFOV()*0.5, x*0.5, y*0.5, sizeX, sizeY)
                            if IsValid(selected_ply) then
                                selected_ply:DrawModel()
                            end
                        cam.End3D()
                    end)

                end
            end
        end
    end)

    hook.Add("PlayerButtonUp", tag, function(ply, key)
        if key == MOUSE_LEFT and IsFirstTimePredicted() then
            Stop()
        end
    end)
end)

hook.Add("OnContextMenuClose", tag, function()
    Stop()
end)

local blacklist = {
	"DMenuBar",
	"DMenu",
	"SpawnMenu",
	"ContextMenu",
	"ControlPanel",
	"CGMODMouseInput",
	"Panel",
	['xlib_Panel'] = true,
	['CGMODMouseInput'] = true,
	['atlaschat.chat'] = true,
	['atlaschat.chat.list'] = true,
	['DevHUD'] = true,
}

local lightblacklist = {
	"scoreboard",
	"menu",
	"f1",
	"f2",
	"f3",
	"f4",
	"playx",
	"gcompute",
}

local function VGUICleanup()
	local sum = 0
	for _,pnl in next,vgui.GetWorldPanel():GetChildren() do
		if not IsValid(pnl) then continue end
		local name = pnl:GetName()
		local class = pnl:GetClassName()
		local hit_blacklist = false
		if blacklist[class] then continue end
		if blacklist[name] then continue end
		for _,class in next,lightblacklist do
			if name:lower():match(class:lower()) then
				hit_blacklist = true
				continue
			end
		end
		if hit_blacklist then continue end
		Msg("[vgui] ") print("Removed " .. tostring(pnl))
		pnl:Remove()
		sum = sum + 1
	end
	Msg("[vgui] ") print("Total panels removed: " .. sum)
end

concommand.Add("vgui_cleanup", VGUICleanup)
