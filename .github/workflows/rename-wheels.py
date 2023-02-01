import sys
import os
from pathlib import Path
wheel_dir = sys.argv[1]

is_macos_arm_build = '--is-macos-arm' in sys.argv 

for filename in os.listdir(wheel_dir):
  filename = Path(wheel_dir, filename)
  if not filename.suffix == 'whl':
    continue
  new_filename = (filename
    .replace('cp311-cp311', 'py3-none')
    .replace('linux_x86_64', 'manylinux_2_17_x86_64.manylinux2014_x86_64')
    
    
  )
  if is_macos_arm_build:
    new_filename = new_filename.replace('macosx_12_0_universal2', 'macosx_11_0_arm64')
  else:
    new_filename = new_filename.replace('macosx_12_0_universal2', 'macosx_10_6_x86_64')
  
  os.rename(filename, new_filename)