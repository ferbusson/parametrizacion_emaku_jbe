# XML to Database Automation

## 🎯 Overview

This automation system eliminates the manual process of copying XML content from form definition files to your PostgreSQL database. Instead of manually copying and pasting XML content, you can now sync files with a single command or keyboard shortcut.

## 🔄 Your Automated Workflow

### Before (Manual):
1. Edit `JBTR00004_perfil.xml`
2. Copy entire XML content
3. Open database client
4. Execute: `UPDATE transacciones SET perfil = '<xml_content>' WHERE codigo = 'JBTR00004'`
5. Risk of errors, no backup, time-consuming

### After (Automated):
1. Edit `JBTR00004_perfil.xml`
2. Press `Ctrl+Shift+D` or run command
3. ✅ Done! (with automatic backup, validation, and error handling)

## 🚀 Quick Start

### 1. Setup (One-time)
```bash
chmod +x setup.sh
./setup.sh
```

### 2. Configure Database
Edit `db_config.json`:
```json
{
  "database": {
    "host": "localhost",
    "port": 5432,
    "database": "your_database_name",
    "user": "your_username", 
    "password": "your_password"
  }
}
```

### 3. Test Connection
```bash
python3 xml_db_sync.py test
```

### 4. Sync Your First File
```bash
python3 xml_db_sync.py sync --file transacciones/ventas/cotizaciones/JBTR00004_perfil.xml
```

## 🎮 Usage Methods

### Method 1: Keyboard Shortcuts (Fastest)
- **`Ctrl+Shift+D`** - Sync current XML file to database
- **`Ctrl+Shift+T`** - Test database connection
- **`Ctrl+Shift+L`** - List all database records

### Method 2: Command Palette
1. Press `Ctrl+Shift+P`
2. Type "Tasks: Run Task"
3. Choose:
   - "Sync XML to Database"
   - "Sync JBTR00004 (Cotizaciones)"
   - "Sync JBTR00001 (Pedidos)"
   - "Test Database Connection"

### Method 3: Command Line

#### New Convention (Recommended - Simpler)
The second parameter (file path or directory) no longer needs `-o` or `-f` flags:

```bash
# Sync XML file (second parameter is the file path)
python3 xml_db_sync.py sync path/to/file.xml

# Update SQL from file (second parameter is the file path)
python3 xml_db_sync.py update-sql LCSEL0857.sql

# Get SQL query and save to directory
# Note: For optional parameters mixed with flags, use --output or put directory at end
python3 xml_db_sync.py get-sql --codigo LCSEL0857 --output ./output_directory
# Or alternatively:
python3 xml_db_sync.py get-sql --codigo LCSEL0857 -o ./output_directory

# Get XML files and save to directory  
python3 xml_db_sync.py get-xml --codigo JBTR00007 --output ./exports
# Or alternatively:
python3 xml_db_sync.py get-xml --codigo JBTR00007 -o ./exports

# Test connection
python3 xml_db_sync.py test

# List all records
python3 xml_db_sync.py list
```

#### For Sync and Update-SQL (Positional Parameter)
These commands accept the second parameter as a positional argument without any flag:

```bash
# Old way (still works):
python3 xml_db_sync.py sync --file path/to/file.xml

# New way (simpler):
python3 xml_db_sync.py sync path/to/file.xml

# Old way:
python3 xml_db_sync.py update-sql --file LCSEL0857.sql

# New way:
python3 xml_db_sync.py update-sql LCSEL0857.sql
```

#### Legacy Support (For Get-SQL and Get-XML)
The old `-o` / `--output` flags still work perfectly:

```bash
# These all work:
python3 xml_db_sync.py get-sql --codigo LCSEL0857 --output ./output_directory
python3 xml_db_sync.py get-sql --codigo LCSEL0857 -o ./output_directory
python3 xml_db_sync.py get-xml --codigo JBTR00007 --output ./exports
python3 xml_db_sync.py get-xml --codigo JBTR00007 -o ./exports

# Default to current directory if not specified:
python3 xml_db_sync.py get-sql --codigo LCSEL0857
```

## 🛡️ Safety Features

### Automatic Backups
- Every update creates a timestamped backup
- Backups stored in `./backups/` directory
- Format: `JBTR00004_backup_20241029_143022.xml`

### Validation
- ✅ XML format validation
- ✅ File existence checks
- ✅ Database connection validation
- ✅ Record existence verification

### Error Handling
- 🔄 Automatic rollback on failures
- 📝 Detailed error messages
- 🚫 Prevents corrupt data insertion

## 📁 Files Structure

```
parametrizacion_emaku_jbe/
├── xml_db_sync.py              # Main sync script
├── db_config.json              # Database configuration
├── setup.sh                    # One-time setup script
├── backups/                    # Automatic backups
│   ├── JBTR00004_backup_*.xml
│   └── JBTR00001_backup_*.xml
├── .vscode/
│   ├── tasks.json              # VS Code tasks
│   └── keybindings.json        # Keyboard shortcuts
└── transacciones/
    ├── ventas/cotizaciones/JBTR00004_perfil.xml
    └── ventas/pedidos/JBTR00001_perfil.xml
```

## 🔧 Advanced Configuration

### Custom File Mappings
Edit `db_config.json` to add automatic codigo detection:
```json
{
  "file_mappings": {
    "JBTR00001_perfil.xml": "JBTR00001",
    "JBTR00004_perfil.xml": "JBTR00004",
    "JBTR00005_perfil.xml": "JBTR00005"
  }
}
```

### Custom Backup Directory
```json
{
  "backup_directory": "/path/to/your/backups",
  "backup_enabled": true
}
```

## 🚨 Troubleshooting

### Database Connection Issues
```bash
# Test connection
python3 xml_db_sync.py test

# Check config
python3 xml_db_sync.py config
```

### Missing Dependencies
```bash
pip3 install psycopg2-binary
# or
sudo apt-get install libpq-dev python3-dev
pip3 install psycopg2-binary
```

### Permission Issues
```bash
chmod +x xml_db_sync.py
chmod +x setup.sh
```

## 📊 Example Usage Session

```bash
$ python3 xml_db_sync.py test
🔄 Testing database connection...
✅ Connected to PostgreSQL: PostgreSQL 13.7
✅ Table 'transacciones' accessible: 25 records

$ python3 xml_db_sync.py sync transacciones/ventas/cotizaciones/JBTR00004_perfil.xml
🔍 Auto-detected codigo: JBTR00004
✅ XML validation passed
💾 Backup created: ./backups/JBTR00004_backup_20241029_143022.xml
📝 Updated existing record for codigo: JBTR00004
✅ Successfully synced JBTR00004_perfil.xml to database
📊 Record: JBTR00004 in table transacciones
💾 Backup available: ./backups/JBTR00004_backup_20241029_143022.xml

$ python3 xml_db_sync.py get-sql --codigo LCSEL0857 ./sentencias_sql
🔍 Retrieving SQL query for codigo: LCSEL0857
📄 SQL file created: ./sentencias_sql/LCSEL0857.sql
✅ Successfully retrieved SQL query

$ python3 xml_db_sync.py get-xml --codigo JBTR00004 ./exports
🔍 Extracting XML files for codigo: JBTR00004
📄 perfil XML file created: ./exports/JBTR00004_perfil.xml
📄 args_driver XML file created: ./exports/JBTR00004_args_driver.xml
✅ Successfully extracted XML files
```

## 🔄 Integration with Existing Workflow

This system integrates seamlessly with your current development process:

1. **Edit XML files** as usual in VS Code
2. **Save changes** (`Ctrl+S`)
3. **Sync to database** (`Ctrl+Shift+D`)
4. **Test your application** with updated forms

## 🌟 Benefits

- ⚡ **99% time reduction** - From minutes to seconds
- 🛡️ **Zero risk** - Automatic backups and validation
- 🔄 **Consistent** - No copy-paste errors
- 📝 **Auditable** - Timestamped backups for every change
- 🚀 **Efficient** - Works directly from VS Code

## 🔮 Future Enhancements

Possible additions:
- 🔄 Two-way sync (database → XML)
- 📝 Change history tracking
- 🔀 Multi-database support
- 🔔 Slack/Teams notifications
- 🤖 Automatic sync on file save