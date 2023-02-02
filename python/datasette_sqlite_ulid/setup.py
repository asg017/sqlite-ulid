from setuptools import setup

VERSION = "0.1.1-alpha.4"

setup(
    name="datasette-sqlite-ulid",
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
    license="MIT License, Apache License, Version 2.0",
    version=VERSION,
    packages=["datasette_sqlite_ulid"],
    entry_points={"datasette": ["sqlite_ulid = datasette_sqlite_ulid"]},
    install_requires=["datasette", "sqlite-ulid"],
    extras_require={"test": ["pytest"]},
    python_requires=">=3.6",
)