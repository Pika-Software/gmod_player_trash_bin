resource.AddSingleFile("materials/xyi/bin.png")
util.AddNetworkString("PlayerInBin")

net.Receive("PlayerInBin", function(len, ply)
    if IsValid(ply) and ply:IsSuperAdmin() then
        ply = net.ReadEntity()
        if IsValid(ply) and ply:Alive() then
            -- ply:Kill()
            ply:KillSilent()
        end
    end
end)