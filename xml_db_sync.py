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
    
    def _backup_current_record(self, codigo, column="perfil"):
        """Backup current database record before updating."""
        if not self.config.get('backup_enabled', True):
            return None
        
        conn = self._get_connection()
        if not conn:
            return None
        
        try:
            cursor = conn.cursor()
            cursor.execute(
                f"SELECT {column} FROM {self.config['table']} WHERE codigo = %s",
                (codigo,)
            )
            result = cursor.fetchone()
            
            if result and result[0]:
                backup_dir = Path(self.config.get('backup_directory', './backups'))
                backup_dir.mkdir(exist_ok=True)
                
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                backup_file = backup_dir / f"{codigo}_{column}_backup_{timestamp}.xml"
                
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
        
        #if '<FORM>' not in xml_content:
        #   return False, "XML doesn't contain expected <FORM> element"
        
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
        
        # Auto-detect codigo and column from filename if not provided
        filename = xml_path.stem  # Gets filename without extension
        
        # Determine target column based on filename suffix
        target_column = "perfil"  # default
        if filename.endswith("_args_driver"):
            target_column = "args_driver"
            # Remove suffix to get codigo
            codigo_from_file = filename[:-12]  # Remove "_args_driver"
        elif filename.endswith("_perfil"):
            target_column = "perfil"
            # Remove suffix to get codigo
            codigo_from_file = filename[:-7]   # Remove "_perfil"
        else:
            # No recognized suffix, assume entire filename is codigo and default to perfil
            codigo_from_file = filename
        
        if not codigo:
            codigo = codigo_from_file
            print(f"🔍 Auto-detected codigo: {codigo}")
        
        print(f"🎯 Target column: {target_column}")
        
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
            backup_file = self._backup_current_record(codigo, target_column)
            
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
                        f"UPDATE {self.config['table']} SET {target_column} = %s WHERE codigo = %s",
                        (xml_content, codigo)
                    )
                    print(f"📝 Updated existing record for codigo: {codigo} (column: {target_column})")
                else:
                    # Insert new record - determine which columns to populate
                    if target_column == "perfil":
                        cursor.execute(
                            f"INSERT INTO {self.config['table']} (codigo, perfil) VALUES (%s, %s)",
                            (codigo, xml_content)
                        )
                    else:  # args_driver
                        cursor.execute(
                            f"INSERT INTO {self.config['table']} (codigo, args_driver) VALUES (%s, %s)",
                            (codigo, xml_content)
                        )
                    print(f"➕ Created new record for codigo: {codigo} (column: {target_column})")
                
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
    
    def get_next_codigo(self, prefix):
        """
        Get the next codigo value for a given prefix.
        
        Args:
            prefix: Codigo prefix (e.g., 'JBTR0')
            
        Returns:
            Next codigo string (e.g., 'JBTR00007')
        """
        conn = self._get_connection()
        if not conn:
            return None
        
        try:
            cursor = conn.cursor()
            
            # Query for max codigo with the given prefix
            cursor.execute(
                f"SELECT MAX(codigo) AS codigo FROM {self.config['table']} WHERE codigo LIKE %s",
                (f"{prefix}%",)
            )
            result = cursor.fetchone()
            max_codigo = result[0] if result and result[0] else None
            
            if max_codigo:
                # Extract the numeric part and increment
                try:
                    # Find the position where numbers start after the prefix
                    numeric_part = max_codigo[len(prefix):]
                    # Extract leading zeros and number
                    num_str = numeric_part.lstrip('0') or '0'
                    next_num = int(num_str) + 1
                    
                    # Calculate padding based on original format
                    original_length = len(numeric_part)
                    next_codigo = f"{prefix}{next_num:0{original_length}d}"
                    
                    print(f"🔍 Found max codigo: {max_codigo}")
                    print(f"➡️  Next codigo: {next_codigo}")
                    
                    return next_codigo
                    
                except (ValueError, IndexError) as e:
                    print(f"⚠️  Error parsing codigo format: {e}")
                    # Fallback: assume 5-digit format
                    return f"{prefix}00001"
            else:
                # No existing records with this prefix
                print(f"🆕 No existing records with prefix '{prefix}'")
                return f"{prefix}00001"
                
        except Exception as e:
            print(f"❌ Error getting next codigo: {e}")
            return None
        finally:
            conn.close()
    
    def _prompt_for_input(self, prompt, default=None, required=True):
        """Helper method to prompt user for input with validation."""
        while True:
            if default:
                user_input = input(f"{prompt} [{default}]: ").strip()
                if not user_input:
                    return default
            else:
                user_input = input(f"{prompt}: ").strip()
            
            if user_input or not required:
                return user_input
            
            print("⚠️  This field is required. Please enter a value.")
    
    def _get_user_inputs(self, prefix=None):
        """
        Prompt user for transaction creation inputs.
        
        Args:
            prefix: Optional prefix from command line
            
        Returns:
            Tuple of (prefix, nombre, descripcion)
        """
        print("\n📝 Creating new transaction...")
        print("=" * 50)
        
        # Get prefix
        if not prefix:
            print("\n1️⃣  Enter the codigo prefix (e.g., 'JBTR0' for JBTR00001, JBTR00002, etc.)")
            prefix = self._prompt_for_input("Codigo prefix", "JBTR0")
        
        # Get nombre
        print(f"\n2️⃣  Enter the transaction name (nombre)")
        nombre = self._prompt_for_input("Transaction name")
        
        # Get descripcion
        print(f"\n3️⃣  Enter the transaction description (descripcion)")
        print(f"💡 Press Enter to use the same value as nombre: '{nombre}'")
        descripcion = self._prompt_for_input("Transaction description", default=nombre, required=False)
        
        return prefix, nombre, descripcion
    
    def create_new_transaction(self, prefix=None):
        """
        Create a new transaction record in the database.
        
        Args:
            prefix: Optional codigo prefix from command line
            
        Returns:
            Boolean indicating success
        """
        
        # Get user inputs
        prefix, nombre, descripcion = self._get_user_inputs(prefix)
        
        # Get next codigo
        next_codigo = self.get_next_codigo(prefix)
        if not next_codigo:
            print("❌ Could not generate next codigo")
            return False
        
        # Default values for the transaction
        driver = "server.businessrules.LNDocuments"
        args_driver = "<container />"
        perfil = "<FORM />"
        
        # Show confirmation
        print(f"\n📋 Transaction to be created:")
        print("=" * 50)
        print(f"📍 Codigo:      {next_codigo}")
        print(f"📝 Nombre:      {nombre}")
        print(f"📄 Descripcion: {descripcion}")
        print(f"⚙️  Driver:      {driver}")
        print(f"🔧 Args Driver: {args_driver}")
        print(f"📊 Perfil:      {perfil}")
        print("=" * 50)
        
        # Confirmation prompt
        confirm = input("\n❓ Do you want to create this transaction? (y/N): ").strip().lower()
        if confirm not in ['y', 'yes']:
            print("❌ Operation cancelled by user")
            return False
        
        # Insert into database
        conn = self._get_connection()
        if not conn:
            return False
        
        try:
            cursor = conn.cursor()
            
            # Check if codigo already exists (safety check)
            cursor.execute(
                f"SELECT codigo FROM {self.config['table']} WHERE codigo = %s",
                (next_codigo,)
            )
            
            if cursor.fetchone():
                print(f"❌ Codigo {next_codigo} already exists!")
                return False
            
            # Insert new transaction
            insert_query = f"""
                INSERT INTO {self.config['table']} (
                    codigo,
                    nombre,
                    descripcion,
                    driver,
                    args_driver,
                    perfil
                ) VALUES (%s, %s, %s, %s, %s, %s)
            """
            
            cursor.execute(insert_query, (
                next_codigo,
                nombre,
                descripcion,
                driver,
                args_driver,
                perfil
            ))
            
            # Commit changes
            conn.commit()
            
            print(f"✅ Successfully created transaction: {next_codigo}")
            print(f"📊 Record created in table: {self.config['table']}")
            
            # Verify creation
            cursor.execute(
                f"SELECT codigo, nombre FROM {self.config['table']} WHERE codigo = %s",
                (next_codigo,)
            )
            result = cursor.fetchone()
            if result:
                print(f"✅ Verification: Record exists - {result[0]}: {result[1]}")
            
            return True
            
        except psycopg2.Error as e:
            print(f"❌ Database error: {e}")
            conn.rollback()
            return False
        except Exception as e:
            print(f"❌ Error creating transaction: {e}")
            conn.rollback()
            return False
        finally:
            conn.close()


def main():
    """Main function for command line usage."""
    
    parser = argparse.ArgumentParser(description="Sync XML files to PostgreSQL database")
    parser.add_argument('action', choices=['sync', 'test', 'list', 'config', 'create'], 
                       help='Action to perform')
    parser.add_argument('--file', '-f', help='XML file path to sync')
    parser.add_argument('--codigo', '-c', help='Database codigo value (auto-detected if not provided)')
    parser.add_argument('--prefix', '-p', help='Codigo prefix for creating new transactions (e.g., JBTR0)')
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
    
    elif args.action == 'create':
        success = sync_tool.create_new_transaction(args.prefix)
        sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()