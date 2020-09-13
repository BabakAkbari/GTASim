const dgram = require('dgram');
var SITL_ip = '192.168.137.64';
var sensor_port = 9003;
var sensor_flag = false;
const control_port = 9002;
const client_sensor = dgram.createSocket('udp4');
const server_control = dgram.createSocket('udp4');
var timestamp = 0;
onNet(
    "SensorData",
    (gyro_vector, acceleration_vector, position_vector, attitude_vector, velocity_vector) => {

        // print("here")
        // var hrTime = process.hrtime();
        // var timestamp = hrTime[0] * 1000000 + hrTime[1] / 1000;
        timestamp = timestamp + 1;
        // print('timestamp is:', timestamp)
        // console.log(position_vector[2])
        const message = `
            {"timestamp":${timestamp},"imu":{"gyro":[${gyro_vector[0]},${gyro_vector[1]},${gyro_vector[2]}],"accel_body":[${acceleration_vector[0]},${acceleration_vector[1]},${acceleration_vector[2]}]},"position":[${position_vector[0].toFixed(7)},${position_vector[1].toFixed(7)},${position_vector[2].toFixed(3)}],"attitude":[${attitude_vector[0]},${attitude_vector[1]},${attitude_vector[2]}],"velocity":[${velocity_vector[0]},${velocity_vector[1]},${velocity_vector[2]}]}
            `;
        // const message = `{"timestamp":${timestamp},"imu":{"gyro":[0,0,0],"accel_body":[0,0,0]},"position":[0,0,0],"attitude":[0,0,0],"velocity":[0,0,0]}
        // `;
        client_sensor.send(message, sensor_port, SITL_ip, (err) => {
            // console.error(err);
            // client_sensor.close();
        });
    }
);


server_control.on('error', (err) => {
    console.log(`server error:\n${err.stack}`);
    // server_control.close();
});

server_control.on('message', (msg, rinfo) => {
    // console.log(`server got: from ${rinfo.address}:${rinfo.port}`);
    SITL_ip = rinfo.address;
    sensor_port = rinfo.port;
    sensor_flag = true;
    const buff = Buffer.from(msg);
    const magic = buff.readUInt16LE(0);
    const frame_rate = buff.readUInt16LE(2);
    const frame_count = buff.readUInt32LE(4);
    const pwm1 = buff.readUInt16LE(8);
    const pwm2 = buff.readUInt16LE(10);
    const pwm3 = buff.readUInt16LE(12);
    const pwm4 = buff.readUInt16LE(14);
    // buffer.swap16();   // change endianness
    // var motors = new Uint16Array(buffer.buffer, buffer.byteOffset, buffer.length / 2);
    // setTimeout((frame_rate) => {console.log(frame_rate);}, 5000, frame_rate)
    var k = 1/20;
    b = 70;
    emitNet('pwmOutputs', -1 ,pwm1,pwm2,pwm3,pwm4);
    emitNet('MotorOutputs', -1, k * pwm1 - b, k * pwm2 - b, k * pwm3 - b, k * pwm4 - b);
});

server_control.on('listening', () => {
    const address = server_control.address();
    console.log(`server listening ${address.address}:${address.port}`);
});

server_control.bind(control_port);

