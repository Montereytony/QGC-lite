import asyncio
from mavsdk import System

async def run():
    drone = System()
    await drone.connect(system_address="serial:///dev/serial0:57600")
    
    print("Waiting for drone to connect...")
    async for state in drone.core.connection_state():
        if state.is_connected:
            print("Drone connected!")
            break
    
    async for gps in drone.telemetry.position():
        print(f"Latitude: {gps.latitude_deg}, Longitude: {gps.longitude_deg}")
        break

asyncio.run(run())
