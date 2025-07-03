# rpi_edge_node/main.py

import asyncio
import json
import websockets
from pymavlink import mavutil

# --- Configuration ---
PIXHAWK_CONNECTION_STRING = '/dev/ttyAMA0'
PIXHAWK_BAUDRATE = 57600

# For testing, we use a public echo server.
# Later, this will be your own cloud server's address.
# CLOUD_WEBSOCKET_URI = "wss://socketsbay.com/wss/v2/1/demo/"
# Let's use a more standard echo server:
CLOUD_WEBSOCKET_URI = "wss://echo.websocket.events"


async def run_mavlink_to_websocket_bridge():
    """
    Connects to a Pixhawk, reads MAVLink messages, and forwards them
    as JSON over a WebSocket connection.
    """
    print(f"Connecting to Pixhawk on {PIXHAWK_CONNECTION_STRING} at {PIXHAWK_BAUDRATE} baud...")
    
    # Using mavutil.mavlink_connection in a non-blocking way
    # We will poll for messages instead of blocking
    try:
        pixhawk = mavutil.mavlink_connection(PIXHAWK_CONNECTION_STRING, baud=PIXHAWK_BAUDRATE)
    except Exception as e:
        print(f"Failed to connect to Pixhawk: {e}")
        return

    pixhawk.wait_heartbeat()
    print("Heartbeat from Pixhawk received!")

    print(f"Connecting to WebSocket server at {CLOUD_WEBSOCKET_URI}...")
    try:
        async with websockets.connect(CLOUD_WEBSOCKET_URI) as websocket:
            print("Successfully connected to WebSocket server.")
            
            while True:
                # Poll for a new MAVLink message
                msg = pixhawk.recv_match(blocking=False)

                if msg:
                    # Convert message to a dictionary and add its type
                    msg_dict = msg.to_dict()
                    msg_dict['mav_type'] = msg.get_type()
                    
                    # Convert dict to JSON string and send over WebSocket
                    await websocket.send(json.dumps(msg_dict))
                    print(f"Sent: {msg.get_type()}") # Print to console for confirmation

                # Give the event loop a chance to run other tasks
                await asyncio.sleep(0.01)

    except (websockets.exceptions.ConnectionClosedError, ConnectionRefusedError) as e:
        print(f"WebSocket connection error: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

if __name__ == "__main__":
    try:
        # Run the main asynchronous function
        asyncio.run(run_mavlink_to_websocket_bridge())
    except KeyboardInterrupt:
        print("\nScript interrupted by user.")
