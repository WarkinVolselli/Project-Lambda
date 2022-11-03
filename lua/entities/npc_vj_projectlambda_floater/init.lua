AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2022 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/vj_projectlambda/xen/floater.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 40
ENT.HullType = HULL_TINY
ENT.MovementType = VJ_MOVETYPE_AERIAL -- How does the SNPC move?
ENT.Aerial_FlyingSpeed_Calm = 100 -- The speed it should fly with, when it's wandering, moving slowly, etc. | Basically walking compared to ground SNPCs
ENT.Aerial_FlyingSpeed_Alerted = 200 -- The speed it should fly with, when it's chasing an enemy, moving away quickly, etc. | Basically running compared to ground SNPCs
ENT.Aerial_AnimTbl_Calm = {ACT_WALK} -- Animations it plays when it's wandering around while idle
ENT.Aerial_AnimTbl_Alerted = {ACT_RUN} -- Animations it plays when it's moving while alerted
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.ConstantlyFaceEnemy = true -- Should it face the enemy constantly
ENT.IdleAlwaysWander = true -- If set to true, it will make the SNPC always wander when idling
ENT.CanOpenDoors = false -- Can it open doors?
ENT.VJ_NPC_Class = {"CLASS_XEN"} -- NPCs with the same class with be allied to each other
ENT.Behavior = VJ_BEHAVIOR_NEUTRAL -- The behavior of the SNPC
ENT.BloodColor = "Yellow" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.HasMeleeAttack = false -- Should the SNPC have a melee attack?

ENT.HasRangeAttack = true -- Should the SNPC have a range attack?
ENT.AnimTbl_RangeAttack = {"vjseq_attack"} -- Range Attack Animations
ENT.RangeAttackEntityToSpawn = "obj_vj_projectlambda_spit" -- The entity that is spawned when range attacking
ENT.RangeDistance = 1000 -- This is how far away it can shoot
ENT.RangeToMeleeDistance = 1 -- How close does it have to be until it uses melee?
ENT.TimeUntilRangeAttackProjectileRelease = false -- How much time until the projectile code is ran?
ENT.RangeAttackPos_Up = 20 -- Up/Down spawning position for range attack
ENT.RangeAttackPos_Forward = 20 -- Forward/ Backward spawning position for range attack
ENT.NextRangeAttackTime = 2 -- How much time until it can use a range attack?
ENT.NextRangeAttackTime_DoRand = 4 -- False = Don't use random time | Number = Picks a random number between the regular timer and this timer

ENT.NoChaseAfterCertainRange = true -- Should the SNPC not be able to chase when it's between number x and y?
ENT.NoChaseAfterCertainRange_FarDistance = "UseRangeDistance" -- How far until it can chase again? | "UseRangeDistance" = Use the number provided by the range attack instead
ENT.NoChaseAfterCertainRange_CloseDistance = "UseRangeDistance" -- How near until it can chase again? | "UseRangeDistance" = Use the number provided by the range attack instead
ENT.NoChaseAfterCertainRange_Type = "Regular" -- "Regular" = Default behavior | "OnlyRange" = Only does it if it's able to range attack
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_Idle = {"vj_projectlambda/floater/idle1.wav","vj_projectlambda/floater/idle2.wav","vj_projectlambda/floater/idle3.wav"}
ENT.SoundTbl_CombatIdle = {"vj_projectlambda/floater/combatidle.wav"}
ENT.SoundTbl_Alert = {"vj_projectlambda/floater/alert1.wav","vj_projectlambda/floater/alert2.wav","vj_projectlambda/floater/alert3.wav"}
ENT.SoundTbl_Pain = {"vj_projectlambda/floater/pain1.wav","vj_projectlambda/floater/pain2.wav","vj_projectlambda/floater/pain3.wav"}
ENT.SoundTbl_Death = {"vj_projectlambda/floater/death.wav"}

-- Custom
ENT.Floater_FollowOffsetPos = 0

Floater_Leader = NULL
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(10,10,50), Vector(-10,-10,0))
	self.Floater_FollowOffsetPos = Vector(math.random(-60, 60), math.random(-60, 60), math.random(-60, 60))
	if !IsValid(Floater_Leader) then
		Floater_Leader = self
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key, activator, caller, data)
	//print(key)
	if key == "shoot" then
		self:RangeAttackCode()
	end 
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	if self.VJ_IsBeingControlled then return end
	if !IsValid(self:GetEnemy()) then
		if IsValid(Floater_Leader) then
			if Floater_Leader != self && Floater_Leader.AA_CurrentMovePos then
				self.DisableWandering = true
				self:AA_MoveTo(Floater_Leader, true, "Calm", {AddPos=self.Floater_FollowOffsetPos, IgnoreGround=true})
			end
		else
			self.IsGuard = false
			self.DisableWandering = false
			Floater_Leader = self
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackCode_GetShootPos(projectile)
	return self:CalculateProjectile("Curve", self:GetPos() + self:GetForward()*20 + self:GetUp()*20, self:GetEnemy():GetPos() + self:GetEnemy():OBBCenter(), 1000)
end