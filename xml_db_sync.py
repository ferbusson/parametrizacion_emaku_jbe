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
    
    def retrieve_sql_query(self, codigo, output_directory="."):
        """
        Retrieve SQL query from sentencia_sql table and create a .sql file.
        
        Args:
            codigo: The codigo value to search for in sentencia_sql table
            output_directory: Directory where to create the .sql file (default: current directory)
            
        Returns:
            Boolean indicating success
        """
        
        if not codigo:
            print("❌ Codigo parameter is required")
            return False
        
        print(f"🔍 Searching for SQL query with codigo: {codigo}")
        
        # Connect to database
        conn = self._get_connection()
        if not conn:
            return False
        
        try:
            cursor = conn.cursor()
            
            # Query the sentencia_sql table
            cursor.execute(
                "SELECT codigo, sentencia FROM sentencia_sql WHERE codigo = %s",
                (codigo,)
            )
            
            result = cursor.fetchone()
            
            if not result:
                print(f"❌ No SQL query found for codigo: {codigo}")
                return False
            
            codigo_found, sql_content = result
            
            if not sql_content or not sql_content.strip():
                print(f"❌ Empty SQL content found for codigo: {codigo}")
                return False
            
            # Create output file path
            output_path = Path(output_directory) / f"{codigo}.sql"
            
            # Ensure output directory exists
            output_path.parent.mkdir(parents=True, exist_ok=True)
            
            # Write SQL content to file
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(sql_content)
            
            print(f"✅ Successfully retrieved SQL query for codigo: {codigo}")
            print(f"📁 Created file: {output_path}")
            print(f"📊 Content size: {len(sql_content)} characters")
            
            # Show first few lines of the SQL for verification
            lines = sql_content.strip().split('\n')
            preview_lines = min(3, len(lines))
            print(f"📝 Preview (first {preview_lines} lines):")
            for i in range(preview_lines):
                print(f"   {i+1}: {lines[i][:80]}{'...' if len(lines[i]) > 80 else ''}")
            
            if len(lines) > preview_lines:
                print(f"   ... ({len(lines)} total lines)")
            
            return True
            
        except psycopg2.Error as e:
            print(f"❌ Database error: {e}")
            return False
        except Exception as e:
            print(f"❌ Error retrieving SQL query: {e}")
            return False
        finally:
            conn.close()
    
    def update_sql_query(self, sql_file_path, codigo=None):
        """
        Update SQL query in sentencia_sql table from a .sql file.
        
        Args:
            sql_file_path: Path to the .sql file containing the query
            codigo: Database codigo value (auto-detected from filename if None)
            
        Returns:
            Boolean indicating success
        """
        
        sql_path = Path(sql_file_path)
        
        if not sql_path.exists():
            print(f"❌ File not found: {sql_file_path}")
            return False
        
        if not sql_path.suffix.lower() == '.sql':
            print(f"❌ File must have .sql extension: {sql_file_path}")
            return False
        
        # Auto-detect codigo from filename if not provided
        if not codigo:
            codigo = sql_path.stem  # Gets filename without .sql extension
            print(f"🔍 Auto-detected codigo from filename: {codigo}")
        
        try:
            # Read SQL content
            with open(sql_path, 'r', encoding='utf-8') as f:
                sql_content = f.read()
            
            if not sql_content.strip():
                print(f"❌ SQL file is empty: {sql_file_path}")
                return False
            
            print(f"📄 Read SQL content: {len(sql_content)} characters")
            
            # Show preview of content
            lines = sql_content.strip().split('\n')
            preview_lines = min(3, len(lines))
            print(f"📝 Content preview (first {preview_lines} lines):")
            for i in range(preview_lines):
                print(f"   {i+1}: {lines[i][:80]}{'...' if len(lines[i]) > 80 else ''}")
            
            if len(lines) > preview_lines:
                print(f"   ... ({len(lines)} total lines)")
            
            # Connect to database
            conn = self._get_connection()
            if not conn:
                return False
            
            try:
                cursor = conn.cursor()
                
                # Check if record exists in sentencia_sql table
                cursor.execute(
                    "SELECT codigo FROM sentencia_sql WHERE codigo = %s",
                    (codigo,)
                )
                
                exists = cursor.fetchone() is not None
                
                if exists:
                    # Update existing record
                    cursor.execute(
                        "UPDATE sentencia_sql SET sentencia = %s WHERE codigo = %s",
                        (sql_content, codigo)
                    )
                    print(f"📝 Updated existing SQL query for codigo: {codigo}")
                else:
                    # Insert new record
                    cursor.execute(
                        "INSERT INTO sentencia_sql (codigo, sentencia) VALUES (%s, %s)",
                        (codigo, sql_content)
                    )
                    print(f"➕ Created new SQL query record for codigo: {codigo}")
                
                # Commit changes
                conn.commit()
                
                print(f"✅ Successfully updated sentencia_sql table")
                print(f"📊 Record: {codigo} in table sentencia_sql")
                
                # Verify update
                cursor.execute(
                    "SELECT LENGTH(sentencia) as content_length FROM sentencia_sql WHERE codigo = %s",
                    (codigo,)
                )
                result = cursor.fetchone()
                if result:
                    print(f"✅ Verification: Content length in database: {result[0]} characters")
                
                return True
                
            except psycopg2.Error as e:
                print(f"❌ Database error: {e}")
                conn.rollback()
                return False
            finally:
                conn.close()
                
        except Exception as e:
            print(f"❌ Error updating SQL query: {e}")
            return False
    
    def extract_xml_files(self, codigo, output_directory="."):
        """
        Extract both perfil and args_driver XML files from transacciones table.
        
        Args:
            codigo: The codigo value to search for in transacciones table
            output_directory: Directory where to create the XML files (default: current directory)
            
        Returns:
            Boolean indicating success
        """
        
        if not codigo:
            print("❌ Codigo parameter is required")
            return False
        
        print(f"🔍 Extracting XML files for codigo: {codigo}")
        
        # Connect to database
        conn = self._get_connection()
        if not conn:
            return False
        
        try:
            cursor = conn.cursor()
            
            # Query the transacciones table for both columns
            cursor.execute(
                f"SELECT codigo, perfil, args_driver FROM {self.config['table']} WHERE codigo = %s",
                (codigo,)
            )
            
            result = cursor.fetchone()
            
            if not result:
                print(f"❌ No transaction found for codigo: {codigo}")
                return False
            
            codigo_found, perfil_content, args_driver_content = result
            
            # Ensure output directory exists
            output_path = Path(output_directory)
            output_path.mkdir(parents=True, exist_ok=True)
            
            success_count = 0
            files_created = []
            
            # Extract perfil XML
            if perfil_content and perfil_content.strip():
                perfil_file = output_path / f"{codigo}_perfil.xml"
                
                try:
                    with open(perfil_file, 'w', encoding='utf-8') as f:
                        f.write(perfil_content)
                    
                    print(f"✅ Created perfil file: {perfil_file}")
                    print(f"   📊 Content size: {len(perfil_content)} characters")
                    
                    # Show preview
                    lines = perfil_content.strip().split('\n')
                    preview_lines = min(2, len(lines))
                    for i in range(preview_lines):
                        preview_line = lines[i][:60]
                        if len(lines[i]) > 60:
                            preview_line += "..."
                        print(f"   📝 Line {i+1}: {preview_line}")
                    
                    files_created.append(str(perfil_file))
                    success_count += 1
                    
                except Exception as e:
                    print(f"❌ Error writing perfil file: {e}")
            else:
                print(f"⚠️  No perfil content found for codigo: {codigo}")
            
            # Extract args_driver XML
            if args_driver_content and args_driver_content.strip():
                args_driver_file = output_path / f"{codigo}_args_driver.xml"
                
                try:
                    with open(args_driver_file, 'w', encoding='utf-8') as f:
                        f.write(args_driver_content)
                    
                    print(f"✅ Created args_driver file: {args_driver_file}")
                    print(f"   📊 Content size: {len(args_driver_content)} characters")
                    
                    # Show preview
                    lines = args_driver_content.strip().split('\n')
                    preview_lines = min(2, len(lines))
                    for i in range(preview_lines):
                        preview_line = lines[i][:60]
                        if len(lines[i]) > 60:
                            preview_line += "..."
                        print(f"   📝 Line {i+1}: {preview_line}")
                    
                    files_created.append(str(args_driver_file))
                    success_count += 1
                    
                except Exception as e:
                    print(f"❌ Error writing args_driver file: {e}")
            else:
                print(f"⚠️  No args_driver content found for codigo: {codigo}")
            
            # Summary
            if success_count > 0:
                print(f"\n🎉 Successfully extracted {success_count} XML file(s) for codigo: {codigo}")
                print(f"📁 Output directory: {output_path.absolute()}")
                print(f"📄 Files created:")
                for file_path in files_created:
                    print(f"   • {file_path}")
                return True
            else:
                print(f"❌ No XML files were created - no valid content found for codigo: {codigo}")
                return False
            
        except psycopg2.Error as e:
            print(f"❌ Database error: {e}")
            return False
        except Exception as e:
            print(f"❌ Error extracting XML files: {e}")
            return False
        finally:
            conn.close()
    
    def get_next_sql_codigo(self, prefix):
        """
        Get the next codigo value for SQL queries with a given prefix.
        
        Args:
            prefix: Codigo prefix (e.g., 'JBSEL' for JBSEL0001, JBSEL0002, etc.)
            
        Returns:
            Next codigo string (e.g., 'JBSEL0012')
        """
        conn = self._get_connection()
        if not conn:
            return None
        
        try:
            cursor = conn.cursor()
            
            # Query for max codigo with the given prefix from sentencia_sql table
            cursor.execute(
                "SELECT MAX(codigo) AS codigo FROM sentencia_sql WHERE codigo LIKE %s",
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
                    
                    # Calculate padding based on original format (4 digits for SQL queries)
                    original_length = len(numeric_part)
                    next_codigo = f"{prefix}{next_num:0{original_length}d}"
                    
                    print(f"🔍 Found max codigo: {max_codigo}")
                    print(f"➡️  Next codigo: {next_codigo}")
                    
                    return next_codigo
                    
                except (ValueError, IndexError) as e:
                    print(f"⚠️  Error parsing codigo format: {e}")
                    # Fallback: assume 4-digit format for SQL queries
                    return f"{prefix}0001"
            else:
                # No existing records with this prefix
                print(f"🆕 No existing records with prefix '{prefix}'")
                return f"{prefix}0001"
                
        except Exception as e:
            print(f"❌ Error getting next SQL codigo: {e}")
            return None
        finally:
            conn.close()
    
    def _get_sql_inputs(self, prefix=None):
        """
        Prompt user for SQL query creation inputs.
        
        Args:
            prefix: Optional prefix from command line
            
        Returns:
            Tuple of (prefix, nombre, descripcion)
        """
        print("\n📝 Creating new SQL query...")
        print("=" * 50)
        
        # Get prefix if not provided
        if not prefix:
            print("\n1️⃣  Enter the codigo prefix:")
            print("   Format: [Business][Nature] (e.g., 'JBSEL', 'LCUPD', 'ANINS', 'TBDEL')")
            print("   Business: 2 chars (JB, LC, AN, TB, etc.)")
            print("   Nature: SEL, UPD, INS, DEL")
            prefix = self._prompt_for_input("Codigo prefix (e.g., JBSEL)", required=True)
            
            # Convert to uppercase
            prefix = prefix.upper().strip()
            
            # Validate prefix format
            if len(prefix) < 5:
                print(f"⚠️  Warning: Prefix '{prefix}' is shorter than expected format (BusinessNature)")
                confirm = input("Continue anyway? (y/N): ").strip().lower()
                if confirm not in ['y', 'yes']:
                    print("❌ Operation cancelled")
                    return None, None, None
        else:
            prefix = prefix.upper().strip()
        
        # Get nombre
        print(f"\n2️⃣  Enter the query name (nombre)")
        print(f"   This will describe what the query does")
        nombre = self._prompt_for_input("Query name", required=True)
        
        # Get descripcion
        print(f"\n3️⃣  Enter the query description (descripcion)")
        print(f"💡 Press Enter to use the same value as nombre: '{nombre}'")
        descripcion = self._prompt_for_input("Query description", default=nombre, required=False)
        
        return prefix, nombre, descripcion
    
    def create_new_sql_query(self, prefix=None):
        """
        Create a new SQL query record in the sentencia_sql table.
        
        Args:
            prefix: Optional codigo prefix from command line
            
        Returns:
            Boolean indicating success
        """
        
        # Get user inputs
        inputs = self._get_sql_inputs(prefix)
        if inputs[0] is None:  # User cancelled
            return False
        
        prefix, nombre, descripcion = inputs
        
        # Get next codigo
        next_codigo = self.get_next_sql_codigo(prefix)
        if not next_codigo:
            print("❌ Could not generate next codigo")
            return False
        
        # Empty sentencia for initial creation
        sentencia = ""
        
        # Show confirmation
        print(f"\n📋 SQL Query to be created:")
        print("=" * 50)
        print(f"📍 Codigo:      {next_codigo}")
        print(f"📝 Nombre:      {nombre}")
        print(f"📄 Descripcion: {descripcion}")
        print(f"📊 Sentencia:   (empty - will be added later)")
        print("=" * 50)
        
        # Confirmation prompt
        confirm = input("\n❓ Do you want to create this SQL query? (y/N): ").strip().lower()
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
                "SELECT codigo FROM sentencia_sql WHERE codigo = %s",
                (next_codigo,)
            )
            
            if cursor.fetchone():
                print(f"❌ Codigo {next_codigo} already exists!")
                return False
            
            # Insert new SQL query
            insert_query = """
                INSERT INTO sentencia_sql (
                    codigo,
                    nombre,
                    descripcion,
                    sentencia
                ) VALUES (%s, %s, %s, %s)
            """
            
            cursor.execute(insert_query, (
                next_codigo,
                nombre,
                descripcion,
                sentencia
            ))
            
            # Commit changes
            conn.commit()
            
            print(f"✅ Successfully created SQL query: {next_codigo}")
            print(f"📊 Record created in table: sentencia_sql")
            print(f"💡 You can now edit the query content and use:")
            print(f"   python xml_db_sync.py update-sql --file {next_codigo}.sql")
            
            # Verify creation
            cursor.execute(
                "SELECT codigo, nombre FROM sentencia_sql WHERE codigo = %s",
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
            print(f"❌ Error creating SQL query: {e}")
            conn.rollback()
            return False
        finally:
            conn.close()


def main():
    """Main function for command line usage."""
    
    parser = argparse.ArgumentParser(description="Sync XML files to PostgreSQL database")
    parser.add_argument('action', choices=['sync', 'test', 'list', 'config', 'create', 'get-sql', 'update-sql', 'get-xml', 'insert-sql'], 
                       help='Action to perform')
    parser.add_argument('--file', '-f', help='File path (XML for sync, SQL for update-sql)')
    parser.add_argument('--codigo', '-c', help='Database codigo value (auto-detected if not provided)')
    parser.add_argument('--prefix', '-p', help='Codigo prefix for creating new transactions/queries (e.g., JBTR0, JBSEL)')
    parser.add_argument('--output', '-o', help='Output directory for get-sql/get-xml actions (default: current directory)')
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
    
    elif args.action == 'get-sql':
        if not args.codigo:
            print("❌ --codigo parameter is required for get-sql action")
            print("💡 Usage: python xml_db_sync.py get-sql --codigo LCSEL0857")
            sys.exit(1)
        
        output_dir = args.output or "."
        success = sync_tool.retrieve_sql_query(args.codigo, output_dir)
        sys.exit(0 if success else 1)
    
    elif args.action == 'update-sql':
        if not args.file:
            print("❌ --file parameter is required for update-sql action")
            print("💡 Usage: python xml_db_sync.py update-sql --file LCSEL0857.sql")
            sys.exit(1)
        
        success = sync_tool.update_sql_query(args.file, args.codigo)
        sys.exit(0 if success else 1)
    
    elif args.action == 'get-xml':
        if not args.codigo:
            print("❌ --codigo parameter is required for get-xml action")
            print("💡 Usage: python xml_db_sync.py get-xml --codigo JBTR00007")
            sys.exit(1)
        
        output_dir = args.output or "."
        success = sync_tool.extract_xml_files(args.codigo, output_dir)
        sys.exit(0 if success else 1)
    
    elif args.action == 'insert-sql':
        success = sync_tool.create_new_sql_query(args.prefix)
        sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()