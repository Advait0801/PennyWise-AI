"""
compat.py — ensures bcrypt + passlib work on Python 3.13+
"""
import bcrypt
import types

# Some bcrypt builds don't expose __about__ (needed by Passlib)
if not hasattr(bcrypt, "__about__"):
    bcrypt.__about__ = types.SimpleNamespace(__version__=bcrypt.__version__)
