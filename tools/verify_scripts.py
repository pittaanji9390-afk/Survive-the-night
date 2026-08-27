import os
import glob
import re

def verify_scripts():
    gd_files = glob.glob('**/*.gd', recursive=True)
    print(f"Verifying {len(gd_files)} GDScript files...")
    
    errors = 0
    for path in sorted(gd_files):
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Check basic syntax rules
        lines = content.splitlines()
        for idx, line in enumerate(lines, 1):
            stripped = line.strip()
            if not stripped or stripped.startswith('#'):
                continue
            
            # Check for illegal python syntax accidentally placed in GDScript (like def, None, True/False vs true/false)
            if re.match(r'^\s*def\s+', line):
                print(f"Error in {path}:{idx}: Python 'def' used instead of GDScript 'func'")
                errors += 1
            if re.search(r'\bNone\b', line):
                print(f"Error in {path}:{idx}: Python 'None' used instead of GDScript 'null'")
                errors += 1
            if re.search(r'\bTrue\b', line) and not re.search(r'#.*True', line):
                print(f"Error in {path}:{idx}: Python 'True' used instead of GDScript 'true'")
                errors += 1
            if re.search(r'\bFalse\b', line) and not re.search(r'#.*False', line):
                print(f"Error in {path}:{idx}: Python 'False' used instead of GDScript 'false'")
                errors += 1

    tscn_files = glob.glob('**/*.tscn', recursive=True)
    print(f"Verifying {len(tscn_files)} Scene (TSCN) files...")
    for tpath in sorted(tscn_files):
        with open(tpath, 'r', encoding='utf-8') as f:
            tcontent = f.read()
        if not tcontent.startswith('[gd_scene'):
            print(f"Error in {tpath}: Does not start with [gd_scene")
            errors += 1
            
    if errors == 0:
        print(f"SUCCESS: All {len(gd_files)} scripts and {len(tscn_files)} scenes verified with 0 errors!")
    else:
        print(f"FAILED: Found {errors} syntax/format errors.")

if __name__ == '__main__':
    verify_scripts()
