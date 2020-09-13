RegisterCommand('cam', function()
    -- SetCamActive(drone_cam, false)
    -- print(IsCamActive(drone_cam))
    is_active = not is_active
    RenderScriptCams(is_active, true, 1, true, true)
end, false) 


function CreateDrone(where)
    local model = `xs_prop_arena_drone_02`
    RequestModel(model)
    Citizen.CreateThread(function()
        while not HasModelLoaded(model) do
            Citizen.Wait(0)
        end
    end)
    local location = vector3(where.x - 1, where.y - 2, where.z )
    local drone = CreateObject(model, location, true, true, true)
    -- SetObjectPhysicsParams(drone, 1.0, 1.0, -1.0, -1.0, -1.0, 10.0, 10.0, 10.0, -1.0, 1.1, -1.0)
    SetObjectPhysicsParams(drone, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.1, -1.0)
    ActivatePhysics(drone)
    SetEntityHasGravity(drone, true)
    drone_cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    AttachCamToEntity(drone_cam, drone, 0.0, 0.0, 0.5, true)
    SetCamRot(drone_cam, 0.0, 0.0, 0.0, 1)
    SetCamActive(drone_cam, true)
    RenderScriptCams(true, true, 1, true, true)
    is_active = true
    return drone
end

function GetAccelerations(entity)
    -- local _dt = 0.0001
    -- local _dt = 0.1
    local _vel_last = GetEntityVelocity(entity)
    local start = GetGameTimer()
    Citizen.Wait(0)
    -- print(GetGameTimer() - start)
    return (GetEntityVelocity(entity) - _vel_last) * 1000/ (GetGameTimer() - start)
end

function GetCurrentDrone()
    return CurrentDrone
end

function SetCurrentDrone(drone)
    CurrentDrone = drone
end
RegisterNetEvent('pwmOutputs')
AddEventHandler('pwmOutputs', function(mot1, mot2, mot3, mot4)
    -- print(mot1,',',mot2,',',mot3,',',mot4,',')
end)
RegisterNetEvent('MotorOutputs')
AddEventHandler('MotorOutputs', function(mot1, mot2, mot3, mot4)
    -- print((mot1 + mot2 + mot3 + mot4 - 20)/2)
    local entity = GetCurrentDrone()
    if entity then  
        local forceType = 0
        -- sends the entity straight up into the sky:
        local direction = vector3(0.0, 0.0, mot1)
        local rotation = vector3(0.55, 0.55, 0.0)
        local boneIndex = 0
        local isDirectionRel = true
        local ignoreUpVec = true
        local isForceRel = false
        local p12 = false
        local p13 = true
        yaw_rate = mot1 + mot2 - mot3 - mot4
        local momentum = vector3(0, 0, yaw_rate)
        local centre = vector3(0, 0, 0)
        ApplyForceToEntity(
            entity,
            4,
            momentum / 10,
            centre,
            boneIndex,
            isDirectionRel,
            ignoreUpVec,
            isForceRel,
            p12,
            p13
        )
        ApplyForceToEntity(
            entity,
            forceType,
            direction,
            rotation,
            boneIndex,
            isDirectionRel,
            ignoreUpVec,
            isForceRel,
            p12,
            p13
        )
        direction = vector3(0.0, 0.0, mot2)
        rotation = vector3(-0.55, -0.55, 0.0)
        ApplyForceToEntity(
            entity,
            forceType,
            direction,
            rotation,
            boneIndex,
            isDirectionRel,
            ignoreUpVec,
            isForceRel,
            p12,
            p13
        )
        direction = vector3(0.0, 0.0, mot3)
        rotation = vector3(-0.55, 0.55, 0.0)
        ApplyForceToEntity(
            entity,
            forceType,
            direction,
            rotation,
            boneIndex,
            isDirectionRel,
            ignoreUpVec,
            isForceRel,
            p12,
            p13
        )
        direction = vector3(0.0, 0.0, mot4)
        rotation = vector3(0.55, -0.55, 0.0)
        ApplyForceToEntity(
            entity,
            forceType,
            direction,
            rotation,
            boneIndex,
            isDirectionRel,
            ignoreUpVec,
            isForceRel,
            p12,
            p13
        )
    end
end)

function ProcessSensors()
    if GetCurrentDrone() then
        drone = GetCurrentDrone()
        angular_velocity_vector = GetEntityRotationVelocity(drone) 
        angular_velocity_vector = angular_velocity_vector * 0.0174533
        -- print(GetEntityHeightAboveGround(drone) + math.random()/10)
        angular_velocity_vector = {angular_velocity_vector.x, angular_velocity_vector.y, angular_velocity_vector.z}

        acceleration_vector = GetAccelerations(drone)
        -- acceleration_vector = vector3(acceleration_vector.x, acceleration_vector.y, acceleration_vector.z)
        -- Wait(10) 
        -- print("accel:",-acceleration_vector.z)
        acceleration_vector = {acceleration_vector.x, acceleration_vector.y, -acceleration_vector.z - 10}
        
        position_vector = GetEntityCoords(drone)
        -- print(position_vector)
        position_vector = position_vector
        position_vector = {position_vector.x, position_vector.y, -GetEntityHeightAboveGround(drone)}
        
        -- print(GetEntityHeightAboveGround(drone))
        
        attitude_vector = GetEntityRotation(drone)
        -- print(attitude_vector)
        -- local roll = 0
        -- local pitch = 0 
        -- if attitude_vector.x < 0 then 
        --     roll = (attitude_vector.x + 360) * 0.0174533  
        -- else 
        --     roll = attitude_vector.x * 0.0174533 
        -- end
        -- if attitude_vector.y < 0 then 
        --     pitch = (attitude_vector.y + 360) * 0.0174533  
        -- else 
        --     pitch = attitude_vector.y * 0.0174533 
        -- end
        SetCamRot(drone_cam, attitude_vector.x, attitude_vector.y, attitude_vector.z, 1)
        attitude_vector = {attitude_vector.y * 0.0174533 , attitude_vector.x * 0.0174533, GetEntityHeading(drone) * 0.0174533} 

       
        print(GetEntityRotation(drone))
        
        velocity_vector = GetEntityVelocity(drone)
        velocity_vector = velocity_vector
        velocity_vector = {velocity_vector.x, velocity_vector.y, -velocity_vector.z}
        
        TriggerServerEvent('SensorData', angular_velocity_vector, acceleration_vector, position_vector, attitude_vector,
        velocity_vector)
    end
end

RegisterCommand('drone', function(source)
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(PlayerPedId())
    local drone = CreateDrone(pos)
    -- SetEntityHeading(drone, 40.0)
    SetCurrentDrone(drone)
    -- TriggerServerEvent('Connect')
end, false)

Citizen.CreateThread(function()
    math.randomseed(GetGameTimer())
    while true do
        -- SetWeatherTypePersist("EXTRASUNNY")
        -- SetWeatherTypeNowPersist("EXTRASUNNY")
    	-- SetWeatherTypeNow("EXTRASUNNY")
    	-- SetOverrideWeather("EXTRASUNNY")
        ProcessSensors()
        -- TriggerEvent('MotorOutputs', 0, 0, 0, 0)
        local entity = GetCurrentDrone()
        -- if entity then
        --     local forceType = 0
        --     -- sends the entity straight up into the sky:
        --     -- local direction = vector3(0.0, 0.0, mot1)
        --     local mass = vector3(0.0, 0.0, -4.9)
        --     local rotation = vector3(0.55, 0.55, 0.0)
        --     local boneIndex = 0
        --     local isDirectionRel = false
        --     local ignoreUpVec = true
        --     local isForceRel = false
        --     local p12 = false
        --     local p13 = true
        --     ApplyForceToEntity(
        --         entity,
        --         forceType,
        --         mass,
        --         rotation,
        --         boneIndex,
        --         isDirectionRel,
        --         ignoreUpVec,
        --         isForceRel,
        --         p12,
        --         p13
        --     )
        --     -- direction = vector3(0.0, 0.0, mot2)
        --     rotation = vector3(-0.55, -0.55, 0.0)
        --     ApplyForceToEntity(
        --         entity,
        --         forceType,
        --         mass,
        --         rotation,
        --         boneIndex,
        --         isDirectionRel,
        --         ignoreUpVec,
        --         isForceRel,
        --         p12,
        --         p13
        --     )
        --     -- direction = vector3(0.0, 0.0, mot3)
        --     rotation = vector3(-0.55, 0.55, 0.0)
        --     ApplyForceToEntity(
        --         entity,
        --         forceType,
        --         mass,
        --         rotation,
        --         boneIndex,
        --         isDirectionRel,
        --         ignoreUpVec,
        --         isForceRel,
        --         p12,
        --         p13
        --     )
        --     -- direction = vector3(0.0, 0.0, mot4)
        --     rotation = vector3(0.55, -0.55, 0.0)
        --     ApplyForceToEntity(
        --         entity,
        --         forceType,
        --         mass,
        --         rotation,
        --         boneIndex,
        --         isDirectionRel,
        --         ignoreUpVec,
        --         isForceRel,
        --         p12,
        --         p13
        --     )
        -- end
        Citizen.Wait(0)   
    end
end)

-- Citizen.CreateThread(function()
--     local entity = GetCurrentDrone()
--     while entity do
--         accel = GetAccelerations(entity)
--     end
-- end)