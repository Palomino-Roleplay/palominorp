local PLUGIN = PLUGIN 

util.AddNetworkString("ixArmoryPurchase")
util.AddNetworkString("ixArmoryOpen")

function PLUGIN:GiveAmmo(ply)
    local isMax = false
    for k,v in pairs(ply:GetWeapons()) do 
        if !v.ixIsPoliceWeapon then continue end 

        local ammoType = v:GetPrimaryAmmoType()
        if ply:GetAmmoCount(ammoType) < (v.ammoCap or 60) then 
            ply:SetAmmo(v.ammoCap or 60, ammoType) 
            isMax = true       
        end 
    end

    if isMax then 
        ply:EmitSound("items/ammo_pickup.wav")
    else 
        ply:Notify("You are full on ammo!")
    end 
end

function PLUGIN:GiveArmor(ply)
    if ply:ixHasKevlarHelmet() and ply.policeKevlar then 
        ply:Notify("You already have kevlar and helmet!")
        return
    end 

    ply:ixSetKevlarHelmet(true)
    ply.policeKevlar = true 
    ply:EmitSound("items/ammo_pickup.wav")
end  

function PLUGIN:PurchaseWeapon(ply, weaponClass, attachments, locker)
    local character = ply:GetCharacter()

    ply.armoryUseDelay = ply.armoryUseDelay or 0

    if CurTime() < ply.armoryUseDelay then return end 
    ply.armoryUseDelay = CurTime() + 1 

    if !IsValid(locker) or !ply:Alive() or ply:GetPos():DistToSqr(locker:GetPos()) > 12000 or !ix.faction.Get(character:GetFaction()).equipmentLockerAccess then 
        ply:Notify("You must move closer to the armory!")
        return 
    end 

    local factionLocker = character:GetWeaponsArmoryTable()
        
    if factionLocker[weaponClass] and factionLocker[weaponClass].buyFunc then 
        local metaTab = factionLocker[weaponClass]

        metaTab.buyFunc(ply)
        return
    end 
        
    if !PLUGIN.weaponItems[weaponClass] then
        ply:Notify(PLUGIN.errorm)
        return 
    end 

    local found = false 

    local weaponsTab = {}

    for k,v in pairs(factionLocker) do 
        if v.entclass == weaponClass then 
            weaponsTab = v
            found = true 
            break
        end 
    end 

    if weaponsTab.cost and weaponsTab.cost ~= 0 then 
        if character:HasMoney(weaponsTab.cost) then 
            character:TakeMoney(weaponsTab.cost)
        else 
            ply:Notify("Insufficient cash!")
        end 
    end 

    if !found then 
        ply:Notify(PLUGIN.errorm)
        return
    end 

    if PLUGIN.attachmentTable[weaponClass] then 
        for cat, attachment in pairs(attachments) do
            local foundValue = false
            for _, v in pairs(PLUGIN.attachmentTable[weaponClass][cat]) do 
                if v == attachment then 
                    foundValue = true 
                end 
            end
            if !foundValue then 
                ply:Notify(PLUGIN.errorm)
                return 
            end
        end 
    end

    ply:StripWeapon(weaponClass)

    local wepCategory = weaponsTab.category

    for k,v in pairs(ply:GetWeapons()) do 
        if v.loadoutType == wepCategory then 
            ply:StripWeapon(v:GetClass())
        end 
    end 

    local activeWep = ply:Give(weaponClass)
    activeWep.loadoutType = wepCategory
    activeWep.ammoCap = weaponsTab.ammoCap
    activeWep.ixIsPoliceWeapon = true 

    timer.Simple(0.1, function()
        for k,v in pairs(attachments) do 
            local found, row, column = PLUGIN.attachPlugin:FindAttachment(ply, v, activeWep)

            if !found then

                ply:Notify("An error has occurred while attaching " .. v)
            else 
                activeWep:_attach(row, column)
            end       
        end 
    end)

    ply:SelectWeapon(weaponClass)   
    ply:EmitSound("items/ammo_pickup.wav")
end

net.Receive("ixArmoryPurchase", function(len, ply) PLUGIN:PurchaseWeapon(ply, net.ReadString(), net.ReadTable(), net.ReadEntity()) end)

function PLUGIN:PlayerDeath(ply)
    if ply.policeKevlar then 
        ply:ixSetKevlarHelmet(false)
    end 
end

function PLUGIN:PlayerChangedTeam(ply)
    if ply.policeKevlar then 
        ply:ixSetKevlarHelmet(false)
    end 
end