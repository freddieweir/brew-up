"""Configuration management for Brew Manager."""

import os
from pathlib import Path
from typing import Dict, List, Optional

import yaml
from pydantic import BaseModel, Field, validator


class PackageConfig(BaseModel):
    """Configuration for package lists."""
    
    essential_formulae: List[str] = Field(
        default=["git", "curl", "wget", "tree", "htop", "jq"],
        description="Essential CLI tools for all environments"
    )
    
    development_formulae: List[str] = Field(
        default=["node", "npm", "yarn", "docker", "docker-compose", "cmake"],
        description="Development tools"
    )
    
    essential_casks: List[str] = Field(
        default=["reminders-menubar"],
        description="Essential GUI applications"
    )
    
    development_casks: List[str] = Field(
        default=["visual-studio-code", "docker", "postman"],
        description="Development GUI applications"
    )
    
    productivity_casks: List[str] = Field(
        default=["alt-tab", "rectangle", "obsidian"],
        description="Productivity applications"
    )


class TemplateConfig(BaseModel):
    """Configuration for VM template generation."""
    
    name: str = Field(default="vm-setup", description="Template name")
    version: str = Field(default="1.0.0", description="Template version")
    include_development: bool = Field(default=False, description="Include development packages")
    include_productivity: bool = Field(default=False, description="Include productivity packages")
    custom_formulae: List[str] = Field(default=[], description="Additional formulae")
    custom_casks: List[str] = Field(default=[], description="Additional casks")


class Config(BaseModel):
    """Main configuration class for Brew Manager."""
    
    # Application settings
    app_name: str = Field(default="Brew Manager", description="Application name")
    version: str = Field(default="1.0.0", description="Application version")
    
    # Package configurations
    packages: PackageConfig = Field(default_factory=PackageConfig)
    
    # Template configurations
    templates: Dict[str, TemplateConfig] = Field(
        default_factory=lambda: {
            "minimal": TemplateConfig(
                name="minimal-vm",
                include_development=False,
                include_productivity=False
            ),
            "development": TemplateConfig(
                name="dev-vm", 
                include_development=True,
                include_productivity=False
            ),
            "full": TemplateConfig(
                name="full-vm",
                include_development=True,
                include_productivity=True
            )
        }
    )
    
    # Path configurations
    config_dir: Path = Field(
        default_factory=lambda: Path.home() / ".config" / "brew-manager"
    )
    templates_dir: Path = Field(
        default_factory=lambda: Path.home() / ".config" / "brew-manager" / "templates"
    )
    output_dir: Path = Field(
        default_factory=lambda: Path.home() / "Documents" / "brew-scripts"
    )
    
    @validator("config_dir", "templates_dir", "output_dir", pre=True)
    def ensure_path_type(cls, v):
        """Ensure paths are Path objects."""
        return Path(v) if not isinstance(v, Path) else v
    
    def ensure_directories(self) -> None:
        """Create necessary directories if they don't exist."""
        for directory in [self.config_dir, self.templates_dir, self.output_dir]:
            directory.mkdir(parents=True, exist_ok=True)
    
    @classmethod
    def load_from_file(cls, config_path: Optional[Path] = None) -> "Config":
        """Load configuration from YAML file."""
        if config_path is None:
            config_path = Path.home() / ".config" / "brew-manager" / "config.yaml"
        
        if config_path.exists():
            with open(config_path, "r") as f:
                data = yaml.safe_load(f)
                return cls(**data)
        else:
            # Create default config
            config = cls()
            config.save_to_file(config_path)
            return config
    
    def save_to_file(self, config_path: Optional[Path] = None) -> None:
        """Save configuration to YAML file."""
        if config_path is None:
            config_path = self.config_dir / "config.yaml"
        
        self.ensure_directories()
        
        with open(config_path, "w") as f:
            yaml.dump(
                self.dict(exclude={"config_dir", "templates_dir", "output_dir"}),
                f,
                default_flow_style=False,
                sort_keys=False
            )
    
    def get_template_config(self, template_name: str) -> Optional[TemplateConfig]:
        """Get configuration for a specific template."""
        return self.templates.get(template_name)
    
    def add_template(self, name: str, config: TemplateConfig) -> None:
        """Add a new template configuration."""
        self.templates[name] = config
    
    def get_all_packages(self, template_name: str) -> Dict[str, List[str]]:
        """Get all packages for a specific template."""
        template = self.get_template_config(template_name)
        if not template:
            return {"formulae": [], "casks": []}
        
        formulae = self.packages.essential_formulae.copy()
        casks = self.packages.essential_casks.copy()
        
        if template.include_development:
            formulae.extend(self.packages.development_formulae)
            casks.extend(self.packages.development_casks)
        
        if template.include_productivity:
            casks.extend(self.packages.productivity_casks)
        
        formulae.extend(template.custom_formulae)
        casks.extend(template.custom_casks)
        
        return {
            "formulae": list(set(formulae)),  # Remove duplicates
            "casks": list(set(casks))
        } 