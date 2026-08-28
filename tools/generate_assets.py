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

    # 1. Boss Night Terror (64x64)
    def boss_pix(x, y, w, h):
        cx, cy = w / 2.0, h / 2.0
        dist = ((x - cx)**2 + (y - cy)**2)**0.5
        if dist > 26: return (0, 0, 0, 0)
        if dist >= 24: return (10, 5, 20, 255) # Shadow outline
        # Glowing crimson horns
        if y < 20 and (x < 20 or x > 44):
            return (220, 30, 60, 255)
        # Fiery demonic eyes
        if 22 <= y <= 26 and (20 <= x <= 25 or 39 <= x <= 44):
            return (255, 40, 20, 255)
        # Dark void carapace
        shade = 30 + int((x * 17 + y * 23) % 30)
        return (shade + 20, shade, shade + 35, 255)

    with open('assets/sprites/boss_night_terror.png', 'wb') as f:
        f.write(make_png(64, 64, boss_pix))

    print("Generated boss sprite successfully.")

if __name__ == '__main__':
    generate_all()
