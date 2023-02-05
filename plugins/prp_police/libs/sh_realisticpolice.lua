-- Functions from Realistic Police addon

Realistic_Police = Realistic_Police or {}

Realistic_Police.ManipulateBoneCuffed = {
	["ValveBiped.Bip01_R_UpperArm"] = Angle(-28,18,-21),
	["ValveBiped.Bip01_L_Hand"] = Angle(0,0,119),
	["ValveBiped.Bip01_L_Forearm"] = Angle(22.5,20,40),
	["ValveBiped.Bip01_L_UpperArm"] = Angle(15, 26, 0),
	["ValveBiped.Bip01_R_Forearm"] = Angle(0,47.5,0),
	["ValveBiped.Bip01_R_Hand"] = Angle(45,34,-15),
	["ValveBiped.Bip01_L_Finger01"] = Angle(0,50,0),
	["ValveBiped.Bip01_R_Finger0"] = Angle(10,2,0),
	["ValveBiped.Bip01_R_Finger1"] = Angle(-10,0,0),
	["ValveBiped.Bip01_R_Finger11"] = Angle(0,-40,0),
	["ValveBiped.Bip01_R_Finger12"] = Angle(0,-30,0)
}

Realistic_Police.ManipulateBoneSurrender = {
    ["ValveBiped.Bip01_R_UpperArm"] = Angle(60,33,118),
    ["ValveBiped.Bip01_L_Hand"] = Angle(-8,11,90),
    ["ValveBiped.Bip01_L_Forearm"] = Angle(-25,-23,36),
    ["ValveBiped.Bip01_R_Forearm"] = Angle(-22,1,15),
    ["ValveBiped.Bip01_L_UpperArm"] = Angle(-67,-40,2),
    ["ValveBiped.Bip01_R_Hand"] = Angle(30,42,-45),
    ["ValveBiped.Bip01_L_Finger01"] = Angle(0,30,0),
    ["ValveBiped.Bip01_L_Finger1"] = Angle(0,45,0),
    ["ValveBiped.Bip01_L_Finger11"] = Angle(0,45,0),
    ["ValveBiped.Bip01_L_Finger2"] = Angle(0,45,0),
    ["ValveBiped.Bip01_L_Finger21"] = Angle(0,45,0),
    ["ValveBiped.Bip01_L_Finger3"] = Angle(0,45,0),
    ["ValveBiped.Bip01_L_Finger31"] = Angle(0,45,0),
    ["ValveBiped.Bip01_L_Finger4"] = Angle(0,40,0),
    ["ValveBiped.Bip01_L_Finger41"] = Angle(-10,30,0),
    ["ValveBiped.Bip01_R_Finger0"] = Angle(0,-40,0),
    ["ValveBiped.Bip01_R_Finger11"] = Angle(0,50,20),
    ["ValveBiped.Bip01_R_Finger2"] = Angle(10,30,0),
    ["ValveBiped.Bip01_R_Finger21"] = Angle(0,80,0),
    ["ValveBiped.Bip01_R_Finger22"] = Angle(10,40,0),  
    ["ValveBiped.Bip01_R_Finger3"] = Angle(0,30,0),
    ["ValveBiped.Bip01_R_Finger31"] = Angle(0,80,-0),
    ["ValveBiped.Bip01_R_Finger32"] = Angle(0,80,-0),
    ["ValveBiped.Bip01_R_Finger4"] = Angle(0,40,0),
    ["ValveBiped.Bip01_R_Finger41"] = Angle(0,90,-20),
    ["ValveBiped.Bip01_R_Finger42"] = Angle(0,80,-0),
}


-- Reset position of all bones for surrender and cuffed 
function Realistic_Police.ResetBonePosition(Table, ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    for k, v in pairs(Table) do
        if isnumber(ply:LookupBone(k)) then
            ply:ManipulateBoneAngles(ply:LookupBone(k), Angle(0, 0, 0))
        end
    end
end