from setuptools import setup, Extension
import os
import platform

VERSION = "0.0.1.alpha-5"

system = platform.system()
machine = platform.machine()

print(system, machine)

if system == 'Darwin':
  if machine not in ['x86_64', 'arm64']:
    raise Exception("unsupported platform")  
elif system == 'Linux':
  if machine not in ['x86_64']:
    raise Exception("unsupported platform")
elif system == 'Windows':
  pass
else: 
  raise Exception("unsupported platform")

setup(
    name="sqlite-ulid",
    description="",
    long_description="",
    long_description_content_type="text/markdown",
    author="Alex Garcia",
    url="https://github.com/asg017/sqlite-ulid",
    project_urls={
        "Issues": "https://github.com/asg017/sqlite-ulid/issues",
        "CI": "https://github.com/asg017/sqlite-ulid/actions",
        "Changelog": "https://github.com/asg017/sqlite-ulid/releases",
    },
    license="Apache License, Version 2.0",
    version=VERSION,
    packages=["sqlite_ulid"],
    package_data={"sqlite_ulid": ['*.so', '*.dylib', '*.dll']},
    install_requires=[],
    ext_modules=[Extension("noop", ["noop.c"], optional=True)],
    extras_require={"test": ["pytest"]},
    python_requires=">=3.7",
)