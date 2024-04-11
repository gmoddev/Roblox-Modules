--[[
Author: Not_Lowest
License: GNU AGPLv3
Permissions: You may redistribute as long as credit is given

Desc:Allows restricteive control over lighting service to manage a huge game
]]


return function()
	local Lighting = game:GetService("Lighting")
	
	local Settings = Lighting.Settings
	
	local manager = {}
	manager.__index = manager
	
	local Default = "Menu"
	
	local LightingSets = {
		["Outdoors"] = Settings.Outside;
		["Inside"] = Settings.Inside;
		["Menu"] = Settings.Menu;
	}
	
	function manager.new()
		local Set = {
			CurrentLighting = Default;
			OldLighting = nil;
			Locked = false;
			Busy = false;
			Key = ""
		}
		
		return setmetatable(Set,manager)
	end
	
	local function findi(haystack,needle)
		for i,v in pairs(haystack) do
			if i ~= needle then continue end
			return v
		end
		return nil
	end
	
	local function ChangeLighting(self,desired)
		if self.Busy then return {false, "System is busy"} end
		
		self.Busy = true
		local Search = findi(LightingSets,desired)
		if not Search then
			return {false, "Desired Lighting doesnt exist"}
		end
		
		local CurrentLighting = self.CurrentLighting
		
		local OldLighting = findi(CurrentLighting)
		
		self.OldLighting = CurrentLighting
		self.Lighting = desired
		
		local OldLightingSearch = findi(self.OldLighting)
		
		for i,v in pairs(Search) do
			local LightingSearch = Lighting:FindFirstChildWhichIsA(v.ClassName)
			if LightingSearch then
				LightingSearch:Destroy()
			end
			v:Clone().Parent = Lighting
		end
		return {true, "Success"}
	end
	

	local function CheckKey(self,key)
		local not_allowed = self.Locked
		
		local allowed = not not_allowed
		
		if not_allowed then
			if key == self.Key then allowed = true end
		end
		
		return allowed
	end
	
	function manager:Lock(key)
		if self.Locked then return {false, "Lighting is already locked"} end
		self.Locked = true
		self.Key = key
		return {true,"Success"}
	end
	
	function manager:Unlock(key)
		if not self.Locked then return {false, "Lighting is not locked"} else if key ~= self.Key then return {false, "Key is wrong"} end end
		self.Locked = false
		self.Key = ""
		return {true, "Success"}
	end
	
	function manager:Change(key,desired:string)
		local allowed = CheckKey(self,key)
		if not allowed then return {false, "Lighting is locked and the key is wrong"} end
		return ChangeLighting(self,desired)
	end
	
	function manager:Revert(key)
		if self.OldLighting == nil then return {false, "There have been no changes to lighting"} end
		return ChangeLighting(self,self.OldLighting)
	end
	
	return manager.new()
end
