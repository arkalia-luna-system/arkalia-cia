#!/usr/bin/env python3
"""Setup script for Arkalia CIA Python backend."""

from setuptools import find_packages, setup  # type: ignore

setup(
    name="arkalia-cia",
    version="1.3.0",
    description="Arkalia CIA - Assistant Mobile Santé",
    long_description=open("README.md", encoding="utf-8").read(),
    long_description_content_type="text/markdown",
    author="Arkalia Luna System",
    author_email="arkalia.luna.system@gmail.com",
    url="https://github.com/arkalia-luna-system/arkalia-cia",
    packages=find_packages(include=["arkalia_cia_python_backend*"]),
    exclude_package_data={
        "": [
            "tests*",
            "arkalia_cia",
            "docs*",
            "arkalia_cia_venv*",
            "build*",
            "dist*",
            ".*",
        ]
    },
    python_requires=">=3.10",
    install_requires=[
        "fastapi>=0.116.1",
        "uvicorn>=0.35.0",
        "pydantic>=2.0.0",
        "python-multipart>=0.0.20",
        "python-magic>=0.4.27",
        "pypdf>=4.0.0",
        "rich>=13.5.3",
        "python-dotenv>=1.1.1",
    ],
    extras_require={
        "dev": [
            "pytest>=8.4.2",
            "pytest-asyncio>=0.21.1",
            "pytest-cov>=7.0.0",
            "black>=24.0.0",
            "ruff>=0.1.6",
            "mypy>=1.8.0",
            "bandit>=1.7.5",
            "safety>=3.0.0",
        ],
    },
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: End Users/Desktop",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Topic :: Scientific/Engineering :: Medical Science Apps.",
    ],
    keywords="health mobile flutter python security",
    project_urls={
        "Homepage": "https://github.com/arkalia-luna-system/arkalia-cia",
        "Repository": "https://github.com/arkalia-luna-system/arkalia-cia.git",
        "Issues": "https://github.com/arkalia-luna-system/arkalia-cia/issues",
    },
)
