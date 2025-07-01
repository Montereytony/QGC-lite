# QGC-lite: A Lightweight, Web-Based Ground Control Station

A custom Ground Control Station for MAVLink-based drones, featuring a Raspberry Pi 5 edge node, a cloud-based backend, and a web UI for real-time telemetry, multi-camera streaming, and gimbal control.

---

## Architecture Overview

This project uses a distributed architecture to provide a flexible and accessible GCS.

```mermaid
graph TD
    A[Pixhawk 6C] --  MAVLink via USB/UART --> B(Raspberry Pi 5);
    C[2x Arducams] -- MIPI CSI --> B;
    D[Siyi A8 Mini] -- Ethernet/UART --> B;
    B -- Telemetry & Control (WebSocket) --> E{Cloud Server (Nginx + Node.js/Python)};
    B -- Video Streams (SRT/RTSP) --> E;
    E -- GCS Frontend (HTTPS) --> F((Web Browser));
    E -- Real-time Data (WebSocket) --> F;
```
* **Edge Node (RPi5):** Aggregates MAVLink telemetry, camera streams, and handles gimbal control.
* **Cloud Node:** Serves the web application and acts as a secure relay for data and commands.
* **Client (Browser):** Provides the user interface for monitoring and control from anywhere.

---

## Features (Planned)

* [x] Real-time telemetry display (Attitude, Altitude, Speed, Position)
* [x] Live map with drone position tracking
* [X] Multi-camera video streaming (2x MIPI, 1x IP Camera)
* [X] Siyi A8 gimbal and camera control
* [ ] Mission planning (Waypoint upload/download)
* [ ] Parameter configuration

---

## Technology Stack

* **Edge Node:** Python 3, `pymavlink`, `picamera2`, `pyserial`, `websockets`
* **Cloud Backend:** Node.js (or Python/FastAPI), `ws`, Nginx
* **Web Frontend:** HTML5, CSS3, JavaScript, Leaflet.js, WebRTC/SRT player
* **Protocol:** MAVLink, WebSocket, SRT/RTSP

---

## Setup & Installation

*(Instructions to be added here)*
