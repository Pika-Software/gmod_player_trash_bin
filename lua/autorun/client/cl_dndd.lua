local addonName = "Drag'n'Drop Deletion"

local binMat = Material( "icon/bin.png" )
local vector_zero = Vector()

local function DoBoxesIntersect( pnl1, pnl2 )
    local p1x, p1y = pnl1:GetPos()
    local p1w, p1h = pnl1:GetSize()
    local p2x, p2y = pnl2:GetPos()
    local p2w, p2h = pnl2:GetSize()
    return (math.abs(p1x - p2x) * 2 < (p1w + p2w)) and (math.abs(p1y - p2y) * 2 < (p1h + p2h))
end

hook.Add("ContextMenuOpened", addonName, function()
    local contextMenu = g_ContextMenu
    if IsValid( contextMenu ) then
        if IsValid( contextMenu[ addonName ] ) then
            contextMenu[ addonName ]:Remove()
            -- return
        end

        local binPanel = vgui.Create( "EditablePanel", contextMenu )
        contextMenu[ addonName ] = binPanel

        function binPanel:PerformLayout( w, h )
            local size = ScreenScale( 50 )
            self:SetSize( size, size )

            local parent = self:GetParent()
            if IsValid( parent ) then
                self:SetPos((parent:GetWide() - size) / 2, parent:GetTall() - size - 15 )
            end
        end

        function binPanel:Paint( w, h )
            surface.SetDrawColor( 255, 255, 255 )
            surface.SetMaterial( binMat )
            surface.DrawTexturedRect( 0, 0, w, h )
        end

        hook.Add("PlayerButtonDown", binPanel, function( mainPanel, lply, key )
            if IsValid( mainPanel.PlayerPanel ) then
                return
            end

            if (key == MOUSE_LEFT) and IsFirstTimePredicted() and mainPanel:IsVisible() then
                local ply = nil
                local viewEntity = lply:GetViewEntity()
                if viewEntity:IsPlayer() or viewEntity:IsNPC() then
                    ply = properties.GetHovered( viewEntity:GetShootPos(), viewEntity:GetAimVector() )
                else
                    ply = properties.GetHovered( viewEntity:EyePos(), viewEntity:EyeAngles():Forward() )
                end

                if IsValid( ply ) and ply:IsPlayer() and ply:Alive() then
                    local playerPanel = vgui.Create( "EditablePanel", contextMenu )
                    mainPanel.PlayerPanel = playerPanel
                    playerPanel.BinPanel = mainPanel
                    playerPanel.Player = ply

                    hook.Add("PlayerButtonUp", playerPanel, function( self, _, key2 )
                        if (key2 == MOUSE_LEFT) and IsFirstTimePredicted() then
                            local pnl = self.BinPanel
                            if IsValid( pnl ) and DoBoxesIntersect( self, pnl ) then
                                net.Start( addonName )
                                    net.WriteEntity( self.Player )
                                net.SendToServer()
                            end

                            self:Remove()
                        end
                    end)

                    hook.Add("PreventScreenClicks", playerPanel, function( pnl )
                        return true
                    end)

                    hook.Add("ContextMenuClosed", playerPanel, function( pnl )
                        gui.EnableScreenClicker( false )
                        pnl:Remove()
                    end)

                    local nickName = vgui.Create( "DLabel", playerPanel )
                    if IsValid( nickName ) then
                        playerPanel.NickName = nickName
                        nickName:Dock( TOP )
                        nickName:SetText( ply:Nick() )
                        nickName:SetContentAlignment( 5 )
                        nickName:SetColor( team.GetColor( ply:Team() ) )
                    end

                    local model = vgui.Create( "DModelPanel", playerPanel )
                    if IsValid( model ) then
                        playerPanel.Model = model
                        model:SetModel( ply:GetModel() )
                        model:Dock( FILL )

                        function model.Entity.GetPlayerColor()
                            if IsValid( ply ) then
                                return ply:GetPlayerColor()
                            end

                            return vector_zero
                        end

                        function model.LayoutEntity()
                        end

                    end

                    function playerPanel:PerformLayout( w, h )
                        local size = ScreenScale( 50 )
                        self:SetSize( size, size )
                        self:SetPos( (ScrW() - size) / 2, ScrH() - size  )
                    end

                    function playerPanel:Think()
                        local x, y = input.GetCursorPos()
                        self:SetPos( x - self:GetWide() / 2, y - self:GetTall() / 2 )
                        if IsValid( self.BinPanel ) and self.BinPanel:IsVisible() then return end
                        self:Remove()
                    end
                end
            end
        end)
    end

end)

hook.Add("GUIMousePressed", addonName, function( key, aimVector )

end)

print( addonName .. " initialised" )

