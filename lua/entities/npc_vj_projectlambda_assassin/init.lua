AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2017 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/vj_projectlambda/combine/assassin.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 80
ENT.HullType = HULL_HUMAN

ENT.Hide = false
ENT.NextHide = 0

ENT.MaxJumpLegalDistance = VJ_Set(800, 1000) -- The max distance the NPC can jump (Usually from one node to another) | ( UP, DOWN )
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_COMBINE"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Yellow" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.AnimTbl_IdleStand = {ACT_IDLE} -- The idle animation when AI is enabled
ENT.AnimTbl_Walk = {ACT_WALK} -- Set the walking animations | Put multiple to let the base pick a random animation when it moves
ENT.AnimTbl_Run = {ACT_RUN} -- Set the running animations | Put multiple to let the base pick a random animation when it moves

ENT.DisableFootStepSoundTimer = true
ENT.FootStepTimeRun = 1 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 1 -- Next foot step sound when it is walking
ENT.HasExtraMeleeAttackSounds = false -- Set to true to use the extra melee attack sounds
ENT.GeneralSoundPitch1 = 100
ENT.GeneralSoundPitch2 = 90

ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.TimeUntilMeleeAttackDamage = false -- This counted in seconds | This calculates the time until it hits something
ENT.MeleeAttackDistance = 80 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 100 -- How far does the damage go?
ENT.MeleeAttackDamage = 20
ENT.MeleeAttackDamageType = DMG_SLASH -- Type of Damage
ENT.AnimTbl_MeleeAttack = {"vjges_stab"} -- Melee Attack Animations
ENT.MeleeAttackAnimationAllowOtherTasks = true -- If set to true, the animation will not stop other tasks from playing, such as chasing | Useful for gesture attacks!

ENT.HasRangeAttack = false -- Should the SNPC have a range attack?
ENT.TimeUntilRangeAttackProjectileRelease = false -- How much time until the projectile code is ran?
ENT.RangeAttackEntityToSpawn = "sent_cb_hopwire" -- The entity that is spawned when range attacking
ENT.AnimTbl_RangeAttack = {"vjges_tripwire"} -- Range Attack Animations
ENT.NextRangeAttackTime = 4 -- How much time until it can use a range attack?
ENT.RangeDistance = 2000 -- This is how far away it can shoot
ENT.RangeToMeleeDistance = 300 -- How close does it have to be until it uses melee?
ENT.RangeUseAttachmentForPos = true -- Should the projectile spawn on a attachment?
ENT.RangeUseAttachmentForPosID = "r_hand" -- The attachment used on the range attack if RangeUseAttachmentForPos is set to true
ENT.RangeAttackAnimationStopMovement = false -- Should it stop moving when performing a range attack?

ENT.NoChaseAfterCertainRange = true -- Should the SNPC not be able to chase when it's between number x and y?
ENT.NoChaseAfterCertainRange_FarDistance = 2000 -- How far until it can chase again? | "UseRangeDistance" = Use the number provided by the range attack instead
ENT.NoChaseAfterCertainRange_CloseDistance = 300 -- How near until it can chase again? | "UseRangeDistance" = Use the number provided by the range attack instead
ENT.NoChaseAfterCertainRange_Type = "OnlyRange" -- "Regular" = Default behavior | "OnlyRange" = Only does it if it's able to range attack

	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {"npc/vort/vort_foot1.wav","npc/vort/vort_foot2.wav","npc/vort/vort_foot3.wav","npc/vort/vort_foot4.wav"}
ENT.SoundTbl_Alert = {"vj_projectlambda/assassin/alert1.wav","vj_projectlambda/assassin/alert2.wav","vj_projectlambda/assassin/alert3.wav"}
ENT.SoundTbl_BeforeMeleeAttack = {"vj_projectlambda/assassin/attack1.wav","vj_projectlambda/assassin/attack2.wav","vj_projectlambda/assassin/attack3.wav"}
ENT.SoundTbl_Pain = {"vj_projectlambda/assassin/pain1.wav","vj_projectlambda/assassin/pain2.wav","vj_projectlambda/assassin/pain3.wav"}
ENT.SoundTbl_Death = {"vj_projectlambda/assassin/death1.wav","vj_projectlambda/assassin/death2.wav","vj_projectlambda/assassin/death3.wav"}
ENT.SoundTbl_MeleeAttack = {"npc/zombie/claw_strike1.wav","npc/zombie/claw_strike2.wav","npc/zombie/claw_strike3.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"npc/zombie/claw_miss1.wav","npc/zombie/claw_miss2.wav"}

ENT.FootStepPitch = VJ_Set(130, 140)
ENT.FootStepSoundLevel = 65

---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key,activator,caller,data)
	if key == "step" then
		self:FootStepSoundCode()
	end
	if key == "melee" then
		self:MeleeAttackCode()
	end
	if key == "range" then
		self:RangeAttackCode()
    end	
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnFootStepSound()
	if !self:IsOnGround() then return end
	local tr = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() +Vector(0,0,-150),
		filter = {self}
	})
	if self:WaterLevel() > 0 && self:WaterLevel() < 3 then
		VJ_EmitSound(self,"player/footsteps/wade" .. math.random(1,8) .. ".wav",self.FootStepSoundLevel,self:VJ_DecideSoundPitch(self.FootStepPitch1,self.FootStepPitch2))
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()

self.NextHide = CurTime() + math.random(0,4)

self:SetRenderMode(RENDERMODE_TRANSCOLOR)	

    self.Eye1 = ents.Create( "env_sprite" )
    self.Eye2 = ents.Create( "env_sprite" ) 
    local eyes = {
        {
            ent = self.Eye1,
            attachment = 3,
        },
        {
            ent = self.Eye2,
            attachment = 4,
        },
    }

	for _,eye_data in pairs(eyes) do
        local eye = eye_data.ent
        eye:SetKeyValue("model","vj_base/sprites/vj_glow1.vmt")
        eye:SetKeyValue( "rendercolor","0 255 0" )
        eye:SetPos( self:GetAttachment(eye_data.attachment).Pos )
        eye:SetParent( self, eye_data.attachment )
        eye:SetKeyValue( "scale","0.05" )
        eye:SetKeyValue( "rendermode","7" )
        eye:Spawn()
        self:DeleteOnRemove(eye)
    end
           
	self.Eye1_Trail = util.SpriteTrail(self.Eye1, 0, Color(0,255,0), true, 5, 10, 0.5, 0.1, "trails/laser")
    self.Eye2_Trail = util.SpriteTrail(self.Eye2, 0, Color(0,255,0), true, 5, 10, 0.5, 0.1, "trails/laser")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDeath_BeforeCorpseSpawned(dmginfo,hitgroup,GetCorpse)
	self:SetSkin(1)
    self.Hide = false
	self:DrawShadow(true)
	self.VJ_NoTarget = false
	self:SetColor(Color( 255, 255, 255, 255 ))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackCode_GetShootPos(projectile)
    return self:CalculateProjectile("Curve", self:GetAttachment(self:LookupAttachment(self.RangeUseAttachmentForPosID)).Pos, self:GetEnemy():GetPos() + self:GetEnemy():OBBCenter(), 2000)
end	
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
    if IsValid(self:GetEnemy()) && math.random(1,50) == 1 && self.Hide == false && self.VJ_IsBeingControlled == false && CurTime() > self.NextHide then
		        self.Hide = true 
				self:SetColor(Color( 0, 0, 0, 25 ))
				VJ_EmitSound(self, "vj_projectlambda/assassin/cloak1.wav", 80, 100)
			    self:DrawShadow(false)
			    self.VJ_NoTarget = true
				self.HasRangeAttack = true
				self.NoChaseAfterCertainRange = true  
		   timer.Simple(6,function() if IsValid(self) then
		   self.NoChaseAfterCertainRange_CloseDistance = 999999
    end 
	end)
		   timer.Simple(10,function() if IsValid(self) then
		   		self.NoChaseAfterCertainRange = false
				self.NoChaseAfterCertainRange_CloseDistance = 300
				self.HasRangeAttack = false	 
		        self.VJ_NoTarget = false
		        self.Hide = false
				VJ_EmitSound(self, "vj_projectlambda/assassin/uncloak1.wav", 80, 100)
			    self:VJ_ACT_PLAYACTIVITY("vjseq_inspectalert",true,VJ_GetSequenceDuration(self,tbl),false)
		        self:DrawShadow(true)
				self:SetColor(Color( 255, 255, 255, 255 ))
		   	    self.NextHide = CurTime() + math.random(8,16)
    end 
	end)
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2017 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/