import os
import struct
import zlib

def make_png(width, height, get_pixel_func):
    raw_data = bytearray()
    for y in range(height):
        raw_data.append(0)
        for x in range(width):
            r, g, b, a = get_pixel_func(x, y, width, height)
            raw_data.extend([r, g, b, a])
    
    def chunk(tag, data):
        c_type = tag.encode('ascii')
        crc = zlib.crc32(c_type + data) & 0xffffffff
        return struct.pack('>I', len(data)) + c_type + data + struct.pack('>I', crc)
    
    header = b'\x89PNG\r\n\x1a\n'
    ihdr = struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)
    idat = zlib.compress(bytes(raw_data), 9)
    return header + chunk('IHDR', ihdr) + chunk('IDAT', idat) + chunk('IEND', b'')

def generate_all():
    os.makedirs('assets/sprites', exist_ok=True)
    os.makedirs('assets/tiles', exist_ok=True)

    # 1. Player Sprite (32x32)
    def player_pix(x, y, w, h):
        cx, cy = w / 2.0, h / 2.0
        dist = ((x - cx)**2 + (y - cy)**2)**0.5
        if dist > 13: return (0, 0, 0, 0)
        if dist >= 12: return (20, 24, 30, 255)
        if y < 14:
            if 8 <= y <= 10 and (x in (12, 13, 18, 19)): return (20, 24, 30, 255)
            return (230, 190, 150, 255)
        elif 14 <= y <= 24:
            return (40, 140, 110, 255) if 13 <= x <= 18 else (30, 115, 90, 255)
        return (70, 50, 40, 255)

    with open('assets/sprites/player.png', 'wb') as f:
        f.write(make_png(32, 32, player_pix))

    # 2. Zombie (32x32)
    def zombie_pix(x, y, w, h):
        cx, cy = w / 2.0, h / 2.0
        dist = ((x - cx)**2 + (y - cy)**2)**0.5
        if dist > 13: return (0, 0, 0, 0)
        if dist >= 12: return (15, 25, 20, 255) # Outline
        if y < 14:
            if 8 <= y <= 10 and (x in (11, 12, 19, 20)): return (240, 40, 30, 255) # Glowing red eyes
            return (70, 145, 80, 255) # Decayed green flesh
        elif 14 <= y <= 24:
            return (45, 55, 65, 255) # Tattered rags
        return (35, 40, 45, 255)

    with open('assets/sprites/zombie.png', 'wb') as f:
        f.write(make_png(32, 32, zombie_pix))

    # 3. Wolf (32x32)
    def wolf_pix(x, y, w, h):
        cx, cy = w / 2.0, h / 2.0
        dist = ((x - cx)**2 + (y - cy)**2)**0.5
        if dist > 12: return (0, 0, 0, 0)
        if 9 <= y <= 11 and (x in (10, 11, 20, 21)): return (255, 210, 40, 255) # Yellow eyes
        shade = 90 + int((x * 13 + y * 7) % 25)
        return (shade, shade, shade + 5, 255)

    with open('assets/sprites/wolf.png', 'wb') as f:
        f.write(make_png(32, 32, wolf_pix))

    # 4. Skeleton (32x32)
    def skeleton_pix(x, y, w, h):
        cx, cy = w / 2.0, h / 2.0
        dist = ((x - cx)**2 + (y - cy)**2)**0.5
        if dist > 12: return (0, 0, 0, 0)
        if 8 <= y <= 10 and (x in (12, 13, 18, 19)): return (10, 10, 15, 255) # Eye sockets
        return (215, 215, 210, 255) # Bone

    with open('assets/sprites/skeleton.png', 'wb') as f:
        f.write(make_png(32, 32, skeleton_pix))

    print("Generated all enemy sprites successfully.")

if __name__ == '__main__':
    generate_all()
