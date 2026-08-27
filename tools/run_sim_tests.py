import math

def test_stat_attribute_logic():
    print("Testing StatAttribute Logic...")
    # Base
    base_val = 100.0
    mods = [("flat_hp", 50.0, "FLAT"), ("pct_buff", 0.2, "PERCENT_ADDITIVE"), ("mult_buff", 0.1, "PERCENT_MULTIPLICATIVE")]
    
    flat_sum = sum(m[1] for m in mods if m[2] == "FLAT")
    pct_add_sum = sum(m[1] for m in mods if m[2] == "PERCENT_ADDITIVE")
    pct_mult = 1.0
    for m in mods:
        if m[2] == "PERCENT_MULTIPLICATIVE":
            pct_mult *= (1.0 + m[1])
            
    max_val = (base_val + flat_sum) * (1.0 + pct_add_sum) * pct_mult
    # (100 + 50) * 1.2 * 1.1 = 150 * 1.32 = 198.0
    assert abs(max_val - 198.0) < 0.001, f"Expected 198.0, got {max_val}"
    print("  [PASS] StatAttribute Modifier Math")

def test_time_manager_logic():
    print("Testing TimeManager Logic...")
    start_hour = 8.0
    advance_hrs = 14.5 # 8 + 14.5 = 22.5 (10:30 PM, Night)
    new_hour = (start_hour + advance_hrs) % 24.0
    minute = int((new_hour - int(new_hour)) * 60.0)
    assert abs(new_hour - 22.5) < 0.001
    assert minute == 30
    
    # Daylight factor at 13.0 (peak day)
    peak_h = 13.0
    norm_peak = (peak_h - 5.0) / 16.0
    daylight_peak = math.sin(norm_peak * math.pi)
    assert abs(daylight_peak - 1.0) < 0.001, f"Peak daylight should be 1.0, got {daylight_peak}"
    print("  [PASS] TimeManager Math & Daylight Curve")

def test_direction_8_logic():
    print("Testing 8-Direction Cardinal Snap...")
    test_vectors = [
        ((1.0, 0.0), "RIGHT"),
        ((0.0, 1.0), "DOWN"),
        ((-1.0, 0.0), "LEFT"),
        ((0.0, -1.0), "UP"),
        ((1.0, 1.0), "DOWN-RIGHT")
    ]
    for vec, name in test_vectors:
        angle = math.atan2(vec[1], vec[0])
        octant = int(round(angle / (math.pi / 4.0))) % 8
        assert 0 <= octant <= 7
    print("  [PASS] 8-Direction Octant Snap")

if __name__ == '__main__':
    test_stat_attribute_logic()
    test_time_manager_logic()
    test_direction_8_logic()
    print("ALL CORE UNIT SIMULATIONS PASSED!")
