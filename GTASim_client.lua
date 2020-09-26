-- register vehicle command
-- a list of available vehicle models is documented in https://wiki.gtanet.work/index.php?title=Vehicle_Models 
-- but it may not be complete
RegisterCommand('vehicle', function(source, args)
    -- account for the argument not being passed
    local vehicleName = args[1] or 'adder'

    -- check if the vehicle actually exists
    if not IsModelInCdimage(vehicleName) or not IsModelAVehicle(vehicleName) then
        TriggerEvent('chat:addMessage', {
            args = { 'It might have been a good thing that you tried to spawn a ' .. vehicleName .. '. Who even wants their spawning to actually ^*succeed?' }
        })

        return
    end

    -- load the model
    RequestModel(vehicleName)

    -- wait for the model to load
    while not HasModelLoaded(vehicleName) do
        Wait(500) -- often you'll also see Citizen.Wait
    end

    -- get the player's position
    local playerPed = PlayerPedId() -- get the local player ped
    local pos = GetEntityCoords(playerPed) -- get the position of the local player ped

    -- create the vehicle
    local vehicle = CreateVehicle(vehicleName, pos.x, pos.y, pos.z, GetEntityHeading(playerPed), true, false)

    -- set the player ped into the vehicle's driver seat
    SetPedIntoVehicle(playerPed, vehicle, -1)

    -- give the vehicle back to the game (this'll make the game decide when to despawn the vehicle)
    SetEntityAsNoLongerNeeded(vehicle)

    -- release the model
    SetModelAsNoLongerNeeded(vehicleName)

    -- set the vehicle's plate text
    SetVehicleNumberPlateText(vehicle, "Rover")
    
    -- tell the player
    TriggerEvent('chat:addMessage', {
		args = { 'Woohoo! Enjoy your new ^*' .. vehicleName .. '!' }
	})
end, false)

--register trunk command
RegisterCommand('trunk', function(source)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if vehicle == 0 then
        TriggerEvent('chat:addMessage', {
            args = {'Player is not in a vehicle'}
        })
        return
    end
    if GetVehicleDoorAngleRatio(vehicle, 5) ~= 0 then
        SetVehicleDoorShut(vehicle, 5, false)
        TriggerEvent('chat:addMessage', {
            args = {'Closing the trunk'}
        })
    else
        SetVehicleDoorOpen(vehicle, 5, true, false)
        TriggerEvent('chat:addMessage', {
            args = {'Openning the trunk'}
        })
    end
end, false)

-- register hood command
RegisterCommand('hood', function(source)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if vehicle == 0 then
        TriggerEvent('chat:addMessage', {
            args = {'Player is not in a vehicle'}
        })
        return
    end
    if GetVehicleDoorAngleRatio(vehicle, 4) ~= 0 then
        SetVehicleDoorShut(vehicle, 4, false)
        TriggerEvent('chat:addMessage', {
            args = {'Closing the hood'}
        })
    else
        SetVehicleDoorOpen(vehicle, 4, true, false)
        TriggerEvent('chat:addMessage', {
            args = {'Openning the hood'}
        })
    end
end, false)

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
