import glob
import os

def count_lines():
    patterns = ['**/*.gd', '**/*.tscn']
    total_lines = 0
    code_lines = 0
    comment_lines = 0
    blank_lines = 0
    
    file_stats = []
    
    for pat in patterns:
        for fpath in glob.glob(pat, recursive=True):
            if 'tools' in fpath:
                continue
            with open(fpath, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            f_tot = len(lines)
            f_code = 0
            f_comm = 0
            f_blank = 0
            
            for line in lines:
                stripped = line.strip()
                if not stripped:
                    f_blank += 1
                elif stripped.startswith('#') or stripped.startswith(';'):
                    f_comm += 1
                else:
                    f_code += 1
                    
            total_lines += f_tot
            code_lines += f_code
            comment_lines += f_comm
            blank_lines += f_blank
            
            file_stats.append((fpath, f_code, f_tot))
            
    print("==================================================")
    print("          SURVIVE THE NIGHT - LOC REPORT          ")
    print("==================================================")
    for path, c_lines, t_lines in sorted(file_stats, key=lambda x: -x[1]):
        print(f"{path:<55} | {c_lines:>5} code | {t_lines:>5} total")
    print("--------------------------------------------------")
    print(f"Total Meaningful Code Lines: {code_lines:>6}")
    print(f"Total Comment Lines:        {comment_lines:>6}")
    print(f"Total Blank Lines:          {blank_lines:>6}")
    print(f"Grand Total Lines:          {total_lines:>6}")
    print("==================================================")

if __name__ == '__main__':
    count_lines()
