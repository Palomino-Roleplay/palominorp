AddCSLuaFile()

ENT.Type            = "anim"
ENT.Base            = "base_anim"

ENT.PrintName		= "Parking Meter"
ENT.Author			= "sil"
ENT.Category        = "Palomino"
ENT.Purpose			= "Parking vehicles"
ENT.Instructions	= "Use with care. Always handle with gloves."

ENT.Spawnable		= true
ENT.AdminOnly		= true

if SERVER then
	util.AddNetworkString( "PRP.ParkingMeter.DEV_USE")

	net.Receive( "PRP.ParkingMeter.DEV_USE", function( _, pPlayer )
		local eEntity = net.ReadEntity()
		if not IsValid( eEntity ) then return end

		local sVehicleClass = net.ReadString()

		eEntity:SpawnVehicle( pPlayer, sVehicleClass )
	end )

	function ENT:SpawnVehicle( pPlayer, sVehicleClass )
		local eVehicle, sMessage = PRP.Vehicle.Parking.Spawn( self:GetParkingLot(), sVehicleClass )

		if not eVehicle then
			pPlayer:Notify( sMessage )
		else
			pPlayer:Notify( "Vehicle spawned." )
		end
	end
end

AccessorFunc( ENT, "ParkingLot", "ParkingLot" )

function ENT:Initialize()
	-- Sets what model to use
	self:SetModel( self.Model or "models/props_trainstation/clock01.mdl" )

	-- Physics stuff
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	-- Init physics only on server, so it doesn't mess up physgun beam
	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
	end

	-- Make prop to fall on spawn
	self:PhysWake()

	self:SetParkingLot( "main_square" )
end

function ENT:ClientUse( pPlayer )
    PUI.Dialogue.New( self, {
        ["Land Rover"] = {
            OnSelect = function()
                net.Start( "PRP.ParkingMeter.DEV_USE" )
					net.WriteEntity( self )
					net.WriteString( "landrovertdm" )
				net.SendToServer()
            end
        },
        ["Toyota Rav 4"] = {
            OnSelect = function()
                net.Start( "PRP.ParkingMeter.DEV_USE" )
					net.WriteEntity( self )
					net.WriteString( "toyrav4tdm" )
				net.SendToServer()
            end
        },
        ["Volvo XC90"] = {
            OnSelect = function()
                net.Start( "PRP.ParkingMeter.DEV_USE" )
					net.WriteEntity( self )
					net.WriteString( "volxc90tdm" )
				net.SendToServer()
            end
        },
    } )
end