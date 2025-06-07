"""Main CLI interface for Brew Manager."""

import sys
from pathlib import Path
from typing import Optional

import click
from rich.console import Console
from rich.panel import Panel
from rich.table import Table

from ..core.config import Config, TemplateConfig
from ..core.template_generator import TemplateGenerator
from ..core.scanner import BrewScanner
from ..core.manager import BrewManager


console = Console()


def print_banner():
    """Print the application banner."""
    banner = """
    ██████  ██████  ███████ ██     ██ 
    ██   ██ ██   ██ ██      ██     ██ 
    ██████  ██████  █████   ██  █  ██ 
    ██   ██ ██   ██ ██      ██ ███ ██ 
    ██████  ██   ██ ███████  ███ ███  
    
    ███    ███  █████  ███    ██  █████   ██████  ███████ ██████  
    ████  ████ ██   ██ ████   ██ ██   ██ ██       ██      ██   ██ 
    ██ ████ ██ ███████ ██ ██  ██ ███████ ██   ███ █████   ██████  
    ██  ██  ██ ██   ██ ██  ██ ██ ██   ██ ██    ██ ██      ██   ██ 
    ██      ██ ██   ██ ██   ████ ██   ██  ██████  ███████ ██   ██ 
    """
    
    panel = Panel(
        banner,
        title="🍺 Professional Homebrew Package Management 🍺",
        title_align="center",
        border_style="cyan",
        padding=(1, 2)
    )
    console.print(panel)


@click.group(invoke_without_command=True)
@click.option('--config', '-c', type=click.Path(exists=True), help='Path to config file')
@click.option('--verbose', '-v', is_flag=True, help='Enable verbose output')
@click.version_option(version="1.0.0", prog_name="Brew Manager")
@click.pass_context
def main(ctx: click.Context, config: Optional[str], verbose: bool):
    """
    🍺 Brew Manager - Professional Homebrew Package Management
    
    A comprehensive solution for managing Homebrew packages with VM template
    generation capabilities and professional Python best practices.
    """
    # Set up context
    ctx.ensure_object(dict)
    ctx.obj['verbose'] = verbose
    
    # Load configuration
    config_path = Path(config) if config else None
    ctx.obj['config'] = Config.load_from_file(config_path)
    
    # If no command is specified, show the interactive menu
    if ctx.invoked_subcommand is None:
        print_banner()
        show_interactive_menu(ctx.obj['config'])


def show_interactive_menu(config: Config):
    """Show the interactive main menu."""
    while True:
        console.print("\n" + "="*60)
        console.print("🍺 [bold cyan]Brew Manager - Main Menu[/bold cyan] 🍺", justify="center")
        console.print("="*60)
        
        options = [
            ("1", "📦 Manage Local Packages", "Install, update, or remove packages"),
            ("2", "🔍 Scan Applications", "Find brew equivalents for installed apps"),
            ("3", "📋 Generate VM Templates", "Create installation scripts for VMs"),
            ("4", "💾 Create Drive Package", "Package scripts for USB drives"),
            ("5", "⚙️  Configure Templates", "Manage package templates"),
            ("6", "📊 Show Status", "Display system and package information"),
            ("7", "❓ Help", "Show detailed help information"),
            ("q", "🚪 Exit", "Quit the application")
        ]
        
        table = Table(show_header=False, box=None, padding=(0, 2))
        table.add_column("Choice", style="bold cyan", width=3)
        table.add_column("Action", style="bold white", width=25)
        table.add_column("Description", style="dim", width=30)
        
        for choice, action, desc in options:
            table.add_row(choice, action, desc)
        
        console.print(table)
        console.print()
        
        choice = console.input("Enter your choice: ").strip().lower()
        
        if choice == "q":
            console.print("\n👋 [green]Goodbye![/green]")
            break
        elif choice == "1":
            handle_package_management(config)
        elif choice == "2":
            handle_scanner(config)
        elif choice == "3":
            handle_template_generation(config)
        elif choice == "4":
            handle_drive_package(config)
        elif choice == "5":
            handle_configuration(config)
        elif choice == "6":
            handle_status(config)
        elif choice == "7":
            show_help()
        else:
            console.print("[red]❌ Invalid choice. Please try again.[/red]")


def handle_package_management(config: Config):
    """Handle package management operations."""
    manager = BrewManager(config)
    
    console.print("\n📦 [bold]Package Management[/bold]")
    actions = [
        ("1", "Install essential packages"),
        ("2", "Update all packages"),
        ("3", "Clean up unused packages"),
        ("4", "Show installed packages"),
        ("b", "Back to main menu")
    ]
    
    for choice, desc in actions:
        console.print(f"{choice}. {desc}")
    
    choice = console.input("\nChoose action: ").strip()
    
    if choice == "1":
        manager.install_essentials()
    elif choice == "2":
        manager.update_all()
    elif choice == "3":
        manager.cleanup()
    elif choice == "4":
        manager.show_installed()


def handle_scanner(config: Config):
    """Handle application scanning."""
    scanner = BrewScanner(config)
    
    console.print("\n🔍 [bold]Application Scanner[/bold]")
    console.print("Scanning for installed applications and brew equivalents...")
    
    results = scanner.scan_system()
    scanner.display_results(results)


def handle_template_generation(config: Config):
    """Handle VM template generation."""
    generator = TemplateGenerator(config)
    
    console.print("\n📋 [bold]VM Template Generation[/bold]")
    
    templates = list(config.templates.keys())
    if not templates:
        console.print("[yellow]⚠️  No templates configured.[/yellow]")
        return
    
    console.print("Available templates:")
    for i, template in enumerate(templates, 1):
        console.print(f"{i}. {template}")
    console.print(f"{len(templates) + 1}. Generate all templates")
    
    try:
        choice = int(console.input("\nChoose template to generate: "))
        if 1 <= choice <= len(templates):
            template_name = templates[choice - 1]
            script_path = generator.generate_script(template_name)
            console.print(f"✅ Generated: {script_path}")
        elif choice == len(templates) + 1:
            scripts = generator.generate_all_templates()
            console.print(f"✅ Generated {len(scripts)} templates")
    except (ValueError, KeyboardInterrupt):
        console.print("[yellow]Operation cancelled.[/yellow]")


def handle_drive_package(config: Config):
    """Handle USB drive package creation."""
    generator = TemplateGenerator(config)
    
    console.print("\n💾 [bold]Create Drive Package[/bold]")
    
    drive_path = console.input("Enter USB drive path (or press Enter for ~/Desktop): ").strip()
    if not drive_path:
        drive_path = Path.home() / "Desktop"
    else:
        drive_path = Path(drive_path)
    
    if not drive_path.exists():
        console.print(f"[red]❌ Path does not exist: {drive_path}[/red]")
        return
    
    try:
        package_dir = generator.create_drive_package(drive_path)
        console.print(f"✅ [green]Drive package created: {package_dir}[/green]")
    except Exception as e:
        console.print(f"[red]❌ Error creating package: {e}[/red]")


def handle_configuration(config: Config):
    """Handle template configuration."""
    console.print("\n⚙️  [bold]Template Configuration[/bold]")
    # Implementation would go here - showing templates, editing, etc.
    console.print("[yellow]Configuration interface coming soon...[/yellow]")


def handle_status(config: Config):
    """Handle status display."""
    console.print("\n📊 [bold]System Status[/bold]")
    # Implementation would go here - system info, package counts, etc.
    console.print("[yellow]Status display coming soon...[/yellow]")


def show_help():
    """Show detailed help information."""
    help_text = """
🍺 [bold cyan]Brew Manager Help[/bold cyan]

[bold white]What is Brew Manager?[/bold white]
A professional tool for managing Homebrew packages with VM template generation.

[bold white]Key Features:[/bold white]
• 📦 Local package management (install, update, clean)
• 🔍 Application scanning to find brew equivalents  
• 📋 VM template generation for new environments
• 💾 USB drive package creation for offline installs
• ⚙️  Configurable package templates
• 🎯 Professional Python architecture and best practices

[bold white]Templates:[/bold white]
• [green]Minimal[/green]: Essential tools only
• [blue]Development[/blue]: Coding environment setup
• [magenta]Full[/green]: Complete productivity setup

[bold white]CLI Commands:[/bold white]
• `brew-manager` or `bm` - Start interactive mode
• `brew-manager generate --help` - See generation options
• `brew-manager scan --help` - See scanning options

[bold white]Configuration:[/bold white]
Config files are stored in: ~/.config/brew-manager/
Templates are stored in: ~/.config/brew-manager/templates/
Output scripts go to: ~/Documents/brew-scripts/
"""
    
    panel = Panel(help_text, title="Help", border_style="blue")
    console.print(panel)


# CLI Commands for non-interactive use
@main.command()
@click.argument('template_name')
@click.option('--output', '-o', type=click.Path(), help='Output file path')
@click.pass_context  
def generate(ctx: click.Context, template_name: str, output: Optional[str]):
    """Generate a VM installation script from a template."""
    config = ctx.obj['config']
    generator = TemplateGenerator(config)
    
    output_path = Path(output) if output else None
    
    try:
        script_path = generator.generate_script(template_name, output_path)
        console.print(f"✅ Generated script: {script_path}")
    except ValueError as e:
        console.print(f"❌ {e}", style="red")
        sys.exit(1)


@main.command()
@click.option('--export', '-e', type=click.Path(), help='Export results to JSON file')
@click.pass_context
def scan(ctx: click.Context, export: Optional[str]):
    """Scan system for applications and brew equivalents."""
    config = ctx.obj['config']
    scanner = BrewScanner(config)
    
    console.print("🔍 Scanning system...")
    results = scanner.scan_system()
    scanner.display_results(results)
    
    if export:
        scanner.export_results(results, Path(export))
        console.print(f"✅ Results exported to: {export}")


@main.command()
@click.argument('drive_path', type=click.Path(exists=True))
@click.pass_context
def package(ctx: click.Context, drive_path: str):
    """Create a complete package for USB drive installation."""
    config = ctx.obj['config']
    generator = TemplateGenerator(config)
    
    try:
        package_dir = generator.create_drive_package(Path(drive_path))
        console.print(f"✅ Drive package created: {package_dir}")
    except Exception as e:
        console.print(f"❌ Error: {e}", style="red")
        sys.exit(1)


if __name__ == "__main__":
    main() 