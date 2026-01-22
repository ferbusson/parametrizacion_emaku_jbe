# Quick CLI Reference - Updated

## Summary of Changes
**No more `-f` or `-o` flags for the second parameter!** The script now recognizes the second parameter automatically by convention.

---

## Before (Old Way - Still Works)
```bash
python3 xml_db_sync.py sync --file transacciones/ventas/pedidos/JBTR00001_perfil.xml
python3 xml_db_sync.py update-sql --file LCSEL0857.sql
python3 xml_db_sync.py get-sql --codigo LCSEL0857 --output ./output_dir
python3 xml_db_sync.py get-xml --codigo JBTR00007 --output ./exports
```

## After (New Way - Recommended)
```bash
python3 xml_db_sync.py sync transacciones/ventas/pedidos/JBTR00001_perfil.xml
python3 xml_db_sync.py update-sql LCSEL0857.sql
# Get-SQL and Get-XML still use --output (or -o) for now
python3 xml_db_sync.py get-sql --codigo LCSEL0857 --output ./output_dir
python3 xml_db_sync.py get-xml --codigo JBTR00007 --output ./exports
```

---

## All Available Commands

### 1. **Sync XML to Database**
```bash
# Sync a file (positional parameter replaces --file)
python3 xml_db_sync.py sync path/to/file.xml

# With specific codigo
python3 xml_db_sync.py sync path/to/file.xml --codigo JBTR00004
```

### 2. **Update SQL Query**
```bash
# Update SQL from a file (positional parameter replaces --file)
python3 xml_db_sync.py update-sql LCSEL0857.sql

# With specific codigo (if different from filename)
python3 xml_db_sync.py update-sql query.sql --codigo LCSEL0857
```

### 3. **Get SQL Query from Database**
```bash
# Get SQL and save to current directory
python3 xml_db_sync.py get-sql --codigo LCSEL0857

# Get SQL and save to specific directory
python3 xml_db_sync.py get-sql --codigo LCSEL0857 --output ./sentencias_sql
python3 xml_db_sync.py get-sql --codigo LCSEL0857 -o ./sentencias_sql  # Short flag
```

### 4. **Get XML Files from Database**
```bash
# Get XML and save to current directory
python3 xml_db_sync.py get-xml --codigo JBTR00007

# Get XML and save to specific directory
python3 xml_db_sync.py get-xml --codigo JBTR00007 --output ./exports
python3 xml_db_sync.py get-xml --codigo JBTR00007 -o ./exports  # Short flag
```

### 5. **Create New Transaction**
```bash
# Create with optional prefix hint
python3 xml_db_sync.py create --prefix JBTR0
python3 xml_db_sync.py create  # Will ask for prefix interactively
```

### 6. **Create New SQL Query**
```bash
# Create new SQL query record
python3 xml_db_sync.py insert-sql --prefix LCSEL
python3 xml_db_sync.py insert-sql  # Will ask for prefix interactively
```

### 7. **Test Connection**
```bash
python3 xml_db_sync.py test
```

### 8. **List Records**
```bash
python3 xml_db_sync.py list
```

### 9. **View Configuration**
```bash
python3 xml_db_sync.py config
```

---

## Key Improvements

| Command | Before | After | Benefit |
|---------|--------|-------|---------|
| sync | `sync --file path/file.xml` | `sync path/file.xml` | 🎯 Simpler |
| update-sql | `update-sql --file file.sql` | `update-sql file.sql` | 🎯 Simpler |
| get-sql | `get-sql --codigo X --output dir` | `get-sql --codigo X -o dir` | ✨ Works as before |
| get-xml | `get-xml --codigo X --output dir` | `get-xml --codigo X -o dir` | ✨ Works as before |

---

## Error Messages Guide

If you forget the required parameters, you'll get helpful messages:

```
❌ File path parameter is required for sync action
💡 Usage: python xml_db_sync.py sync <file_path>
         or: python xml_db_sync.py sync --file <file_path>
```

---

## Real-World Examples

### Example 1: Update Pedido Form
```bash
# Old way:
python3 xml_db_sync.py sync --file transacciones/ventas/pedidos/JBTR00001_perfil.xml

# New way:
python3 xml_db_sync.py sync transacciones/ventas/pedidos/JBTR00001_perfil.xml
```

### Example 2: Update SQL Report
```bash
# Old way:
python3 xml_db_sync.py update-sql --file sentencias_sql/LCSEL0857.sql

# New way:
python3 xml_db_sync.py update-sql sentencias_sql/LCSEL0857.sql
```

### Example 3: Export SQL Query
```bash
# Save to a specific folder:
python3 xml_db_sync.py get-sql --codigo LCSEL0857 -o ./exports/

# Save to current directory:
python3 xml_db_sync.py get-sql --codigo LCSEL0857
```

### Example 4: Backup XML Files
```bash
# Create a backup folder and export:
mkdir -p ./backups/2026-01
python3 xml_db_sync.py get-xml --codigo JBTR00001 -o ./backups/2026-01
```

---

## Backward Compatibility

✅ All old commands still work! You can gradually migrate to the new convention:

```bash
# These all work:
python3 xml_db_sync.py sync transacciones/ventas/pedidos/JBTR00001_perfil.xml  # New
python3 xml_db_sync.py sync --file transacciones/ventas/pedidos/JBTR00001_perfil.xml  # Old - still works!
```

---

## Next Steps

1. 📝 Update your scripts and shortcuts to use the new, simpler format
2. 🚀 Enjoy faster typing - no more `-f` or `-o` flags needed!
3. 💾 Don't worry - old syntax still works perfectly for now
