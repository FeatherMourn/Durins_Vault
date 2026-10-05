local UEHelpers = require("UEHelpers")

local GetKismetSystemLibrary = UEHelpers.GetKismetSystemLibrary
local GetKismetMathLibrary = UEHelpers.GetKismetMathLibrary
local GetPlayerController = UEHelpers.GetPlayerController

local IsInitialized = false

local function Init()
    if not GetKismetSystemLibrary():IsValid() then error("KismetSystemLibrary not valid\n") end
    if not GetKismetMathLibrary():IsValid() then error("KismetMathLibrary not valid\n") end
    IsInitialized = true
end

Init()

local function GetActorFromHitResult(HitResult)
    if UnrealVersion:IsBelow(5, 0) then
        return HitResult.Actor:Get()
    else
        return HitResult.HitObjectHandle.Actor:Get()
    end
end

local function GetObjectName()
    if not IsInitialized then return end
    local PlayerController = GetPlayerController()
    local PlayerPawn = PlayerController.Pawn
    local CameraManager = PlayerController.PlayerCameraManager
    local StartVector = CameraManager:GetCameraLocation()
    local AddValue = GetKismetMathLibrary():Multiply_VectorInt(
        GetKismetMathLibrary():GetForwardVector(CameraManager:GetCameraRotation()), 50000.0)
    local EndVector = GetKismetMathLibrary():Add_VectorVector(StartVector, AddValue)
    local TraceColor = { ["R"] = 0, ["G"] = 0, ["B"] = 0, ["A"] = 0 }
    local TraceHitColor = TraceColor
    local EDrawDebugTrace_Type_None = 0
    local ETraceTypeQuery_TraceTypeQuery1 = 0
    local ActorsToIgnore = {}
    local HitResult = {}
    local WasHit = GetKismetSystemLibrary():LineTraceSingle(
        PlayerPawn, StartVector, EndVector, ETraceTypeQuery_TraceTypeQuery1,
        false, ActorsToIgnore, EDrawDebugTrace_Type_None, HitResult,
        true, TraceColor, TraceHitColor, 0.0)

    if WasHit then
        local HitActor = GetActorFromHitResult(HitResult)
        print(string.format("[DurinsVaultInspector] Target: %s\n", HitActor:GetFullName()))
        print(string.format("[DurinsVaultInspector] Class: %s\n", HitActor:GetClass():GetFullName()))
    else
        print("[DurinsVaultInspector] Nothing targeted.\n")
    end
end

print("[DurinsVaultInspector] Lua inspector loaded. Press F3 to inspect the targeted actor.\n")
RegisterKeyBind(Key.F3, GetObjectName)
