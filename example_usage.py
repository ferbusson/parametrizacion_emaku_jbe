#!/usr/bin/env python3
"""
Example usage of the Column Reorganizer tool
"""

from column_reorganizer import ColumnReorganizer

def example_usage():
    """Example of how to use the column reorganizer."""
    
    # Initialize the reorganizer with your XML file
    xml_file = "transacciones/ventas/pedidos/JBTR00001_perfil.xml"
    reorganizer = ColumnReorganizer(xml_file)
    
    # Example 1: Preview changes before inserting at position 5
    print("=== PREVIEW EXAMPLE ===")
    insert_position = 5  # This would insert between columns 'e' and 'f'
    
    preview = reorganizer.preview_changes(insert_position)
    
    print(f"Inserting at position {insert_position} (after column '{reorganizer.column_letters[insert_position-1]}')")
    print(f"New column will be: '{reorganizer.column_letters[insert_position]}'")
    
    print("\nColumns that will shift:")
    for shift in preview['shifted_columns'][:5]:
        print(f"  {shift['old_letter']} -> {shift['new_letter']}")
    
    print("\nFormulas that will be affected:")
    for formula in preview['affected_formulas'][:3]:
        print(f"  {formula['original']} -> {formula['updated']}")
    
    # Example 2: Actually insert a column (commented out for safety)
    """
    new_column_config = {
        'name': 'NEW_CALC',
        'length': '90',
        'type': 'DECIMAL',
        'enabled': 'false',
        'roundDecimal': '2',
        'description': 'New calculation column'
    }
    
    # Uncomment to actually perform the insertion
    # success = reorganizer.insert_column(insert_position, new_column_config)
    # print(f"Insertion successful: {success}")
    """

def interactive_mode():
    """Run in interactive mode to get user input."""
    
    xml_file = input("Enter XML file path: ").strip()
    if not xml_file:
        xml_file = "transacciones/ventas/pedidos/JBTR00001_perfil.xml"
    
    try:
        reorganizer = ColumnReorganizer(xml_file)
        
        print(f"\nCurrent column mapping (first 20):")
        for i in range(min(20, len(reorganizer.column_letters))):
            print(f"  {i}: {reorganizer.column_letters[i]}")
        
        while True:
            print("\nOptions:")
            print("1. Preview changes for column insertion")
            print("2. Insert new column")
            print("3. Show current column mapping")
            print("4. Exit")
            
            choice = input("\nSelect option (1-4): ").strip()
            
            if choice == '1':
                pos = int(input("Enter insertion position (0-based): "))
                preview = reorganizer.preview_changes(pos)
                
                print(f"\n=== PREVIEW FOR POSITION {pos} ===")
                if 'error' in preview:
                    print(f"Error: {preview['error']}")
                    continue
                
                print("Affected formulas:")
                for f in preview['affected_formulas']:
                    print(f"  {f['original']} -> {f['updated']}")
                
                print("Column shifts:")
                for s in preview['shifted_columns'][:10]:
                    print(f"  {s['old_letter']} -> {s['new_letter']}")
            
            elif choice == '2':
                pos = int(input("Enter insertion position (0-based): "))
                
                config = {
                    'name': input("Column name: "),
                    'length': input("Length (default 80): ") or "80",
                    'type': input("Type (STRING/DECIMAL/INTEGER): ") or "STRING",
                    'enabled': input("Enabled (true/false): ") or "true"
                }
                
                confirm = input(f"Insert column at position {pos}? (y/N): ")
                if confirm.lower() == 'y':
                    success = reorganizer.insert_column(pos, config)
                    print(f"Success: {success}")
            
            elif choice == '3':
                start = int(input("Start from column index (default 0): ") or "0")
                count = int(input("How many to show (default 20): ") or "20")
                
                print(f"\nColumn mapping from {start}:")
                for i in range(start, min(start + count, len(reorganizer.column_letters))):
                    print(f"  {i}: {reorganizer.column_letters[i]}")
            
            elif choice == '4':
                break
            
            else:
                print("Invalid option")
                
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    print("Column Reorganizer - Example Usage")
    print("================================")
    
    mode = input("Run in (e)xample or (i)nteractive mode? (e/i): ").lower()
    
    if mode == 'i':
        interactive_mode()
    else:
        example_usage()