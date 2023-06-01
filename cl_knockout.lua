QBCore = exports["qb-core"]:GetCoreObject()
local knockedOut = false

local function WakeUp()
    if knockedOut then
        ClearTimecycleModifier()
        lib.hideTextUI()
        knockedOut = false
    end
end

local function KnockedOutLoop(ped)
    SetTimecycleModifier("hud_def_blur")
    lib.showTextUI('You are currently knocked out..', {position = "top-center"})
    CreateThread(function()
        while knockedOut do
            Wait(100)
            local PlayerData = QBCore.Functions.GetPlayerData()
            SetPedToRagdoll(ped, 500, 500, 0, 0, 0, 0)
            ResetPedRagdollTimer(ped)
            if PlayerData.metadata.isdead or PlayerData.metadata.inlaststand then
                WakeUp()
            end
        end
    end)
end

AddEventHandler('gameEventTriggered', function(event, data)
    if event == "CEventNetworkEntityDamage" then
        local ped = data[1]
        if IsPedInMeleeCombat(ped) then
            if HasPedBeenDamagedByWeapon(ped, GetHashKey("WEAPON_UNARMED"), 0) then
                if GetEntityHealth(ped) < Config.Health then
                    if not knockedOut then
                        knockedOut = true
                        KnockedOutLoop(ped)
                        Wait(Config.KnockoutTime * 1000)
                        WakeUp()
                    end
                end
            end
        end
    end
end)