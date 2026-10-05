local UEHelpers = require("UEHelpers")

local GetKismetSystemLibrary = UEHelpers.GetKismetSystemLibrary
local GetKismetMathLibrary = UEHelpers.GetKismetMathLibrary
local GetPlayerController = UEHelpers.GetPlayerController

local function actor_from_hit(hit)
    if UnrealVersion:IsBelow(5, 0) then
        return hit.Actor:Get()
    end
    return hit.HitObjectHandle.Actor:Get()
end

local function inspect_target()
    local controller = GetPlayerController()
    if not controller:IsValid() or not controller.Pawn:IsValid() then
        print("[DurinsVaultInspector] Player controller/pawn unavailable.\n")
        return
    end

    local camera = controller.PlayerCameraManager
    local start = camera:GetCameraLocation()
    local forward = GetKismetMathLibrary():GetForwardVector(camera:GetCameraRotation())
    local end_point = GetKismetMathLibrary():Add_VectorVector(
        start,
        GetKismetMathLibrary():Multiply_VectorInt(forward, 50000.0)
    )

    local hit = {}
    local color = { R = 0, G = 255, B = 0, A = 255 }
    local was_hit = GetKismetSystemLibrary():LineTraceSingle(
        controller.Pawn, start, end_point, 0, false, {}, 0, hit, true,
        color, color, 0.0
    )

    if not was_hit then
        print("[DurinsVaultInspector] Nothing targeted.\n")
        return
    end

    local actor = actor_from_hit(hit)
    if actor and actor:IsValid() then
        print(string.format("[DurinsVaultInspector] Target: %s\n", actor:GetFullName()))
        print(string.format("[DurinsVaultInspector] Class: %s\n", actor:GetClass():GetFullName()))
    end
end

print("[DurinsVaultInspector] Lua inspector loaded. Press F3 to inspect the targeted actor.\n")
RegisterKeyBind(Key.F3, inspect_target)
