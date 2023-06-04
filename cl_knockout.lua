local knockedOut = false

local function KOText(message)
    SetTextFont(4)
    SetTextScale(0.5, 0.9)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandDisplayText(0.5, 0.8)
end

local function WakeUp(ped)
    if knockedOut then
        ClearTimecycleModifier()
        knockedOut = false
        SetEntityInvincible(ped, false)
    end
end

local function KnockedOutLoop(ped)
    SetTimecycleModifier("hud_def_blur")
    CreateThread(function()
        while knockedOut do
            Wait(0)
            KOText(Config.Message)
            SetPedToRagdoll(ped, 500, 500, 0, 0, 0, 0)
            if IsEntityDead(ped) then
                WakeUp(ped)
            end
        end
    end)
end

AddEventHandler('gameEventTriggered', function(event, data)
    if event == "CEventNetworkEntityDamage" then
        local victim = NetworkGetPlayerIndexFromPed(data[1])
        if victim == PlayerId() then
            ped = PlayerPedId()
            if IsPedInMeleeCombat(ped) then
                if HasPedBeenDamagedByWeapon(ped, GetHashKey("WEAPON_UNARMED"), 0) then
                    if GetEntityHealth(ped) < Config.Health then
                        if not knockedOut then
                            knockedOut = true
                            SetEntityInvincible(ped, true)
                            KnockedOutLoop(ped)
                            Wait(Config.KnockoutTime * 1000)
                            WakeUp(ped)
                        end
                    end
                end
            end
        end
    end
end)
