#!/usr/bin/env python3

import sys
import os
sys.path.append('/Users/fweir/py-utils')

from module_venv import AutoVirtualEnvironment

# Set up virtual environment with required packages
venv_manager = AutoVirtualEnvironment('venv-brew-scanner')
venv_manager.auto_switch(['requests', 'psutil', 'colorama', 'keyboard', 'json5'])

import subprocess
import json
import re
import time
import psutil
from pathlib import Path
from dataclasses import dataclass
from typing import List, Dict, Optional, Set
from colorama import init, Fore, Back, Style
import keyboard

# Initialize colorama for cross-platform colored output
init(autoreset=True)

@dataclass
class AppInfo:
    name: str
    path: str
    is_brew: bool
    brew_type: Optional[str] = None  # 'formula', 'cask', or None
    has_brew_equivalent: Optional[bool] = None
    brew_equivalent: Optional[str] = None
    description: Optional[str] = None

class BrewScanner:
    def __init__(self):
        self.brew_formulae: Set[str] = set()
        self.brew_casks: Set[str] = set()
        self.installed_apps: List[AppInfo] = []
        self.current_selection = 0
        self.menu_options = []
        
        # UI Colors and Emojis
        self.colors = {
            'header': Fore.CYAN + Style.BRIGHT,
            'success': Fore.GREEN + Style.BRIGHT,
            'warning': Fore.YELLOW + Style.BRIGHT,
            'error': Fore.RED + Style.BRIGHT,
            'info': Fore.BLUE + Style.BRIGHT,
            'selection': Back.BLUE + Fore.WHITE + Style.BRIGHT,
            'normal': Fore.WHITE,
            'dim': Fore.LIGHTBLACK_EX
        }
        
        self.emojis = {
            'brew': '🍺',
            'app': '📱',
            'search': '🔍',
            'check': '✅',
            'cross': '❌',
            'warning': '⚠️',
            'info': 'ℹ️',
            'arrow': '➡️',
            'back': '↩️',
            'rocket': '🚀',
            'gear': '⚙️',
            'folder': '📁',
            'computer': '💻'
        }

    def clear_screen(self):
        """Clear the terminal screen."""
        os.system('cls' if os.name == 'nt' else 'clear')

    def print_header(self, title: str):
        """Print a styled header."""
        print(self.colors['header'] + "=" * 60)
        print(f"{self.emojis['brew']} {title.center(56)} {self.emojis['brew']}")
        print("=" * 60 + Style.RESET_ALL)
        print()

    def print_colored(self, text: str, color_key: str = 'normal', emoji: str = ''):
        """Print colored text with optional emoji."""
        color = self.colors.get(color_key, self.colors['normal'])
        if emoji:
            print(f"{color}{emoji} {text}{Style.RESET_ALL}")
        else:
            print(f"{color}{text}{Style.RESET_ALL}")

    def get_brew_packages(self):
        """Get all installed brew packages (formulae and casks)."""
        try:
            self.print_colored("Scanning Homebrew packages...", 'info', self.emojis['search'])
            
            # Get formulae
            result = subprocess.run(['brew', 'list', '--formula'], 
                                 capture_output=True, text=True, check=True)
            self.brew_formulae = set(result.stdout.strip().split('\n')) if result.stdout.strip() else set()
            
            # Get casks (only on macOS)
            try:
                result = subprocess.run(['brew', 'list', '--cask'], 
                                     capture_output=True, text=True, check=True)
                self.brew_casks = set(result.stdout.strip().split('\n')) if result.stdout.strip() else set()
            except subprocess.CalledProcessError:
                self.print_colored("Casks not available (likely not on macOS)", 'warning', self.emojis['warning'])
                self.brew_casks = set()
            
            self.print_colored(f"Found {len(self.brew_formulae)} formulae and {len(self.brew_casks)} casks", 
                             'success', self.emojis['check'])
            
        except subprocess.CalledProcessError as e:
            self.print_colored(f"Error getting brew packages: {e}", 'error', self.emojis['cross'])
            return False
        return True

    def get_applications_macos(self) -> List[AppInfo]:
        """Get all applications on macOS."""
        apps = []
        app_dirs = ['/Applications', '/System/Applications', os.path.expanduser('~/Applications')]
        
        for app_dir in app_dirs:
            if os.path.exists(app_dir):
                for item in os.listdir(app_dir):
                    if item.endswith('.app'):
                        app_name = item[:-4].lower()  # Remove .app extension
                        full_path = os.path.join(app_dir, item)
                        
                        # Check if it's a brew cask
                        is_brew_cask = any(cask.lower() == app_name or 
                                         cask.lower().replace('-', '') == app_name.replace('-', '') or
                                         cask.lower().replace('-', '') == app_name.replace(' ', '') 
                                         for cask in self.brew_casks)
                        
                        apps.append(AppInfo(
                            name=item[:-4],  # Keep original case for display
                            path=full_path,
                            is_brew=is_brew_cask,
                            brew_type='cask' if is_brew_cask else None
                        ))
        
        return apps

    def get_applications_linux(self) -> List[AppInfo]:
        """Get all applications on Linux."""
        apps = []
        desktop_dirs = ['/usr/share/applications', os.path.expanduser('~/.local/share/applications')]
        
        for desktop_dir in desktop_dirs:
            if os.path.exists(desktop_dir):
                for item in os.listdir(desktop_dir):
                    if item.endswith('.desktop'):
                        app_name = item[:-8]  # Remove .desktop extension
                        full_path = os.path.join(desktop_dir, item)
                        
                        # Check if it's a brew formula (most Linux apps would be formulae)
                        is_brew_formula = app_name.lower() in [f.lower() for f in self.brew_formulae]
                        
                        apps.append(AppInfo(
                            name=app_name,
                            path=full_path,
                            is_brew=is_brew_formula,
                            brew_type='formula' if is_brew_formula else None
                        ))
        
        return apps

    def check_brew_equivalents(self, apps: List[AppInfo]):
        """Check for brew equivalents of non-brew apps."""
        self.print_colored("Checking for brew equivalents...", 'info', self.emojis['search'])
        
        for app in apps:
            if not app.is_brew:
                # Simple name matching - could be enhanced with API calls
                app_name_lower = app.name.lower().replace(' ', '-')
                
                # Check casks first (more likely for GUI apps)
                for cask in self.brew_casks:
                    if (cask.lower() == app_name_lower or 
                        cask.lower().replace('-', '') == app_name_lower.replace('-', '') or
                        app_name_lower in cask.lower() or cask.lower() in app_name_lower):
                        app.has_brew_equivalent = True
                        app.brew_equivalent = cask
                        break
                
                # Check formulae if no cask found
                if not app.has_brew_equivalent:
                    for formula in self.brew_formulae:
                        if (formula.lower() == app_name_lower or 
                            formula.lower().replace('-', '') == app_name_lower.replace('-', '') or
                            app_name_lower in formula.lower() or formula.lower() in app_name_lower):
                            app.has_brew_equivalent = True
                            app.brew_equivalent = formula
                            break
                
                if not app.has_brew_equivalent:
                    app.has_brew_equivalent = False

    def display_menu(self, options: List[str], title: str = "Menu"):
        """Display an interactive menu with arrow key navigation."""
        while True:
            self.clear_screen()
            self.print_header(title)
            
            for i, option in enumerate(options):
                if i == self.current_selection:
                    print(f"{self.colors['selection']} > {option} < {Style.RESET_ALL}")
                else:
                    print(f"{self.colors['normal']}   {option}{Style.RESET_ALL}")
            
            print(f"\n{self.colors['dim']}Use ↑↓ arrow keys to navigate, Enter to select, Esc to exit{Style.RESET_ALL}")
            
            # Get key input
            key = keyboard.read_event(suppress=True)
            if key.event_type == keyboard.KEY_DOWN:
                if key.name == 'up':
                    self.current_selection = (self.current_selection - 1) % len(options)
                elif key.name == 'down':
                    self.current_selection = (self.current_selection + 1) % len(options)
                elif key.name == 'enter':
                    return self.current_selection
                elif key.name == 'esc':
                    return -1

    def display_app_details(self, app: AppInfo):
        """Display detailed information about an app."""
        self.clear_screen()
        self.print_header(f"App Details: {app.name}")
        
        print(f"{self.colors['info']}📱 Name:{Style.RESET_ALL} {app.name}")
        print(f"{self.colors['info']}📁 Path:{Style.RESET_ALL} {app.path}")
        
        if app.is_brew:
            print(f"{self.colors['success']}{self.emojis['brew']} Brew Package:{Style.RESET_ALL} Yes ({app.brew_type})")
        else:
            print(f"{self.colors['warning']}{self.emojis['cross']} Brew Package:{Style.RESET_ALL} No")
            
            if app.has_brew_equivalent:
                print(f"{self.colors['success']}{self.emojis['check']} Brew Equivalent:{Style.RESET_ALL} {app.brew_equivalent}")
                print(f"{self.colors['info']}💡 Suggestion:{Style.RESET_ALL} Consider installing via brew for better management")
            elif app.has_brew_equivalent is False:
                print(f"{self.colors['warning']}{self.emojis['cross']} Brew Equivalent:{Style.RESET_ALL} Not found")
            else:
                print(f"{self.colors['dim']}❓ Brew Equivalent:{Style.RESET_ALL} Not checked")
        
        print(f"\n{self.colors['dim']}Press any key to continue...{Style.RESET_ALL}")
        keyboard.read_event(suppress=True)

    def run_scan(self):
        """Run the complete application scan."""
        self.print_colored("Starting application scan...", 'info', self.emojis['rocket'])
        
        if not self.get_brew_packages():
            return False
        
        # Detect OS and get applications
        if sys.platform == 'darwin':
            self.installed_apps = self.get_applications_macos()
            self.print_colored(f"Found {len(self.installed_apps)} macOS applications", 'success', self.emojis['app'])
        elif sys.platform.startswith('linux'):
            self.installed_apps = self.get_applications_linux()
            self.print_colored(f"Found {len(self.installed_apps)} Linux applications", 'success', self.emojis['app'])
        else:
            self.print_colored("Unsupported operating system", 'error', self.emojis['cross'])
            return False
        
        self.check_brew_equivalents(self.installed_apps)
        return True

    def show_summary(self):
        """Show a summary of the scan results."""
        self.clear_screen()
        self.print_header("Scan Summary")
        
        brew_apps = [app for app in self.installed_apps if app.is_brew]
        non_brew_apps = [app for app in self.installed_apps if not app.is_brew]
        has_equivalent = [app for app in non_brew_apps if app.has_brew_equivalent]
        
        print(f"{self.colors['success']}{self.emojis['check']} Total Applications: {len(self.installed_apps)}")
        print(f"{self.colors['info']}{self.emojis['brew']} Brew Managed: {len(brew_apps)}")
        print(f"{self.colors['warning']}{self.emojis['cross']} Non-Brew: {len(non_brew_apps)}")
        print(f"{self.colors['success']}{self.emojis['check']} Has Brew Equivalent: {len(has_equivalent)}")
        
        if has_equivalent:
            print(f"\n{self.colors['header']}Apps with Brew Equivalents:{Style.RESET_ALL}")
            for app in has_equivalent:
                print(f"  {self.colors['info']}• {app.name}{Style.RESET_ALL} → {self.colors['success']}{app.brew_equivalent}{Style.RESET_ALL}")

    def main_menu(self):
        """Display the main menu and handle user interaction."""
        while True:
            options = [
                f"{self.emojis['search']} Run Application Scan",
                f"{self.emojis['info']} View Scan Summary",
                f"{self.emojis['app']} Browse All Applications",
                f"{self.emojis['brew']} View Brew-Managed Apps",
                f"{self.emojis['warning']} View Non-Brew Apps",
                f"{self.emojis['check']} View Apps with Brew Equivalents",
                f"{self.emojis['gear']} Export Results to JSON",
                f"{self.emojis['back']} Exit"
            ]
            
            self.current_selection = 0
            choice = self.display_menu(options, "Brew Scanner - Main Menu")
            
            if choice == -1 or choice == 7:  # Exit
                self.print_colored("Goodbye! 👋", 'info', self.emojis['back'])
                break
            elif choice == 0:  # Run scan
                if self.run_scan():
                    self.print_colored("Scan completed successfully!", 'success', self.emojis['check'])
                    time.sleep(2)
            elif choice == 1:  # View summary
                if self.installed_apps:
                    self.show_summary()
                    print(f"\n{self.colors['dim']}Press any key to continue...{Style.RESET_ALL}")
                    keyboard.read_event(suppress=True)
                else:
                    self.print_colored("No scan data available. Run a scan first.", 'warning', self.emojis['warning'])
                    time.sleep(2)
            elif choice >= 2 and choice <= 6:  # Browse options
                self.browse_applications(choice)

    def browse_applications(self, filter_type: int):
        """Browse applications with different filters."""
        if not self.installed_apps:
            self.print_colored("No scan data available. Run a scan first.", 'warning', self.emojis['warning'])
            time.sleep(2)
            return
        
        # Filter applications based on choice
        if filter_type == 2:  # All applications
            apps = self.installed_apps
            title = "All Applications"
        elif filter_type == 3:  # Brew-managed
            apps = [app for app in self.installed_apps if app.is_brew]
            title = "Brew-Managed Applications"
        elif filter_type == 4:  # Non-brew
            apps = [app for app in self.installed_apps if not app.is_brew]
            title = "Non-Brew Applications"
        elif filter_type == 5:  # Has brew equivalents
            apps = [app for app in self.installed_apps if not app.is_brew and app.has_brew_equivalent]
            title = "Applications with Brew Equivalents"
        elif filter_type == 6:  # Export to JSON
            self.export_to_json()
            return
        
        if not apps:
            self.print_colored("No applications found for this filter.", 'info', self.emojis['info'])
            time.sleep(2)
            return
        
        # Create menu options from apps
        app_options = []
        for app in apps:
            status = ""
            if app.is_brew:
                status = f" {self.emojis['brew']}"
            elif app.has_brew_equivalent:
                status = f" {self.emojis['check']}"
            else:
                status = f" {self.emojis['cross']}"
            
            app_options.append(f"{app.name}{status}")
        
        app_options.append(f"{self.emojis['back']} Back to Main Menu")
        
        self.current_selection = 0
        while True:
            choice = self.display_menu(app_options, title)
            
            if choice == -1 or choice == len(app_options) - 1:  # Back
                break
            elif 0 <= choice < len(apps):
                self.display_app_details(apps[choice])

    def export_to_json(self):
        """Export scan results to JSON file."""
        if not self.installed_apps:
            self.print_colored("No scan data available. Run a scan first.", 'warning', self.emojis['warning'])
            time.sleep(2)
            return
        
        # Convert apps to dictionary for JSON serialization
        apps_data = []
        for app in self.installed_apps:
            apps_data.append({
                'name': app.name,
                'path': app.path,
                'is_brew': app.is_brew,
                'brew_type': app.brew_type,
                'has_brew_equivalent': app.has_brew_equivalent,
                'brew_equivalent': app.brew_equivalent
            })
        
        # Create export data
        export_data = {
            'scan_timestamp': time.strftime('%Y-%m-%d %H:%M:%S'),
            'total_apps': len(self.installed_apps),
            'brew_managed': len([app for app in self.installed_apps if app.is_brew]),
            'has_brew_equivalent': len([app for app in self.installed_apps if not app.is_brew and app.has_brew_equivalent]),
            'applications': apps_data
        }
        
        # Write to file
        filename = f"brew_scan_results_{time.strftime('%Y%m%d_%H%M%S')}.json"
        try:
            with open(filename, 'w') as f:
                json.dump(export_data, f, indent=2)
            self.print_colored(f"Results exported to {filename}", 'success', self.emojis['check'])
        except Exception as e:
            self.print_colored(f"Error exporting results: {e}", 'error', self.emojis['cross'])
        
        time.sleep(2)

def main():
    """Main function to run the Brew Scanner application."""
    try:
        scanner = BrewScanner()
        scanner.main_menu()
    except KeyboardInterrupt:
        print(f"\n{Fore.YELLOW}⚠️  Operation cancelled by user{Style.RESET_ALL}")
    except Exception as e:
        print(f"\n{Fore.RED}❌ An error occurred: {e}{Style.RESET_ALL}")

if __name__ == "__main__":
    main() 