AddCSLuaFile( )

ENT.Type 			= "anim"
ENT.Base 			= "base_entity"

ENT.Editable		= true
ENT.PrintName		= "Hard Light Bridge"
ENT.Spawnable 		= true
ENT.AdminSpawnable 	= false
ENT.Category		= "Aperture Science"
ENT.AutomaticFrameAdvance = true 

function ENT:Initialize()

	if SERVER then

		self:SetModel( "models/props/wall_emitter.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
	
		self:GetPhysicsObject():EnableMotion(false)

		
		self.hard_light_bridges_ents = { }
	end // SERVER

	if CLIENT  then
		
	end // CLIENT
	
	self.hard_light_bridge_update = 0
end

function ENT:Draw()

	self:DrawModel()
	
	local _bridge_trace = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:LocalToWorld(Vector(10000, 0, 0)),
		filter = function( ent ) if ( ent == self or ent:GetClass() == "player" or ent:GetClass() == "prop_physics" ) then return false end end
	} )
	
	local bridge_draw_width = 35
	local totalDistance = self:GetPos():Distance(_bridge_trace.HitPos)
	
	local bridge_mat = Material("effects/projected_wall", "nocull")
	local bridge_border_mat = Material("effects/laser1")
	
	if (totalDistance != self.hard_light_bridge_update) then
		self.hard_light_bridge_update = totalDistance
		
		local min, max = self:GetRenderBounds() 
		self:SetRenderBounds(min, max + Vector(totalDistance, 0, 0))
	end
	
	render.SetMaterial(bridge_border_mat)
	render.DrawBeam(self:LocalToWorld(Vector(0, bridge_draw_width, 0)), self:LocalToWorld(Vector(totalDistance, bridge_draw_width, 0)), 40, 0, 1, Color(100, 200, 255) )
	render.DrawBeam(self:LocalToWorld(Vector(0, -bridge_draw_width, 0)), self:LocalToWorld(Vector(totalDistance, -bridge_draw_width, 0)), 40, 0, 1, Color(100, 200, 255) )
	
	render.SetMaterial(bridge_mat)
	render.DrawBox(self:LocalToWorld(Vector(totalDistance / 2, 0, 0)), self:LocalToWorldAngles(Angle(0, 0, 0)), -Vector(totalDistance / 2, bridge_draw_width, 0), Vector(totalDistance / 2, bridge_draw_width, 0), Color(255, 255, 255, 255), true) 
	render.SetColorMaterial()
	render.DrawBox(self:LocalToWorld(Vector(totalDistance / 2, 0, 0)), self:LocalToWorldAngles(Angle(0, 0, 0)), -Vector(totalDistance / 2, bridge_draw_width, 0), Vector(totalDistance / 2, bridge_draw_width, 0), Color(100, 200, 255, 50), true) 

	
end

function ENT:Think()

	//self:NextThink(CurTime() + 1)

	if SERVER then
		
		// const base plate length
		local plate_length = 47.450005
		
		local bridge_trace = util.TraceLine( {
			start = self:GetPos(),
			endpos = self:LocalToWorld(Vector(10000, 0, 0)),
			filter = function( ent ) if ( ent == self or ent:GetClass() == "player" or ent:GetClass() == "prop_physics" ) then return false end end
		} )
		
		local totalDistance = self:GetPos():Distance(bridge_trace.HitPos)
		
		
		if (totalDistance != self.hard_light_bridge_update) then
			self.hard_light_bridge_update = totalDistance
			
			for k, v in pairs(self.hard_light_bridges_ents) do
				if (v:IsValid()) then v:Remove() end
			end

			local plateIndex = math.Min(8, math.ceil(totalDistance / plate_length))
			local addingDist = plate_length * plateIndex / 2
			
			while (totalDistance > 0) do
				
				local ent = ents.Create("prop_physics")
				ent:SetModel("models/hunter/plates/plate1x"..tostring(plateIndex)..".mdl")
				ent:SetPos(self:LocalToWorld(Vector(addingDist, 0, 0)))
				ent:SetAngles(self:LocalToWorldAngles(Angle(0, 90, 0)))
				ent:Spawn()
				ent:SetColor(Color(0, 0, 0, 0))
				ent:SetRenderMode( RENDERMODE_TRANSALPHA )
				ent:DrawShadow(false)
				ent:SetParent(self)

				local physEnt = ent:GetPhysicsObject()
				physEnt:SetMaterial("item")
				physEnt:EnableMotion(false)
				
				table.insert(self.hard_light_bridges_ents, table.Count(self.hard_light_bridges_ents) + 1, ent)

				plateIndex = math.Min(8, math.ceil(totalDistance / plate_length))
				addingDist = addingDist + plate_length * plateIndex
				totalDistance = totalDistance - plate_length * plateIndex
				
			end
		end
		
		
		for k, v in pairs(self.hard_light_bridges_ents) do
			if (v:IsValid()) then
			
			end
		end
		
	end // SERVER

	if CLIENT then
		
	end // CLIENT
end

if SERVER then

	function ENT:OnRemove()
		for k, v in pairs(self.hard_light_bridges_ents) do
			if (v:IsValid()) then v:Remove() end
		end
	end
end