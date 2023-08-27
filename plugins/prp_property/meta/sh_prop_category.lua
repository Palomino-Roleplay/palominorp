local PLUGIN = PLUGIN

PRP.Prop = PRP.Prop or {}
PRP.Prop.Category = PRP.Prop.Category or {}
PRP.Prop.Categories = PRP.Prop.Categories or {}

function PRP.Prop.Category.New(sID, sName, sIcon, tModels)
    local oCategory = setmetatable( {}, { __index = PRP.Prop.Category.Metatable } )

    oCategory:SetID( sID )
    oCategory:SetName( sName )
    oCategory:SetIcon( sIcon or "icon16/brick.png" )

    PRP.Prop.Categories[sID] = oCategory

    return oCategory
end

local CATEGORY = {}

AccessorFunc(CATEGORY, "m_iID", "ID", FORCE_STRING)
AccessorFunc(CATEGORY, "m_sName", "Name", FORCE_STRING)
AccessorFunc(CATEGORY, "m_sIcon", "Icon", FORCE_STRING)
AccessorFunc(CATEGORY, "m_tModels", "Models")
AccessorFunc(CATEGORY, "m_tChildren", "Children")

AccessorFunc(CATEGORY, "m_oParent", "Parent")

function CATEGORY:AddModel(sModelPath, tConfig)
    self.m_tModels = self.m_tModels or {}
    local iIndex = table.insert(self.m_tModels, {mdl = sModelPath, cfg = tConfig or {}})

    self.m_tModelsHash = self.m_tModelsHash or {}
    self.m_tModelsHash[sModelPath] = self.m_tModels[iIndex]
end

function CATEGORY:GetModel(sModelPath)
    return self.m_tModelsHash[sModelPath]
end

function CATEGORY:HasModel(sModelPath)
    return self.m_tModelsHash[sModelPath] ~= nil
end

function CATEGORY:NewChild(sID, sName, sIcon, tModels)
    local oCategory = PRP.Prop.Category.New(sID, sName, sIcon, tModels)

    self:AddChild(oCategory)

    return oCategory
end

function CATEGORY:AddChild(oCategory)
    self.m_tChildren = self.m_tChildren or {}

    oCategory:SetParent(self)

    local iIndex = table.insert(self.m_tChildren, oCategory)

    self.m_tChildrenHash = self.m_tChildrenHash or {}
    self.m_tChildrenHash[oCategory:GetID()] = self.m_tChildren[iIndex]
end

function CATEGORY:FindPath(sCategoryPath)
    if sCategoryPath == nil then return nil end
    if sCategoryPath == "" then return nil end

    if sCategoryPath == self:GetID() then return self end

    local tPath = string.Explode("/", sCategoryPath)

    if #tPath == 0 then return nil end

    local sNextCategoryID = tPath[1]

    if self.m_tChildrenHash == nil then return nil end
    if not self.m_tChildrenHash[sNextCategoryID] then return nil end
    return self.m_tChildrenHash[sNextCategoryID]:FindPath(table.concat(tPath, "/", 2))
end

PRP.Prop.Category.Metatable = CATEGORY