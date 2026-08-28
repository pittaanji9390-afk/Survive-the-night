import os
import struct
import zlib

def make_png(width, height, get_pixel_func):
    raw_data = bytearray()
    for y in range(height):
        raw_data.append(0) # filter type 0 (None)
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
        dx, dy = x - cx, y - cy
        dist = (dx*dx + dy*dy)**0.5
        if dist > 13:
            return (0, 0, 0, 0)
        if dist >= 12:
            return (20, 24, 30, 255)
        if y < 14: # Head
            if 8 <= y <= 10 and (x in (12, 13, 18, 19)):
                return (20, 24, 30, 255)
            return (230, 190, 150, 255)
        elif y >= 14 and y <= 24:
            if 13 <= x <= 18:
                return (40, 140, 110, 255)
            return (30, 115, 90, 255)
        else:
            return (70, 50, 40, 255)

    with open('assets/sprites/player.png', 'wb') as f:
        f.write(make_png(32, 32, player_pix))

    # 2. Grass Tile (32x32)
    def grass_pix(x, y, w, h):
        base_g = 130 + ((x * 17 + y * 31) % 25)
        base_r = 55 + ((x * 13 + y * 7) % 15)
        base_b = 45 + ((x * 23 + y * 11) % 15)
        if x == 0 or y == 0 or x == w - 1 or y == h - 1:
            base_g = max(40, base_g - 20)
        return (base_r, base_g, base_b, 255)

    with open('assets/tiles/grass_tile.png', 'wb') as f:
        f.write(make_png(32, 32, grass_pix))

    # 3. Dirt Tile (32x32)
    def dirt_pix(x, y, w, h):
        base_r = 140 + ((x * 29 + y * 19) % 20)
        base_g = 100 + ((x * 13 + y * 23) % 20)
        base_b = 65 + ((x * 7 + y * 17) % 15)
        return (base_r, base_g, base_b, 255)

    with open('assets/tiles/dirt_tile.png', 'wb') as f:
        f.write(make_png(32, 32, dirt_pix))

    # 4. Stone Wall (32x32)
    def stone_pix(x, y, w, h):
        if x == 0 or y == 0 or x == w - 1 or y == h - 1:
            return (40, 45, 55, 255)
        if y == 16 or (y < 16 and x == 16) or (y > 16 and (x == 8 or x == 24)):
            return (40, 45, 55, 255)
        shade = 110 + ((x * 19 + y * 13) % 30)
        return (shade, shade + 5, shade + 15, 255)

    with open('assets/tiles/stone_wall.png', 'wb') as f:
        f.write(make_png(32, 32, stone_pix))

    # 5. Tree (48x64)
    def tree_pix(x, y, w, h):
        dx = x - 24
        dy = y - 24
        dist = (dx*dx + dy*dy)**0.5
        if dist < 20 and y < 45:
            g = 120 + int((x * 7 + y * 13) % 40)
            r = 30 + int((x * 3 + y * 5) % 20)
            b = 30 + int((x * 11) % 20)
            return (r, g, b, 255)
        if 18 <= x <= 30 and 38 <= y <= 60:
            return (100, 65, 40, 255)
        return (0, 0, 0, 0)

    with open('assets/sprites/tree.png', 'wb') as f:
        f.write(make_png(48, 64, tree_pix))

    # 6. Monolith (32x48)
    def monolith_pix(x, y, w, h):
        if 6 <= x <= 26 and 6 <= y <= 44:
            if 14 <= x <= 18 and 14 <= y <= 36:
                return (60, 220, 240, 255)
            shade = 80 + ((x * 13 + y * 7) % 25)
            return (shade, shade + 10, shade + 20, 255)
        return (0, 0, 0, 0)

    with open('assets/sprites/monolith.png', 'wb') as f:
        f.write(make_png(32, 48, monolith_pix))

    # 7. Rock (32x32)
    def rock_pix(x, y, w, h):
        cx, cy = w / 2.0, h / 2.0
        dx, dy = (x - cx) * 1.0, (y - cy) * 1.3
        dist = (dx*dx + dy*dy)**0.5
        if dist > 12:
            return (0, 0, 0, 0)
        if dist >= 11:
            return (45, 50, 60, 255)
        shade = 115 + int((x * 13 + y * 17) % 25)
        return (shade, shade + 5, shade + 10, 255)

    with open('assets/sprites/rock.png', 'wb') as f:
        f.write(make_png(32, 32, rock_pix))

    # 8. Bush (32x32)
    def bush_pix(x, y, w, h):
        cx, cy = w / 2.0, h / 2.0
        dist = ((x - cx)**2 + (y - cy)**2)**0.5
        if dist > 13:
            return (0, 0, 0, 0)
        if (x, y) in [(10, 12), (11, 12), (20, 14), (21, 14), (15, 20), (16, 20), (22, 10), (13, 22)]:
            return (220, 30, 45, 255)
        g = 130 + int((x * 19 + y * 23) % 35)
        r = 35 + int((x * 5) % 15)
        b = 30 + int((y * 7) % 15)
        return (r, g, b, 255)

    with open('assets/sprites/bush.png', 'wb') as f:
        f.write(make_png(32, 32, bush_pix))

    # 9. Workbench (32x32)
    def workbench_pix(x, y, w, h):
        if 4 <= x <= 28 and 8 <= y <= 26:
            if y <= 14:
                return (140, 95, 55, 255) # Tabletop
            if (4 <= x <= 8 or 24 <= x <= 28) and y >= 14:
                return (100, 65, 35, 255) # Table legs
            if 12 <= x <= 20 and 12 <= y <= 16:
                return (180, 185, 195, 255) # Anvil tool on top
            return (110, 75, 45, 255)
        return (0, 0, 0, 0)

    with open('assets/sprites/workbench.png', 'wb') as f:
        f.write(make_png(32, 32, workbench_pix))

    # 10. Campfire (32x32)
    def campfire_pix(x, y, w, h):
        cx, cy = w / 2.0, h / 2.0
        dist = ((x - cx)**2 + (y - cy)**2)**0.5
        if dist > 12:
            return (0, 0, 0, 0)
        if dist >= 10:
            return (70, 75, 80, 255) # Stone ring
        if 12 <= x <= 20 and 10 <= y <= 22:
            return (255, 140, 20, 255) # Flame
        if 14 <= x <= 18 and 12 <= y <= 18:
            return (255, 240, 60, 255) # Bright core
        return (80, 50, 30, 255) # Wood ash

    with open('assets/sprites/campfire.png', 'wb') as f:
        f.write(make_png(32, 32, campfire_pix))

    print("Generated all updated assets including Workbench and Campfire.")

if __name__ == '__main__':
    generate_all()
