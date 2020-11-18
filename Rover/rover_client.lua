-- register rover command
-- a list of available vehicle models is documented in https://wiki.gtanet.work/index.php?title=Vehicle_Models 
-- but it may not be complete
RegisterCommand('rover', function(source, args)
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
    ReviveInjuredPed(playerPed)
    SetEntityHealth(playerPed, 200)

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

-- set motor outputs
thread_counter_pedal = 0 
RegisterNetEvent('Rover:MotorOutputs')
AddEventHandler('Rover:MotorOutputs', function(throttle, steer)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    thread_counter_pedal = thread_counter_pedal + 1
    local thread_id = thread_counter_pedal
    while GetVehiclePedIsIn(playerPed, false) ~= 0 and thread_id == thread_counter_pedal do
        -- local speedms = GetEntitySpeed(GetVehiclePedIsIn(playerPed, false))
        -- print("speed:", speedms)
        -- print("value:", value)
        -- print("thread_counter", thread_counter_pedal)
        -- print("control", SetControlNormal(27, 71, throttle / 1000 - 1))
        if throttle >= 1500 then
            SetControlNormal(27, 71, throttle / 500 - 3)
        else
            SetControlNormal(27, 72, throttle / 500 - 2)
        end
            SetControlNormal(27, 59, 0.002 * steer - 3)
        -- SetControlNormal(27, 59, -1.0)
        -- SetVehicleSteeringAngle(vehicle, 0.002 * steer - 270)
        Citizen.Wait(0)
    end
end)

-- process sensors and send data back to server side
function rover_process_sensors()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if vehicle ~=0 then
        angular_velocity_vector = GetEntityRotationVelocity(vehicle) 
        angular_velocity_vector = angular_velocity_vector * 0.0174533
        angular_velocity_vector = {angular_velocity_vector.y, angular_velocity_vector.x, angular_velocity_vector.z}

        acceleration_vector = GetAccelerations(vehicle)
        acceleration_vector = {acceleration_vector.y, acceleration_vector.x, -acceleration_vector.z - 10}
        
        position_vector = GetEntityCoords(vehicle)
        -- print(position_vector)
        position_vector = {position_vector.y, position_vector.x, -position_vector.z}
        
        attitude_vector = GetEntityRotation(vehicle)
        -- print(attitude_vector)
        -- SetCamRot(drone_cam, attitude_vector.x, attitude_vector.y, attitude_vector.z, 0)
        -- SetCamRot(drone_cam, -20.0, 0.0, attitude_vector.z, 0)
        attitude_vector = attitude_vector * 0.0174533
        attitude_vector = {attitude_vector.y, attitude_vector.x, GetEntityHeading(drone) * 0.0174533} 

        velocity_vector = GetEntityVelocity(vehicle)
        -- print(velocity_vector)
        velocity_vector = {velocity_vector.y, velocity_vector.x, -velocity_vector.z}
        
        TriggerServerEvent('SensorData', angular_velocity_vector, acceleration_vector, position_vector, attitude_vector,
        velocity_vector)
    end
end

thread_counter_speed = 0
RegisterCommand('speed', function(source, args)
    local value = tonumber(args[1]) / 3.6
    local _kp = 15 / value
    local _kd = 0.01 / value
    -- local _ki = 85 / value
    local _ki = 95 / value
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    thread_counter_speed = thread_counter_speed + 1
    local thread_id = thread_counter_speed
    local _error_last = 0
    local _error = 0
    local _integrator = 0
    local _dt = 0.001
    local throttle
    while GetVehiclePedIsIn(playerPed, false) ~= 0 and thread_id == thread_counter_speed do
        throttle = _kp * _error + _kd * (_error - _error_last) / _dt + _ki * _integrator
        if throttle > 1.0 then
            throttle = 1.0
        end
        SetControlNormal(27, 71, throttle)
        -- print("speed:", GetEntitySpeed(vehicle))
        if GetEntitySpeed(vehicle) - value > 4.0 then
            SetVehicleBrake(vehicle, true)
        end
        _error_last = value - GetEntitySpeed(vehicle)
        Citizen.Wait(_dt * 1000)
        _error = value - GetEntitySpeed(vehicle)
        _integrator = _integrator + _error * _dt
        print("integrator:", _integrator)
        if _integrator > 0.2 then
            _integrator = 0.0
        elseif _integrator < -0.1 then
            _integrator = 0.0
        end
    end
end, false)

function RotationToDirection(rotation)
	local adjustedRotation = 
	{ 
		x = (math.pi / 180) * rotation.x, 
		y = (math.pi / 180) * rotation.y, 
		z = (math.pi / 180) * rotation.z 
	}
	local direction = 
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		z = math.sin(adjustedRotation.x)
	}
	return direction
end
i = -45.0
j = -15.0
function RayCastGamePlayCamera(distance)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if i > 57.0 then 
        i = -57.0
        j = j - 5.0
    end
    if j < -20 then
        j = 20.0
    end
    i = i + 10.0
	local cameraRotation = GetEntityRotation(vehicle) + vector3(j, 0.0, i)
	local cameraCoord = GetEntityCoords(vehicle)
	local direction = RotationToDirection(cameraRotation)
	local destination = 
	{ 
		x = cameraCoord.x + direction.x * distance, 
		y = cameraCoord.y + direction.y * distance, 
		z = cameraCoord.z + direction.z * distance 
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y , cameraCoord.z+ 2.0, destination.x, destination.y, destination.z, -1, -1, 1))
	return b, c, e
end


-- create a thread and run ray-casting
Citizen.CreateThread(function()
    while true do
        if GetVehiclePedIsIn(PlayerPedId(), false) ~= 0 then
            local hit, coords, entity = RayCastGamePlayCamera(100.0)
            local position = GetEntityCoords(GetPlayerPed(-1))
            distance = position - coords
            if hit and #distance < 1000 then 
                DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, 0, 255, 0, 255)
            end
            local flag, x, y, z = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)
            print("radius is :", #distance)
            if hit and (IsEntityAVehicle(entity) or IsEntityAPed(entity)) then
                local position = GetEntityCoords(GetPlayerPed(-1))
                DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, 255, 0, 0, 255)
            end
        end
        Citizen.Wait(0)
	end
end)

-- create a thread and run sensors
Citizen.CreateThread(function()
        rover_process_sensors()
        Citizen.Wait(0)   
end)


