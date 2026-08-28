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
        if dist >= 24: return (10, 5, 20, 255)
        if y < 20 and (x < 20 or x > 44): return (220, 30, 60, 255)
        if 22 <= y <= 26 and (20 <= x <= 25 or 39 <= x <= 44): return (255, 40, 20, 255)
        shade = 30 + int((x * 17 + y * 23) % 30)
        return (shade + 20, shade, shade + 35, 255)

    with open('assets/sprites/boss_night_terror.png', 'wb') as f:
        f.write(make_png(64, 64, boss_pix))

    # 2. Broodmother Boss (64x64)
    def broodmother_pix(x, y, w, h):
        cx, cy = w / 2.0, h / 2.0
        dist = ((x - cx)**2 + (y - cy)**2)**0.5
        if dist > 28: return (0, 0, 0, 0)
        if dist >= 26: return (20, 10, 30, 255)
        # Poisonous violet & green abdomen
        if y > 30:
            if ((x - cx)**2 + (y - 45)**2)**0.5 <= 16:
                return (80, 20, 100, 255)
        # Glowing multi-eyes
        if 18 <= y <= 24 and (24 <= x <= 28 or 36 <= x <= 40):
            return (50, 255, 50, 255) # Venom green
        return (45, 30, 55, 255)

    with open('assets/sprites/boss_broodmother.png', 'wb') as f:
        f.write(make_png(64, 64, broodmother_pix))

    # 3. Cave Spider (32x32)
    def spider_pix(x, y, w, h):
        cx, cy = w / 2.0, h / 2.0
        dist = ((x - cx)**2 + (y - cy)**2)**0.5
        if dist > 13: return (0, 0, 0, 0)
        if dist >= 11: return (15, 10, 20, 255)
        if 10 <= y <= 13 and (12 <= x <= 14 or 18 <= x <= 20): return (255, 30, 30, 255)
        return (50, 40, 60, 255)

    with open('assets/sprites/cave_spider.png', 'wb') as f:
        f.write(make_png(32, 32, spider_pix))

    # 4. Crystal Golem (32x32)
    def golem_pix(x, y, w, h):
        cx, cy = w / 2.0, h / 2.0
        dist = ((x - cx)**2 + (y - cy)**2)**0.5
        if dist > 14: return (0, 0, 0, 0)
        if dist >= 12: return (20, 40, 60, 255)
        if (x + y) % 6 == 0: return (80, 220, 255, 255) # Cyan crystal veins
        return (70, 80, 95, 255)

    with open('assets/sprites/crystal_golem.png', 'wb') as f:
        f.write(make_png(32, 32, golem_pix))

    # 5. Cave Tiles & Mineral Sprites
    def dungeon_tile_pix(x, y, w, h):
        return (35 + (x*3 + y*7)%15, 30 + (x*5 + y*2)%15, 40 + (x*11 + y*3)%15, 255)

    with open('assets/tiles/dungeon_stone_tile.png', 'wb') as f:
        f.write(make_png(32, 32, dungeon_tile_pix))

    print("Generated all Act 1 dungeon assets successfully.")

if __name__ == '__main__':
    generate_all()
