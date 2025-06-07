"""
Brew Manager - Professional Homebrew Package Management Tool

A comprehensive solution for managing Homebrew packages on macOS and Linux,
with VM template generation capabilities and professional Python best practices.
"""

__version__ = "1.0.0"
__author__ = "Brew Manager"
__email__ = "brew-manager@example.com"
__license__ = "MIT"

# Public API exports
from .core.manager import BrewManager
from .core.scanner import BrewScanner
from .core.template_generator import TemplateGenerator
from .core.config import Config

__all__ = [
    "BrewManager",
    "BrewScanner", 
    "TemplateGenerator",
    "Config",
    "__version__",
] 