local PLUGIN = PLUGIN

local w,h = ScrW(),ScrH()
local entityFocus

local function scnW(num)
    if !num then return 0 end 
    w = w or ScrW()

    return w*num/1920
end 

local function scnH(num)
    if !num then return 0 end 
    h = h or ScrH()
 
    return h*num/1080
end 

local PANEL = {}

function PANEL:Init()
    local ply = LocalPlayer()
    self:SetDraggable(false)
    self:SetSize(scnW(1400), scnH(900))
    self:Center()
    self:MakePopup()
    self:SetTitle("")
    self.factionLocker = ply:GetCharacter():GetWeaponsArmoryTable()

    self.clickCooldown = 0
    
    surface.SetFont("ixSubTitleFont")
    local textsizeX = surface.GetTextSize("Armory")

    self.Paint = function(frame,wi,he)
        ix.util.DrawBlur(frame, 20, 0.2, 100)
        surface.SetDrawColor(34, 34, 34, 140)
        surface.DrawRect(0, 0, wi, he)    

        surface.SetDrawColor(40, 40, 40, 120) -- top tab
        surface.DrawRect(0, 0, wi, scnH(60))

        surface.SetDrawColor(34, 34, 34, 140)
        surface.DrawRect(scnW(7.5), scnH(65), scnW(315), scnH(830))

        surface.SetTextColor(color_white)
        surface.SetFont("ixSubTitleFont")
        surface.SetTextPos(wi/2 - textsizeX/2, scnH(5))
        surface.DrawText("Armory")

		if !self.setEnt then return end 

        if !IsValid(self.entityFocus) or !ply:Alive() or ply:GetPos():DistToSqr(self.entityFocus:GetPos()) > 12000 then 
            self:Remove()
        end    
    end 

    self.catSelect = self:Add("DScrollPanel")
    self.catSelect:Dock(LEFT)
    self.catSelect:SetWide(scnW(300))
    self.catSelect:DockMargin(scnW(10), scnH(35), 0, 0)

    local categories = {
        [1] = "Primary",
        [2] = "Secondary",

    }


    for k,v in pairs(self.factionLocker) do 
        if !table.HasValue(categories, v.category) then 
            table.insert(categories, v.category)
        end 
    end 

    for _, cat in ipairs(categories) do 
        local selection = self.catSelect:Add("DButton")
        selection:DockMargin(0, scnH(7.5), 0, 0)
        selection:SetTall(scnH(75))
        selection:Dock(TOP)
        selection:SetFont("ixMenuButtonFont")
        selection:SetText(cat) 
        self.CatPanel = self.CatPanel or {}
        self.CatPanel[cat] = selection 

        selection.DoClick = function(this)
            self.scrollPanel:Clear()
            self.populateCategory(cat)
        end 

        selection.PaintOver = function(this, wi, he)
            if self.selectedCat == this then 
                surface.SetDrawColor(34, 34, 34, 160) 
                surface.DrawRect(0, 0, wi, he)    
            end         
        end 
    end 

    self.scrollPanel = self:Add("DScrollPanel")
    self.scrollPanel:DockMargin(scnW(15), scnH(35), scnW(5), 0)
    self.scrollPanel:Dock(FILL)

    self.populateCategory = function(category)
        self.selectedCat = self.CatPanel[category]

        for index, v in pairs(self.factionLocker) do 
            if v.category ~= category then continue end 
            local entTable = (v.entclass and baseclass.Get(v.entclass)) or {}
            local name = v.name or entTable.PrintName 
            local cost = ("$" .. v.cost) or "free"
            
            if v.cost == 0 then 
                cost = "free"
            end 

            local buttonBack = self.scrollPanel:Add("DPanel")
            buttonBack:DockMargin(0, scnH(10), 0, 0)
            buttonBack:Dock(TOP)
            buttonBack:SetTall(scnH(125))
            buttonBack.gunClass = v.entclass or index

            buttonBack.purchaseButton = buttonBack:Add("DButton")
            buttonBack.purchaseButton:SetFont("ixMenuButtonFontSmall")
            buttonBack.purchaseButton:SetText("Purchase")
            buttonBack.purchaseButton:Dock(RIGHT)
            buttonBack.purchaseButton:SetWide(scnW(110))   

            buttonBack.PaintOver = function(this, wi, he)
                surface.SetTextColor(color_white)
                surface.SetFont("ixMenuButtonFont")
                surface.SetTextPos(scnW(210), scnH(5))
                surface.DrawText(name .. " - " .. cost)
                if v.desc then 
                    surface.SetTextColor(color_white)
                    surface.SetFont("ix3D2DSmallFont")
                    surface.SetTextPos(scnW(210), scnH(50))
                    surface.DrawText(v.desc)  
                end      
            end 

            buttonBack.gunModel = buttonBack:Add("DModelPanel")
            buttonBack.gunModel:Dock(LEFT)
            buttonBack.gunModel:SetModel(entTable.WorldModel or v.model)
            buttonBack.gunModel:SetWide(scnW(200))

            buttonBack.gunModel.LayoutEntity = function() end

            local mx, mn = buttonBack.gunModel.Entity:GetRenderBounds()

            buttonBack.gunModel:SetFOV(v.fov or 40)
            buttonBack.gunModel:SetCamPos(v.vec or Vector( 5, 50, 2 ))
            buttonBack.gunModel:SetLookAng(v.ang or Angle( 180, 90, 180 ))
            buttonBack.gunModel.Entity:SetAngles(v.entang or Angle(0, 0, 0))

            
            buttonBack.gunModel.background = buttonBack.gunModel:Add("DPanel")
            buttonBack.gunModel.background:Dock(FILL)


            local onIndex = 0
            local onIndexRow2 = 0 
            self.attachOptions = {}
            local exceedWidth = 0
            if v.entclass and PLUGIN.attachmentTable[v.entclass] then 
                for attachmentCat, attachments in pairs(PLUGIN.attachmentTable[v.entclass]) do 
                    local offset = 0

                    if exceedWidth >= scnW(500) then 
                        offset = scnH(30) 
                        onIndex = onIndexRow2
                    end 

                    self.attachOptions[attachmentCat] = buttonBack:Add("DComboBox")
                    self.attachOptions[attachmentCat]:SetSize(scnW(125), scnH(20))
                    self.attachOptions[attachmentCat]:SetPos(scnW(225) + (onIndex * scnW(175) ), scnH(60) + offset)
                    self.attachOptions[attachmentCat]:SetValue(attachmentCat)
                    
                    exceedWidth = exceedWidth + scnW(125) -- width of dcombobox
                    
                    self.attachOptions[attachmentCat].OnSelect = function(this, _, _, text )
                        this.attachment = text
                    end

                    self.attachOptions[attachmentCat].PaintOver = function(this, wi, he)
                        surface.SetDrawColor(34, 34, 34, 120)
                        surface.DrawRect(0, 0, wi, he)                
                    end 

                    for _, attachment in ipairs(attachments) do
                        if ix.compatAttachments[attachment] then 
                            self.attachOptions[attachmentCat]:AddChoice(PLUGIN.attachPlugin:CapitalizeFirst(string.Replace(PLUGIN.attachPlugin:RemoveAttachmentPrefix(attachment), "_", " " )), attachment)
                        end 
                    end 

                    self.attachOptions[attachmentCat]:AddChoice("None")


                    onIndex = onIndex + 1
                    if offset ~= 0 then 
                        onIndexRow2 = onIndexRow2 + 1
                    end         
                end 
            end 
            
            buttonBack.purchaseButton.DoClick = function(this)
                if CurTime() < self.clickCooldown then return end 
                self.clickCooldown = CurTime() + 1 
                local selections = {}
                for cat, choice in pairs(self.attachOptions) do 
                    if choice.attachment then 
                        selections[cat] = choice.attachment
                    end
                end 

                net.Start("ixArmoryPurchase")
                net.WriteString(this:GetParent().gunClass)
                net.WriteTable(selections)
				net.WriteEntity(self.entityFocus)
                net.SendToServer()

            end
        end 
    end

    self.populateCategory(categories[1]) -- Populate our first category 
end

function PANEL:SetLookEntity(ent) 
	self.entityFocus = ent
	self.setEnt = true
end 

vgui.Register("ixArmoryLocker", PANEL, "DFrame")

net.Receive("ixArmoryOpen", function()
	local frame = vgui.Create("ixArmoryLocker")
	frame:SetLookEntity(net.ReadEntity())
end)