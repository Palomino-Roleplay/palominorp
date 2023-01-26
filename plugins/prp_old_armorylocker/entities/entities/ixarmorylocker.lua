ENT.Type = "ai"
ENT.PrintName = "Armory Locker"
ENT.Category = "PalominoRP"
ENT.AdminSpawnable = true
ENT.PopulateEntityInfo = true


if SERVER then 
    function ENT:Initialize()
        self:SetModel("models/props/de_nuke/hr_nuke/nuke_locker/nuke_lockers_row.mdl")
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)


        local physObj = self:GetPhysicsObject()

        if (IsValid(physObj)) then
            physObj:EnableMotion(true)
            physObj:Wake()
        end
    end

    function ENT:Use(activator)
        if !activator:IsPlayer() then return end

        if ix.faction.Get(activator:GetCharacter():GetFaction()).equipmentLockerAccess then 
            net.Start("ixArmoryOpen")
            net.WriteEntity(self)
            net.Send(activator)
        end 
    end
else 

    function ENT:OnPopulateEntityInfo(tooltip)
        surface.SetFont("ixIconsSmall")

        local title = tooltip:AddRow("name")
        title:SetImportant()
        title:SetText("Equipment Locker")
        title:SetBackgroundColor(ix.config.Get("color"))
        title:SizeToContents()

        local description = tooltip:AddRow("description")
        description:SetText("An Equipment Locker to retrieve guns from for your job!")
        description:SizeToContents()
    end

end 