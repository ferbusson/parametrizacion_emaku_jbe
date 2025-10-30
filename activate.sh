#!/bin/bash

# Quick activation script for the XML sync environment
# Usage: source activate.sh

if [ ! -d "venv" ]; then
    echo "❌ Virtual environment not found. Run ./setup.sh first."
    return 1
fi

echo "🔄 Activating XML sync environment..."
source venv/bin/activate

if [ $? -eq 0 ]; then
    echo "✅ Environment activated!"
    echo ""
    echo "📋 Available commands:"
    echo "• python xml_db_sync.py test         - Test database connection"
    echo "• python xml_db_sync.py list         - List all records"
    echo "• python xml_db_sync.py sync -f FILE - Sync XML file"
    echo "• deactivate                         - Exit virtual environment"
    echo ""
else
    echo "❌ Failed to activate environment"
    return 1
fi