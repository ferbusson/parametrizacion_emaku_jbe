#!/bin/bash

# Setup script for XML to Database sync automation

echo "🚀 Setting up XML to Database Sync Automation"
echo "=============================================="

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install it first."
    exit 1
fi

echo "✅ Python 3 found"

# Install required Python packages (PEP 668 compliant)
echo "📦 Setting up Python environment..."

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment (PEP 668 compliant)..."
    python3 -m venv venv
    
    if [ $? -eq 0 ]; then
        echo "✅ Virtual environment created successfully"
    else
        echo "❌ Failed to create virtual environment"
        exit 1
    fi
else
    echo "✅ Virtual environment already exists"
fi

# Activate virtual environment and install dependencies
echo "📦 Installing dependencies in virtual environment..."
source venv/bin/activate

pip install psycopg2-binary

if [ $? -eq 0 ]; then
    echo "✅ psycopg2-binary installed successfully in virtual environment"
else
    echo "❌ Failed to install psycopg2-binary"
    echo "💡 Try installing system dependencies first:"
    echo "💡 sudo apt-get install libpq-dev python3-dev"
    exit 1
fi

# Create backups directory
echo "📁 Creating backups directory..."
mkdir -p backups
echo "✅ Backups directory created"

# Make scripts executable
echo "🔧 Making scripts executable..."
chmod +x xml_db_sync.py
chmod +x setup.sh

# Test if the script runs
echo "🧪 Testing script..."
python xml_db_sync.py config

echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Edit db_config.json with your PostgreSQL credentials"
echo "2. Activate virtual environment: source venv/bin/activate"
echo "3. Test connection: python xml_db_sync.py test"
echo "4. Sync your first file: python xml_db_sync.py sync --file JBTR00004_perfil.xml"
echo ""
echo "⚠️  IMPORTANT: Always activate the virtual environment first:"
echo "   source venv/bin/activate"
echo ""
echo "🔧 VS Code Integration:"
echo "• Ctrl+Shift+D: Sync current XML file"
echo "• Ctrl+Shift+T: Test database connection"
echo "• Ctrl+Shift+L: List database records"
echo "• Command Palette: 'Tasks: Run Task' → choose sync option"
echo ""
echo "📁 Files created:"
echo "• xml_db_sync.py - Main sync script"
echo "• db_config.json - Database configuration"
echo "• .vscode/tasks.json - VS Code tasks"
echo "• .vscode/keybindings.json - Keyboard shortcuts"
echo "• backups/ - Backup directory"