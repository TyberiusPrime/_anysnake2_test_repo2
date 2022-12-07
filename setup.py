# -*- coding: utf-8 -*-


"""setup.py: setuptools control."""


import re
from setuptools import setup


version = "0.33"
with open("README.rst", "rb") as f:
    long_descr = f.read().decode("utf-8")

setup(
    name="testrepo",
    packages=["testrepo"],
    version=version,
    description="Example package with a requirement that the anysnake2 must provide",
    long_description=long_descr,
    author="Tyberius Prime",
    author_email="nope",
    url="",
    install_requires=[
        "testrepo2"
    ],
)
