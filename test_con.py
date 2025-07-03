from pymavlink import mavutil

# Create a connection to the Pixhawk via TELEM2
connection = mavutil.mavlink_connection('/dev/serial0', baud=57600)

# Wait for the heartbeat message to confirm connection
connection.wait_heartbeat()
print("Heartbeat received from Pixhawk!")

# Example: Request and print the vehicle’s GPS data
while True:
    msg = connection.recv_match(type='GLOBAL_POSITION_INT', blocking=True)
    if msg:
        print(f"Lat: {msg.lat/1e7}, Lon: {msg.lon/1e7}, Alt: {msg.alt/1e3}")
