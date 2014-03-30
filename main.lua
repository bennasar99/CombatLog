-- Configuration --
CombatTime = 10
AllowMobCombat = true


Time = 0
local seconds = {}
local IsOnCombat = {}

function Initialize( Plugin )

	Plugin:SetName( "CombatLog" )
	Plugin:SetVersion( 0 )

    cPluginManager:AddHook(cPluginManager.HOOK_TAKE_DAMAGE, OnTakeDamage);
    cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_DESTROYED, OnPlayerDestroyed);
    cPluginManager:AddHook(cPluginManager.HOOK_TICK, OnTick);
    cPluginManager:AddHook(cPluginManager.HOOK_KILLING, OnKilling);

	LOG( "Initialized " .. Plugin:GetName() .. " v." .. Plugin:GetVersion() )

	return true

end

function OnTakeDamage(Receiver, TDI)
    if TDI.Attacker == nil then
        return false    
    elseif Receiver:IsPlayer() and TDI.Attacker:IsMob() then
        if AllowMobCombat == true then
            Player = tolua.cast(Receiver,"cPlayer")
            IsOnCombat[Player:GetName()] = true
            seconds[Player:GetName()] = 0
            Player:SendMessageWarning("You're on a combat, don't disconnect")
        end
    elseif Receiver:IsPlayer() and TDI.Attacker:IsPlayer() then
        Player = tolua.cast(Receiver,"cPlayer")
        IsOnCombat[Player:GetName()] = true
        seconds[Player:GetName()] = 0
        Player:SendMessageWarning("You're on a combat, don't disconnect")
    end
end

function OnPlayerDestroyed(Player)
    if IsOnCombat[Player:GetName()] == true then
        IsOnCombat[Player:GetName()] = false
        seconds[Player:GetName()] = 0
        cRoot:Get():BroadcastChat(Player:GetName().." disconnected while being on a combat, buuuhhh, you suck")
        local Items = cItems()
        Player:GetInventory():CopyToItems(Items)
        Player:GetWorld():SpawnItemPickups( Items, Player:GetPosX(), Player:GetPosY(), Player:GetPosZ(), 0, 0, 0 )
        Player:GetInventory():Clear()
        Player:SetCurrentExperience(0)
    end
end

function OnTick(TimeDelta)
    if Time == 20 then
        local EachPlayer = function(Player)
            if IsOnCombat[Player:GetName()] == true then
                if seconds[Player:GetName()] == CombatTime then
                    Player:SendMessage("You are no longer in combat")
                    IsOnCombat[Player:GetName()] = false
                else
                    seconds[Player:GetName()] = seconds[Player:GetName()] + 1
                end
            end
        end
        local EachWorld = function(World)
            World:ForEachPlayer(EachPlayer)
        end
        cRoot:Get():ForEachWorld(EachWorld)
        Time = 0
    else
        Time = Time + 1
    end
end

function OnKilling(Victim, Killer)
    if Victim:IsPlayer() then
        Player = tolua.cast(Victim,"cPlayer")
        IsOnCombat[Player:GetName()] = false
        seconds[Player:GetName()] = 0
    end
end
