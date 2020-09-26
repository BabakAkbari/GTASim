-- register cam command
RegisterCommand('cam', function()
    is_active = not is_active
    RenderScriptCams(is_active, true, 1, true, true)
end, false) 

-- create a drone, set physics parameters and attach a camera to the drone
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
    SetObjectPhysicsParams(drone, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0,-1.0, -1.0, -1.0, -1.0)
    ActivatePhysics(drone)
    SetEntityHasGravity(drone, true)
    drone_cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    AttachCamToEntity(drone_cam, drone, 0.0, -1.5, 0.5, true)
    SetCamRot(drone_cam, 0.0, 0.0, 0.0, 1)
    SetCamActive(drone_cam, true)
    RenderScriptCams(true, true, 1, true, true)
    is_active = true
    origin = GetEntityCoords(drone)
    return drone
end

-- get current drone
function GetCurrentDrone()
    return current_drone
end

-- set current drone
function SetCurrentDrone(drone)
    current_drone = drone
end

-- diffrentiating velocity to get acceleration
function GetAccelerations(entity)
    local vel_last = GetEntityVelocity(entity)
    local start = GetGameTimer()
    Citizen.Wait(0)
    return (GetEntityVelocity(entity) - vel_last) * 1000/ (GetGameTimer() - start)
end


RegisterNetEvent('PWMOutputs')
AddEventHandler('PWMOutputs', function(mot1, mot2, mot3, mot4)
    print('motor1:', mot1,', motor2:',mot2,', motor3:',mot3,', motor4:',mot4)
end)

-- set motor outputs
RegisterNetEvent('MotorOutputs')
AddEventHandler('MotorOutputs', function(mot1, mot2, mot3, mot4)
    local entity = GetCurrentDrone()
    if entity then  
        local forceType = 0
        local direction = vector3(0.0, 0.0, mot1)
        local rotation = vector3(0.55, 0.55, 0.0)
        local boneIndex = 0
        local isDirectionRel = true
        local ignoreUpVec = true
        local isForceRel = false
        local p12 = false
        local p13 = true
        local yaw_rate = mot1 + mot2 - mot3 - mot4
        local momentum = vector3(0, 0, yaw_rate / 2)
        local center_mass = vector3(0, 0, 0)
        ApplyForceToEntity(
            entity,
            4,
            momentum,
            center_mass,
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

-- process sensors and send data back to server side
function process_sensors()
    if GetCurrentDrone() then
        drone = GetCurrentDrone()
        angular_velocity_vector = GetEntityRotationVelocity(drone) 
        angular_velocity_vector = angular_velocity_vector * 0.0174533
        angular_velocity_vector = {angular_velocity_vector.y, angular_velocity_vector.x, angular_velocity_vector.z}

        acceleration_vector = GetAccelerations(drone)
        acceleration_vector = {acceleration_vector.y, acceleration_vector.x, -acceleration_vector.z - 10}
        
        position_vector = GetEntityCoords(drone)
        position_vector = position_vector - origin
        -- print(position_vector)
        position_vector = {position_vector.y, position_vector.x, -position_vector.z}
        
        attitude_vector = GetEntityRotation(drone)
        -- print(attitude_vector)
        -- SetCamRot(drone_cam, attitude_vector.x, attitude_vector.y, attitude_vector.z, 0)
        SetCamRot(drone_cam, -20.0, 0.0, attitude_vector.z, 0)
        attitude_vector = attitude_vector * 0.0174533
        attitude_vector = {attitude_vector.y, attitude_vector.x, GetEntityHeading(drone) * 0.0174533} 

        velocity_vector = GetEntityVelocity(drone)
        -- print(velocity_vector)
        velocity_vector = {velocity_vector.y, velocity_vector.x, -velocity_vector.z}
        
        TriggerServerEvent('SensorData', angular_velocity_vector, acceleration_vector, position_vector, attitude_vector,
        velocity_vector)
    end
end

-- register drone command
RegisterCommand('drone', function(source)
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(PlayerPedId())
    local drone = CreateDrone(pos)
    SetCurrentDrone(drone)
end, false)

-- create a thread and run sensors
Citizen.CreateThread(function()
    while true do
        process_sensors()
        Citizen.Wait(0)   
    end
end)
