import pyautogui
import time
from pythonosc.udp_client import SimpleUDPClient

ip = "127.0.0.1"
port = 9000
client = SimpleUDPClient(ip, port)

screen_width, screen_height = pyautogui.size()
center_x, center_y = screen_width / 2, screen_height / 2

def send_pos():
    mouse_x, mouse_y = pyautogui.position()
    mouse_x = max(0, min(mouse_x, screen_width))
    mouse_y = max(0, min(mouse_y, screen_height))
    norm_x = (mouse_x - center_x) / center_x
    norm_y = (mouse_y - center_y) / center_y

    value1 = norm_x
    value2 = norm_x
    value3 = norm_x
    value4 = norm_x
    value5 = norm_x
    value6 = norm_x

    client.send_message("/posx", [norm_x])
    client.send_message("/posy", [norm_y])

    return norm_x, norm_y, value1, value2, value3, value4, value5, value6

def send_packet(norm_x, norm_y, value1, value2, value3, value4, value5, value6):
    client.send_message("/packet", [norm_x, norm_y, value1, value2, value3, value4, value5, value6])

pos_interval = 0.016
packet_interval = 0.3

last_pos = last_packet = time.time()

latest_values = (0, 0, 0, 0, 0, 0, 0, 0)

try:
    while True:
        now = time.time()

        if now - last_pos >= pos_interval:
            latest_values = send_pos()
            last_pos = now

        if now - last_packet >= packet_interval:
            send_packet(*latest_values)
            last_packet = now

        time.sleep(0.001)
except KeyboardInterrupt:
    print("Stopped by user.")
