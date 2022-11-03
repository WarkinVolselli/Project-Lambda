AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2022 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/vj_projectlambda/combine/wasteland_scanner.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 50
ENT.HullType = HULL_TINY_CENTERED 
ENT.MovementType = VJ_MOVETYPE_AERIAL -- How does the SNPC move?
ENT.AA_GroundLimit = 200 -- If the NPC's distance from itself to the ground is less than this, it will attempt to move up
ENT.Aerial_FlyingSpeed_Calm = 100 -- The speed it should fly with, when it's wandering, moving slowly, etc. | Basically walking compared to ground SNPCs
ENT.Aerial_FlyingSpeed_Alerted = 300 -- The speed it should fly with, when it's chasing an enemy, moving away quickly, etc. | Basically running compared to ground SNPCs
ENT.TurningUseAllAxis = true -- If set to true, angles will not be restricted to y-axis, it will change all axes (plural axis)
ENT.Aerial_AnimTbl_Calm = {ACT_IDLE} -- Animations it plays when it's wandering around while idle
ENT.Aerial_AnimTbl_Alerted = {ACT_IDLE} -- Animations it plays when it's moving while alerted
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.ConstantlyFaceEnemy = true -- Should it face the enemy constantly?
ENT.IdleAlwaysWander = true -- If set to true, it will make the SNPC always wander when idling
ENT.CanOpenDoors = false -- Can it open doors?
ENT.VJ_NPC_Class = {"CLASS_COMBINE"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Blue" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.HasMeleeAttack = false -- Should the SNPC have a melee attack?

ENT.HasRangeAttack = true -- Should the SNPC have a range attack?
ENT.AnimTbl_RangeAttack = {"vjseq_attack"} -- Range Attack Animations
ENT.RangeAttackEntityToSpawn = "obj_vj_projectlambda_wscanner_grenade" -- The entity that is spawned when range attacking
ENT.RangeAttackAnimationStopMovement = true -- Should it stop moving when performing a range attack?
ENT.RangeDistance = 1500 -- This is how far away it can shoot
ENT.RangeToMeleeDistance = 1 -- How close does it have to be until it uses melee?
ENT.TimeUntilRangeAttackProjectileRelease = 0.1 -- How much time until the projectile code is ran?
ENT.RangeAttackPos_Up = 0 -- Up/Down spawning position for range attack
ENT.RangeAttackPos_Forward = 20 -- Forward/ Backward spawning position for range attack
ENT.RangeAttackPos_Right = -5 -- Right/Left spawning position for range attack
ENT.NextRangeAttackTime = 4 -- How much time until it can use a range attack?
ENT.NextRangeAttackTime_DoRand = 8 -- False = Don't use random time | Number = Picks a random number between the regular timer and this timer

ENT.NoChaseAfterCertainRange = true -- Should the SNPC not be able to chase when it's between number x and y?
ENT.NoChaseAfterCertainRange_FarDistance = "UseRangeDistance" -- How far until it can chase again? | "UseRangeDistance" = Use the number provided by the range attack instead
ENT.NoChaseAfterCertainRange_CloseDistance = "UseRangeDistance" -- How near until it can chase again? | "UseRangeDistance" = Use the number provided by the range attack instead
ENT.NoChaseAfterCertainRange_Type = "Regular" -- "Regular" = Default behavior | "OnlyRange" = Only does it if it's able to range attack

	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.BreathSoundLevel = 65
ENT.SoundTbl_Breath = {"npc/scanner/combat_scan_loop2.wav"}
ENT.SoundTbl_RangeAttack = {"npc/waste_scanner/grenade_fire.wav"}

-- Custom
ENT.Scanner_FollowOffsetPos = 0

Scanner_Leader = NULL
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(15,15,15), Vector(-15,-15,-15))
	self.Scanner_FollowOffsetPos = Vector(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
	if !IsValid(Scanner_Leader) then
		Scanner_Leader = self
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	if self.VJ_IsBeingControlled then return end
	if !IsValid(self:GetEnemy()) then
		if IsValid(Scanner_Leader) then
			if Scanner_Leader != self && Scanner_Leader.AA_CurrentMovePos then
				self.DisableWandering = true
				self:AA_MoveTo(Scanner_Leader, true, "Calm", {AddPos=self.Scanner_FollowOffsetPos, IgnoreGround=true})
			end
		else
			self.IsGuard = false
			self.DisableWandering = false
			Scanner_Leader = self
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackCode_GetShootPos(projectile)
	return self:CalculateProjectile("Curve", self:GetPos() + self:GetForward()*20 + self:GetUp()*20, self:GetEnemy():GetPos() + self:GetEnemy():OBBCenter(), 1500)
end