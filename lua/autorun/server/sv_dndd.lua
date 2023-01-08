local addonName = "Drag'n'Drop Deletion"

util.AddNetworkString( addonName )

net.Receive(addonName, function( len, admin )
    if admin:IsAdmin() then
        local ply = net.ReadEntity()
        if IsValid( ply ) and ply:Alive() then
            local fx = EffectData()
            fx:SetOrigin( ply:LocalToWorld( ply:OBBCenter() ) )
            fx:SetScale( 5 )
            fx:SetStart( ply:GetPlayerColor() * 255 )
            util.Effect( "balloon_pop", fx, true, true )

            ply:KillSilent()
        end
    end
end)

print( addonName .. " initialised" )