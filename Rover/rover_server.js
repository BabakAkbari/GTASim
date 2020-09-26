// defining variables
const dgram = require('dgram');
const client_sensor = dgram.createSocket('udp4');
const server_control = dgram.createSocket('udp4');
var SITL_ip = '192.168.137.64';
var sensor_port = 9003;
const control_port = 9002;
var timestamp = 0;

// event call-back triggred from client
onNet(
    "SensorData",
    (gyro_vector, acceleration_vector, position_vector, attitude_vector, velocity_vector) => {
        timestamp = timestamp + 1/50;
        const message = `
            {"timestamp":${timestamp},"imu":{"gyro":[${gyro_vector[0]},${gyro_vector[1]},${gyro_vector[2]}],"accel_body":[${acceleration_vector[0]},${acceleration_vector[1]},${acceleration_vector[2]}]},"position":[${position_vector[0].toFixed(7)},${position_vector[1].toFixed(7)},${position_vector[2].toFixed(3)}],"attitude":[${attitude_vector[0]},${attitude_vector[1]},${attitude_vector[2]}],"velocity":[${velocity_vector[0]},${velocity_vector[1]},${velocity_vector[2]}]}
            `;
        client_sensor.send(message, sensor_port, SITL_ip, (err) => {
        });
    }
);

// server error handler 
server_control.on('error', (err) => {
    console.log(`server error:\n${err.stack}`);
});

// parse response from Ardupilot auto detect ip and port
server_control.on('message', (msg, rinfo) => {
    SITL_ip = rinfo.address;
    sensor_port = rinfo.port;
    const buff = Buffer.from(msg);
    const magic = buff.readUInt16LE(0);
    const frame_rate = buff.readUInt16LE(2);
    const frame_count = buff.readUInt32LE(4);
    const pwm1 = buff.readUInt16LE(8);
    const pwm2 = buff.readUInt16LE(10);
    const pwm3 = buff.readUInt16LE(12);
    const pwm4 = buff.readUInt16LE(14);
    const k = 1 / 20;
    const b = 70;
    emitNet('PWMOutputs', -1, pwm1, pwm2, pwm3, pwm4);
    emitNet('MotorOutputs', -1, k * pwm1 - b, k * pwm2 - b, k * pwm3 - b, k * pwm4 - b);
});

// server listen callback
server_control.on('listening', () => {
    const address = server_control.address();
    console.log(`server listening ${address.address}:${address.port}`);
});

server_control.bind(control_port);
