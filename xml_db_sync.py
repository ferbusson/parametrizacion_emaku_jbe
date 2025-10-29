#!/usr/bin/env python3
"""
XML to PostgreSQL Database Sync Tool
Automatically syncs XML form definitions to the transacciones table
"""

import os
import sys
import psycopg2
import argparse
from datetime import datetime
from pathlib import Path
import json

class XMLDatabaseSync:
    def __init__(self, config_file="db_config.json"):
        """Initialize the sync tool with database configuration."""
        self.config_file = config_file
        self.config = self._load_config()
        
    def _load_config(self):
        """Load database configuration from JSON file."""
        config_path = Path(self.config_file)
        
        if not config_path.exists():
            # Create default config file
            default_config = {
                "database": {
                    "host": "localhost",
                    "port": 5432,
                    "database": "your_database_name",
                    "user": "your_username",
                    "password": "your_password"
                },
                "table": "transacciones",
                "backup_enabled": True,
                "backup_directory": "./backups"
            }
            
            with open(config_path, 'w') as f:
                json.dump(default_config, f, indent=2)
            
            print(f"📝 Created default config file: {config_path}")
            print("Please edit it with your database credentials.")
            return default_config
        
        with open(config_path, 'r') as f:
            return json.load(f)
    
    def _get_connection(self):
        """Create database connection."""
        try:
            db_config = self.config['database']
            conn = psycopg2.connect(
                host=db_config['host'],
                port=db_config['port'],
                database=db_config['database'],
                user=db_config['user'],
                password=db_config['password']
            )
            return conn
        except psycopg2.Error as e:
            print(f"❌ Database connection error: {e}")
            return None
    
    def _backup_current_record(self, codigo):
        """Backup current database record before updating."""
        if not self.config.get('backup_enabled', True):
            return None
        
        conn = self._get_connection()
        if not conn:
            return None
        
        try:
            cursor = conn.cursor()
            cursor.execute(
                f"SELECT perfil FROM {self.config['table']} WHERE codigo = %s",
                (codigo,)
            )
            result = cursor.fetchone()
            
            if result:
                backup_dir = Path(self.config.get('backup_directory', './backups'))
                backup_dir.mkdir(exist_ok=True)
                
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                backup_file = backup_dir / f"{codigo}_backup_{timestamp}.xml"
                
                with open(backup_file, 'w', encoding='utf-8') as f:
                    f.write(result[0])
                
                print(f"💾 Backup created: {backup_file}")
                return str(backup_file)
            
        except Exception as e:
            print(f"⚠️  Backup failed: {e}")
        finally:
            conn.close()
        
        return None
    
    def _validate_xml_content(self, xml_content):
        """Basic validation of XML content."""
        if not xml_content.strip():
            return False, "XML content is empty"
        
        if not xml_content.strip().startswith('<'):
            return False, "Content doesn't appear to be XML"
        
        if '<FORM>' not in xml_content:
            return False, "XML doesn't contain expected <FORM> element"
        
        return True, "XML validation passed"
    
    def sync_file_to_database(self, xml_file_path, codigo=None):
        """
        Sync XML file content to database.
        
        Args:
            xml_file_path: Path to the XML file
            codigo: Database codigo value (auto-detected if None)
        """
        
        xml_path = Path(xml_file_path)
        
        if not xml_path.exists():
            print(f"❌ File not found: {xml_file_path}")
            return False
        
        # Auto-detect codigo from filename if not provided
        if not codigo:
            codigo = xml_path.stem  # Gets filename without extension
            print(f"🔍 Auto-detected codigo: {codigo}")
        
        try:
            # Read XML content
            with open(xml_path, 'r', encoding='utf-8') as f:
                xml_content = f.read()
            
            # Validate XML content
            is_valid, message = self._validate_xml_content(xml_content)
            if not is_valid:
                print(f"❌ Validation failed: {message}")
                return False
            
            print(f"✅ XML validation passed")
            
            # Create backup
            backup_file = self._backup_current_record(codigo)
            
            # Connect to database
            conn = self._get_connection()
            if not conn:
                return False
            
            try:
                cursor = conn.cursor()
                
                # Check if record exists
                cursor.execute(
                    f"SELECT codigo FROM {self.config['table']} WHERE codigo = %s",
                    (codigo,)
                )
                
                exists = cursor.fetchone() is not None
                
                if exists:
                    # Update existing record
                    cursor.execute(
                        f"UPDATE {self.config['table']} SET perfil = %s WHERE codigo = %s",
                        (xml_content, codigo)
                    )
                    print(f"📝 Updated existing record for codigo: {codigo}")
                else:
                    # Insert new record
                    cursor.execute(
                        f"INSERT INTO {self.config['table']} (codigo, perfil) VALUES (%s, %s)",
                        (codigo, xml_content)
                    )
                    print(f"➕ Created new record for codigo: {codigo}")
                
                # Commit changes
                conn.commit()
                
                print(f"✅ Successfully synced {xml_file_path} to database")
                print(f"📊 Record: {codigo} in table {self.config['table']}")
                
                if backup_file:
                    print(f"💾 Backup available: {backup_file}")
                
                return True
                
            except psycopg2.Error as e:
                print(f"❌ Database error: {e}")
                conn.rollback()
                return False
            finally:
                conn.close()
                
        except Exception as e:
            print(f"❌ Error: {e}")
            return False
    
    def test_connection(self):
        """Test database connection."""
        print("🔄 Testing database connection...")
        
        conn = self._get_connection()
        if conn:
            try:
                cursor = conn.cursor()
                cursor.execute("SELECT version();")
                version = cursor.fetchone()[0]
                print(f"✅ Connected to PostgreSQL: {version}")
                
                # Test table access
                cursor.execute(f"SELECT COUNT(*) FROM {self.config['table']};")
                count = cursor.fetchone()[0]
                print(f"✅ Table '{self.config['table']}' accessible: {count} records")
                
                return True
            except Exception as e:
                print(f"❌ Connection test failed: {e}")
                return False
            finally:
                conn.close()
        
        return False
    
    def list_available_records(self):
        """List all available records in the transacciones table."""
        conn = self._get_connection()
        if not conn:
            return []
        
        try:
            cursor = conn.cursor()
            cursor.execute(f"SELECT codigo FROM {self.config['table']} ORDER BY codigo;")
            records = [row[0] for row in cursor.fetchall()]
            
            print(f"📋 Available records in {self.config['table']}:")
            for record in records:
                print(f"   • {record}")
            
            return records
            
        except Exception as e:
            print(f"❌ Error listing records: {e}")
            return []
        finally:
            conn.close()


def main():
    """Main function for command line usage."""
    
    parser = argparse.ArgumentParser(description="Sync XML files to PostgreSQL database")
    parser.add_argument('action', choices=['sync', 'test', 'list', 'config'], 
                       help='Action to perform')
    parser.add_argument('--file', '-f', help='XML file path to sync')
    parser.add_argument('--codigo', '-c', help='Database codigo value (auto-detected if not provided)')
    parser.add_argument('--config', help='Config file path (default: db_config.json)')
    
    args = parser.parse_args()
    
    # Initialize sync tool
    config_file = args.config or "db_config.json"
    sync_tool = XMLDatabaseSync(config_file)
    
    if args.action == 'config':
        print(f"📄 Config file: {config_file}")
        print(f"📄 Current configuration:")
        print(json.dumps(sync_tool.config, indent=2))
        return
    
    elif args.action == 'test':
        success = sync_tool.test_connection()
        sys.exit(0 if success else 1)
    
    elif args.action == 'list':
        sync_tool.list_available_records()
        return
    
    elif args.action == 'sync':
        if not args.file:
            print("❌ --file parameter is required for sync action")
            sys.exit(1)
        
        success = sync_tool.sync_file_to_database(args.file, args.codigo)
        sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()