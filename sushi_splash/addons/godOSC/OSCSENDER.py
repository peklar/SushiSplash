import pyautogui
import time
from pythonosc.udp_client import SimpleUDPClient

# OSC setup
ip = "127.0.0.1"
port = 4646
client = SimpleUDPClient(ip, port)

# Value mapping function (returns float)
def map_value(x, in_min, in_max, out_min, out_max):
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min

# Get the screen size
screen_width, screen_height = pyautogui.size()

try:
    while True:
        # Get current mouse position
        mouse_x, mouse_y = pyautogui.position()

        # Clamp to screen bounds
        mouse_x = max(0, min(mouse_x, screen_width))
        mouse_y = max(0, min(mouse_y, screen_height))

        # Map to game resolution (e.g., 1920x1080)
        mapped_x = map_value(mouse_x, 0, screen_width, 0, 1920)
        mapped_y = map_value(mouse_y, 0, screen_height, 0, 1080)

        # Send OSC messages as floats
        client.send_message("/packet",[float(mapped_x),float(mapped_y)])
        time.sleep(0.01)  # 100 updates per second

except KeyboardInterrupt:
    print("Stopped by user.")
