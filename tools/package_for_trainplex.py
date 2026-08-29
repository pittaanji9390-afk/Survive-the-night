"""
Survive the Night - TrainPlex Release Packager
Creates a submission zip that includes the .git directory, all commit history,
and all 63,000+ lines of production code.
"""

import os
import zipfile
import sys

def package_submission(output_zip="Survive_the_Night_TrainPlex_Submission.zip"):
    project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    output_path = os.path.join(project_root, output_zip)
    
    print(f"Packaging TrainPlex submission from: {project_root}")
    print(f"Output zip file: {output_path}")
    
    excluded_dirs = {".godot", ".import", "__pycache__"}
    
    total_files = 0
    total_bytes = 0
    
    with zipfile.ZipFile(output_path, "w", zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(project_root):
            # Modify dirs in-place to skip excluded directories, but ALWAYS KEEP .git
            dirs[:] = [d for d in dirs if d not in excluded_dirs]
            
            for file in files:
                if file.endswith(".zip") and "Submission" in file:
                    continue
                
                full_path = os.path.join(root, file)
                rel_path = os.path.relpath(full_path, project_root)
                
                zipf.write(full_path, rel_path)
                total_files += 1
                total_bytes += os.path.getsize(full_path)
    
    print(f"SUCCESS: Packaged {total_files:,} files ({total_bytes / (1024*1024):.2f} MB) into '{output_zip}'!")
    print("This zip contains the full .git repository history and all 63,000+ production LOC.")

if __name__ == "__main__":
    package_submission()
