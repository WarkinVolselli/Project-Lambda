AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2022 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/

---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetSkin(1)
	self:SetCollisionBounds(Vector(15,15,15), Vector(-15,-15,-15))
	self.Scanner_FollowOffsetPos = Vector(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
	if !IsValid(Scanner_Leader) then
		Scanner_Leader = self
	end
end
