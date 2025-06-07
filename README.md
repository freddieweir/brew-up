# 🍺 Brew Manager - Professional Homebrew Package Management

[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
[![Type checked: mypy](https://img.shields.io/badge/type%20checked-mypy-blue.svg)](https://mypy.readthedocs.io/)

> **A comprehensive, professional solution for managing Homebrew packages with VM template generation capabilities, built following Python best practices.**

## 🎯 **What Makes This Special**

This project serves as both a **powerful Homebrew management tool** and a **showcase of professional Python development practices**. It demonstrates:

- ✨ **Modern Python Architecture** - Clean, modular design with proper separation of concerns
- 🔧 **Professional Tooling** - Type hints, linting, testing, and documentation
- 🎨 **Rich CLI Experience** - Beautiful terminal interfaces with emojis and colors
- 📦 **Proper Packaging** - Using modern `pyproject.toml` configuration
- 🏗️ **Scalable Structure** - Organized codebase following Python best practices
- 🔄 **Template Generation** - Jinja2-powered VM installation script creation
- 💾 **Drive Packaging** - USB drive preparation for offline installations

---

## 🚀 **Features**

### 🏠 **Main Machine Management**
- **Smart Package Discovery** - Scan installed applications and find brew equivalents
- **Dependency-Safe Cleanup** - Remove packages without breaking existing software
- **Template Management** - Create and manage installation templates
- **Status Monitoring** - View system and package information

### 🖥️ **VM Template Generation**
- **Multiple Templates** - Minimal, Development, and Full configurations
- **Custom Packages** - Add your own formulae and casks to templates
- **Auto-Generated Scripts** - Professional bash scripts with error handling
- **USB Drive Packages** - Complete offline installation packages

### 🎨 **Professional User Experience**
- **Interactive CLI** - Rich terminal interface with menus and tables
- **Command Line Interface** - Full CLI support for automation
- **Beautiful Output** - Colorful, emoji-rich feedback
- **Progress Tracking** - Real-time installation progress

---

## 📁 **Project Structure**

```
brew-manager/
├── src/brew_manager/           # Main package source
│   ├── __init__.py            # Package exports and metadata
│   ├── cli/                   # Command line interface
│   │   ├── __init__.py
│   │   └── main.py           # Click-based CLI with Rich UI
│   ├── core/                  # Core business logic
│   │   ├── __init__.py
│   │   ├── config.py         # Pydantic configuration management
│   │   ├── manager.py        # Homebrew package operations
│   │   ├── scanner.py        # Application scanning logic
│   │   └── template_generator.py  # Jinja2 template generation
│   ├── templates/             # Jinja2 templates
│   │   └── vm_install_script.j2
│   └── utils/                 # Utility functions
├── tests/                     # Test suite
├── docs/                      # Documentation
├── pyproject.toml            # Modern Python project configuration
├── README.md                 # This file
└── LICENSE                   # MIT License
```

---

## 🛠️ **Installation**

### **For End Users**

```bash
# Install from source (recommended for development)
git clone https://github.com/user/brew-manager.git
cd brew-manager
pip install -e .

# Or install from PyPI (when published)
pip install brew-manager
```

### **For Developers**

```bash
# Clone and set up development environment
git clone https://github.com/user/brew-manager.git
cd brew-manager

# Install with development dependencies
pip install -e ".[dev]"

# Set up pre-commit hooks
pre-commit install
```

---

## 🎮 **Usage**

### **Interactive Mode (Recommended)**

```bash
# Start the interactive interface
brew-manager
# or use the short alias
bm
```

This launches a beautiful, menu-driven interface where you can:
- 📦 Manage local packages
- 🔍 Scan for brew equivalents  
- 📋 Generate VM templates
- 💾 Create USB drive packages
- ⚙️ Configure templates

### **Command Line Interface**

```bash
# Generate a specific template
brew-manager generate minimal

# Scan system for applications
brew-manager scan --export results.json

# Create USB drive package
brew-manager package /Volumes/MyUSB
```

---

## 📋 **Template System**

### **Built-in Templates**

#### 🎯 **Minimal Template**
```yaml
essential_formulae:
  - git
  - curl  
  - wget
  - tree
  - htop
  - jq

essential_casks:
  - reminders-menubar
```

#### 🔧 **Development Template** 
```yaml
# All minimal packages plus:
development_formulae:
  - node
  - npm
  - yarn
  - docker
  - docker-compose
  - cmake

development_casks:
  - visual-studio-code
  - docker
  - postman
```

#### 🎪 **Full Template**
```yaml
# All development packages plus:
productivity_casks:
  - alt-tab
  - rectangle
  - obsidian
```

### **Custom Templates**

Create your own templates by editing `~/.config/brew-manager/config.yaml`:

```yaml
templates:
  my-custom:
    name: "my-custom-setup"
    include_development: true
    include_productivity: false
    custom_formulae:
      - "my-special-tool"
    custom_casks:
      - "my-favorite-app"
```

---

## 🏗️ **Architecture & Best Practices**

This project demonstrates professional Python development practices:

### **🎨 Modern Python Features**
- **Type Hints** - Full type annotations for better IDE support
- **Dataclasses & Pydantic** - Structured configuration management
- **Context Managers** - Proper resource handling
- **Pathlib** - Modern path manipulation

### **🏛️ Clean Architecture**
- **Separation of Concerns** - CLI, core logic, and configuration separated
- **Dependency Injection** - Configurable components
- **Single Responsibility** - Each module has a clear purpose
- **Interface Segregation** - Clean, focused APIs

### **🔧 Professional Tooling**
- **Black** - Consistent code formatting
- **isort** - Import sorting
- **mypy** - Static type checking
- **pytest** - Comprehensive testing
- **pre-commit** - Git hooks for quality

### **📦 Modern Packaging**
- **pyproject.toml** - Modern Python packaging
- **Semantic Versioning** - Clear version management
- **Entry Points** - Professional CLI installation
- **Optional Dependencies** - Development and documentation extras

---

## 🧪 **Development**

### **Running Tests**

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=brew_manager

# Run specific test file
pytest tests/test_config.py
```

### **Code Quality**

```bash
# Format code
black src/ tests/

# Sort imports  
isort src/ tests/

# Type checking
mypy src/

# Linting
flake8 src/ tests/
```

### **Building Documentation**

```bash
# Install docs dependencies
pip install -e ".[docs]"

# Build documentation
cd docs/
make html
```

---

## 📊 **Example Workflow**

### **Setting Up a New VM**

1. **On your main machine:**
   ```bash
   brew-manager
   # Choose "4. Create Drive Package"
   # Select USB drive path
   ```

2. **On the new VM:**
   ```bash
   # Insert USB drive and navigate to it
   cd /Volumes/MyUSB/brew-setup
   ./setup.sh
   # Choose your desired template
   ```

3. **Enjoy your configured environment!**

### **Finding Brew Equivalents**

```bash
brew-manager scan
# View results showing:
# ✅ Apps already managed by brew
# 🔍 Apps with brew equivalents available
# ❌ Apps without brew equivalents
```

---

## 🤝 **Contributing**

We welcome contributions! This project serves as an example of professional Python development.

### **Development Setup**

```bash
# Fork and clone the repository
git clone https://github.com/yourusername/brew-manager.git
cd brew-manager

# Set up development environment
pip install -e ".[dev]"
pre-commit install

# Create a feature branch
git checkout -b feature/amazing-feature

# Make changes and commit
git commit -m "Add amazing feature"

# Push and create PR
git push origin feature/amazing-feature
```

### **Code Standards**

- Follow PEP 8 and use Black formatting
- Add type hints to all functions
- Write tests for new functionality
- Update documentation as needed
- Use conventional commit messages

---

## 📚 **Python Best Practices Demonstrated**

This project showcases:

- **📁 Proper Package Structure** - Standard Python package layout
- **🔧 Modern Configuration** - `pyproject.toml` instead of `setup.py`
- **🎯 Type Safety** - Full type annotations with mypy checking
- **🧪 Testing** - Comprehensive test suite with pytest
- **📖 Documentation** - Sphinx documentation with type hints
- **🔄 CI/CD Ready** - GitHub Actions workflow ready
- **📦 Distribution** - PyPI-ready packaging
- **🏗️ Extensible Design** - Plugin-ready architecture

---

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 **Acknowledgments**

- **Homebrew** - For making package management on macOS amazing
- **Rich** - For beautiful terminal interfaces
- **Click** - For powerful CLI creation
- **Pydantic** - For robust configuration management
- **Jinja2** - For flexible template generation

---

## 💡 **Why This Project Matters**

**Brew Manager** isn't just a tool - it's a **template for professional Python development**. Whether you're:

- 🎓 **Learning Python** - See how real projects are structured
- 💼 **Building Enterprise Tools** - Follow established patterns
- 🚀 **Creating Open Source** - Use as a starting template
- 🔧 **Managing Infrastructure** - Solve real automation problems

This project demonstrates that **Python tools can be both powerful and beautiful**.

---

<div align="center">

**⭐ Star this repo if it helped you! ⭐**

[Report Bug](https://github.com/user/brew-manager/issues) · [Request Feature](https://github.com/user/brew-manager/issues) · [Documentation](https://brew-manager.readthedocs.io)

</div>