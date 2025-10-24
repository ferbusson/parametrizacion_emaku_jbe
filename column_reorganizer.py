#!/usr/bin/env python3
"""
XML Table Column Reorganizer
Reorganizes formulas and column references when adding new columns to XML table structure.
"""

import re
import sys
from typing import List, Dict, Tuple, Optional

class ColumnReorganizer:
    def __init__(self, xml_file_path: str):
        self.xml_file_path = xml_file_path
        self.column_letters = self._generate_column_letters()
        
    def _generate_column_letters(self) -> List[str]:
        """Generate column letters: a-z, aa-az, ba-bz, etc."""
        letters = []
        # Single letters a-z
        for i in range(26):
            letters.append(chr(ord('a') + i))
        
        # Double letters aa-zz
        for first in range(26):
            for second in range(26):
                letters.append(chr(ord('a') + first) + chr(ord('a') + second))
        
        return letters
    
    def _get_column_index(self, letter: str) -> int:
        """Get the index of a column letter."""
        try:
            return self.column_letters.index(letter)
        except ValueError:
            return -1
    
    def _shift_column_letters(self, text: str, insert_position: int, shift_amount: int = 1) -> str:
        """Shift column letters in formulas after the insertion point."""
        
        def replace_column_ref(match):
            column_letter = match.group(0)
            col_index = self._get_column_index(column_letter)
            
            # Only shift columns that are at or after the insertion position
            if col_index >= insert_position:
                new_index = col_index + shift_amount
                if new_index < len(self.column_letters):
                    return self.column_letters[new_index]
            return column_letter
        
        # Enhanced pattern to match column letters more precisely
        # This pattern matches single letters (a-z) and double letters (aa-zz)
        # but avoids matching parts of longer words
        pattern = r'\b([a-z]{1,2})(?=\s*[=<>!+\-*/()&|,]|\s*$|\s)'
        
        return re.sub(pattern, replace_column_ref, text)
    
    def _update_totales_attribute(self, totales_text: str, insert_position: int) -> str:
        """Update the totales attribute with shifted column references."""
        columns = [col.strip() for col in totales_text.split(',')]
        updated_columns = []
        
        for col in columns:
            col_index = self._get_column_index(col)
            if col_index >= insert_position:
                new_index = col_index + 1
                if new_index < len(self.column_letters):
                    updated_columns.append(self.column_letters[new_index])
                else:
                    updated_columns.append(col)  # Keep original if out of range
            else:
                updated_columns.append(col)
        
        return ','.join(updated_columns)
    
    def _update_export_total_col(self, export_text: str, insert_position: int) -> str:
        """Update exportTotalCol attributes."""
        parts = export_text.split(',', 1)
        if len(parts) == 2:
            col_letter, value_name = parts
            col_index = self._get_column_index(col_letter)
            if col_index >= insert_position:
                new_index = col_index + 1
                if new_index < len(self.column_letters):
                    return f"{self.column_letters[new_index]},{value_name}"
        return export_text
    
    def _update_column_comments(self, comment_text: str, insert_position: int) -> str:
        """Update column comments with shifted position numbers."""
        # Pattern to match comments like "<!-- 15 (o) -->" or "<!-- 15 (o) description -->"
        pattern = r'<!-- (\d+) \(([a-z]{1,2})\)(.*?) -->'
        
        def replace_comment(match):
            num_str = match.group(1)
            letter = match.group(2)
            description = match.group(3)
            
            col_index = self._get_column_index(letter)
            if col_index >= insert_position:
                new_num = int(num_str) + 1
                new_index = col_index + 1
                if new_index < len(self.column_letters):
                    new_letter = self.column_letters[new_index]
                    return f"<!-- {new_num} ({new_letter}){description} -->"
            return match.group(0)
        
        return re.sub(pattern, replace_comment, comment_text)
    
    def update_formulas_after_manual_insertion(self, inserted_position: int) -> bool:
        """
        Update all formulas and references after a column has been manually inserted.
        
        This method assumes you've already manually added the new column definition
        in the XML and now need to update all formula references to shift existing
        columns to their new positions.
        
        Args:
            inserted_position: Index where the new column was inserted (0-based)
                              All columns at this position and after will be shifted
        """
        
        try:
            with open(self.xml_file_path, 'r', encoding='utf-8') as file:
                content = file.read()
            
            print(f"🔄 Updating formulas after manual insertion at position {inserted_position}")
            print(f"📍 New column is at position {inserted_position} (letter: {self.column_letters[inserted_position]})")
            print(f"📊 All columns from position {inserted_position+1} onwards will be shifted")
            
            # Show what columns are being shifted
            print(f"\n📋 Column shifts that will occur:")
            for i in range(inserted_position + 1, min(inserted_position + 10, len(self.column_letters)-1)):
                old_letter = self.column_letters[i-1]  # What the formula currently references
                new_letter = self.column_letters[i]    # What it should reference after shift
                print(f"   Formulas using '{old_letter}' -> will be updated to '{new_letter}'")
            
            # 1. Update totales attribute
            print(f"\n🔧 Updating totales attribute...")
            totales_pattern = r'<arg attribute="totales">([^<]+)</arg>'
            original_totales = re.search(totales_pattern, content)
            if original_totales:
                new_totales = self._update_totales_attribute(original_totales.group(1), inserted_position)
                content = re.sub(totales_pattern, 
                               f'<arg attribute="totales">{new_totales}</arg>',
                               content)
                print(f"   ✓ Updated: {original_totales.group(1)} -> {new_totales}")
            
            # 2. Update exportTotalCol attributes
            print(f"\n🔧 Updating exportTotalCol attributes...")
            export_pattern = r'<arg attribute="exportTotalCol">([^<]+)</arg>'
            for match in re.finditer(export_pattern, content):
                original = match.group(1)
                updated = self._update_export_total_col(original, inserted_position)
                if original != updated:
                    print(f"   ✓ Updated: {original} -> {updated}")
            
            content = re.sub(export_pattern,
                           lambda m: f'<arg attribute="exportTotalCol">{self._update_export_total_col(m.group(1), inserted_position)}</arg>',
                           content)
            
            # 3. Update beanshell formulas
            print(f"\n🔧 Updating beanshell formulas...")
            beanshell_pattern = r'<arg attribute="beanshell">([^<]+)</arg>'
            beanshell_count = 0
            for match in re.finditer(beanshell_pattern, content):
                original = match.group(1)
                updated = self._shift_column_letters(original, inserted_position)
                if original != updated:
                    beanshell_count += 1
                    print(f"   ✓ Formula {beanshell_count}: {original[:50]}{'...' if len(original) > 50 else ''}")
                    print(f"      -> {updated[:50]}{'...' if len(updated) > 50 else ''}")
            
            content = re.sub(beanshell_pattern,
                           lambda m: f'<arg attribute="beanshell">{self._shift_column_letters(m.group(1), inserted_position)}</arg>',
                           content)
            
            # 4. Update formula attributes
            print(f"\n🔧 Updating formula attributes...")
            formula_pattern = r'<arg attribute="formula">([^<]+)</arg>'
            formula_count = 0
            for match in re.finditer(formula_pattern, content):
                original = match.group(1)
                updated = self._shift_column_letters(original, inserted_position)
                if original != updated:
                    formula_count += 1
                    print(f"   ✓ Formula {formula_count}: {original} -> {updated}")
            
            content = re.sub(formula_pattern,
                           lambda m: f'<arg attribute="formula">{self._shift_column_letters(m.group(1), inserted_position)}</arg>',
                           content)
            
            # 5. Update column comments
            print(f"\n🔧 Updating column comments...")
            original_content = content
            content = self._update_column_comments(content, inserted_position)
            if content != original_content:
                print(f"   ✓ Column comments updated")
            
            # Write updated content back to file
            with open(self.xml_file_path, 'w', encoding='utf-8') as file:
                file.write(content)
            
            print(f"\n✅ Successfully updated all formulas and references!")
            print(f"📁 File updated: {self.xml_file_path}")
            
            return True
            
        except Exception as e:
            print(f"❌ Error updating XML file: {e}")
            return False
    
    def _generate_new_subarg(self, position: int, config: Dict) -> str:
        """Generate XML for new column subarg."""
        letter = self.column_letters[position]
        column_num = position + 1
        
        subarg = f"""            <!-- {column_num} ({letter}) -->
            <subarg>
            <arg attribute="name">{config.get('name', 'NEW_COLUMN')}</arg>
            <arg attribute="length">{config.get('length', '80')}</arg>
            <arg attribute="type">{config.get('type', 'STRING')}</arg>"""
        
        if config.get('enabled'):
            subarg += f'\n            <arg attribute="enabled">{config["enabled"]}</arg>'
        
        if config.get('roundDecimal'):
            subarg += f'\n            <arg attribute="roundDecimal">{config["roundDecimal"]}</arg>'
            
        if config.get('queryCol'):
            subarg += f'\n            <arg attribute="queryCol">{config["queryCol"]}</arg>'
            
        if config.get('returnCol'):
            subarg += f'\n            <arg attribute="returnCol">{config["returnCol"]}</arg>'
            
        if config.get('printable'):
            subarg += f'\n            <arg attribute="printable">{config["printable"]}</arg>'
        
        subarg += "\n            </subarg>"
        
        return subarg
    
    def _insert_subarg_at_position(self, content: str, position: int, new_subarg: str) -> str:
        """Insert new subarg at the specified column position."""
        lines = content.split('\n')
        
        # Find the subarg that corresponds to the insertion position
        subarg_count = 0
        insert_line = -1
        
        for i, line in enumerate(lines):
            if '<!-- ' in line and ' (' in line and ') -->' in line:
                if subarg_count == position:
                    insert_line = i
                    break
                subarg_count += 1
        
        if insert_line >= 0:
            # Insert before the found position
            lines.insert(insert_line, new_subarg)
        else:
            # If position not found, insert at the end of subargs
            # Find the last </subarg> line
            for i in range(len(lines) - 1, -1, -1):
                if '</subarg>' in lines[i]:
                    lines.insert(i + 1, new_subarg)
                    break
        
        return '\n'.join(lines)
    
    def preview_changes(self, insert_position: int) -> Dict:
        """Preview what changes would be made without actually modifying the file."""
        
        try:
            with open(self.xml_file_path, 'r', encoding='utf-8') as file:
                content = file.read()
            
            preview = {
                'affected_formulas': [],
                'affected_totales': [],
                'affected_exports': [],
                'shifted_columns': []
            }
            
            # Find affected formulas
            beanshell_pattern = r'<arg attribute="beanshell">([^<]+)</arg>'
            for match in re.finditer(beanshell_pattern, content):
                original = match.group(1)
                updated = self._shift_column_letters(original, insert_position)
                if original != updated:
                    preview['affected_formulas'].append({
                        'original': original,
                        'updated': updated
                    })
            
            # Find affected totales
            totales_pattern = r'<arg attribute="totales">([^<]+)</arg>'
            for match in re.finditer(totales_pattern, content):
                original = match.group(1)
                updated = self._update_totales_attribute(original, insert_position)
                if original != updated:
                    preview['affected_totales'].append({
                        'original': original,
                        'updated': updated
                    })
            
            # Show which columns will be shifted
            for i in range(insert_position, min(len(self.column_letters), insert_position + 20)):
                preview['shifted_columns'].append({
                    'old_position': i,
                    'old_letter': self.column_letters[i],
                    'new_position': i + 1,
                    'new_letter': self.column_letters[i + 1] if i + 1 < len(self.column_letters) else 'OUT_OF_RANGE'
                })
            
            return preview
            
        except Exception as e:
            return {'error': str(e)}


def main():
    """Main function for command line usage."""
    
    if len(sys.argv) < 2:
        print("XML Table Column Reorganizer")
        print("============================")
        print("Usage: python column_reorganizer.py <xml_file_path> <inserted_position> [preview_only]")
        print("")
        print("This script updates formulas after you manually add a new column to your XML.")
        print("")
        print("Workflow:")
        print("1. Manually add your new column definition in the XML")
        print("2. Run this script with the position where you inserted it")
        print("3. All existing formulas will be automatically updated")
        print("")
        print("Examples:")
        print("  python column_reorganizer.py file.xml 3 preview    # Preview changes for insertion at position 3")
        print("  python column_reorganizer.py file.xml 3            # Update formulas for insertion at position 3")
        print("")
        print("Position Examples:")
        print("  0 = column 'a', 1 = column 'b', 2 = column 'c', etc.")
        return
    
    xml_file = sys.argv[1]
    
    if not sys.argv[1].endswith('.xml'):
        print("❌ Error: Please provide an XML file")
        return
    
    try:
        with open(xml_file, 'r') as f:
            pass  # Just check if file exists and is readable
    except FileNotFoundError:
        print(f"❌ Error: File '{xml_file}' not found")
        return
    except PermissionError:
        print(f"❌ Error: Permission denied accessing '{xml_file}'")
        return
    
    reorganizer = ColumnReorganizer(xml_file)
    
    if len(sys.argv) >= 3:
        try:
            insert_pos = int(sys.argv[2])
        except ValueError:
            print("❌ Error: Insert position must be a number")
            print("Example: python column_reorganizer.py file.xml 3")
            return
    else:
        print(f"\nCurrent column mapping:")
        for i in range(min(15, len(reorganizer.column_letters))):
            print(f"  Position {i}: {reorganizer.column_letters[i]}")
        
        try:
            insert_pos = int(input(f"\nEnter position where you inserted the new column (0-based): "))
        except ValueError:
            print("❌ Error: Please enter a valid number")
            return
    
    if insert_pos < 0 or insert_pos >= len(reorganizer.column_letters):
        print(f"❌ Error: Position {insert_pos} is out of range (0-{len(reorganizer.column_letters)-1})")
        return
    
    # Check if preview only
    preview_only = len(sys.argv) >= 4 and sys.argv[3].lower() == 'preview'
    
    print(f"\n📍 Processing insertion at position {insert_pos}")
    print(f"📋 New column letter: {reorganizer.column_letters[insert_pos]}")
    print(f"📊 All formulas referencing columns from position {insert_pos} onwards will be shifted")
    
    if preview_only:
        print(f"\n=== PREVIEW MODE ===")
        
        preview = reorganizer.preview_changes(insert_pos)
        
        if 'error' in preview:
            print(f"❌ Error: {preview['error']}")
            return
        
        print(f"\n📋 Columns that will be shifted:")
        for shift in preview['shifted_columns'][:10]:  # Show first 10
            print(f"   {shift['old_letter']} -> {shift['new_letter']}")
        
        if preview['affected_formulas']:
            print(f"\n🔧 Formulas that will be updated ({len(preview['affected_formulas'])} total):")
            for i, formula in enumerate(preview['affected_formulas'][:5]):  # Show first 5
                print(f"   {i+1}. {formula['original'][:60]}{'...' if len(formula['original']) > 60 else ''}")
                print(f"      -> {formula['updated'][:60]}{'...' if len(formula['updated']) > 60 else ''}")
                print()
        
        if preview['affected_totales']:
            print(f"\n📊 Totales that will be updated:")
            for total in preview['affected_totales']:
                print(f"   {total['original']} -> {total['updated']}")
        
        print(f"\n💡 To apply these changes, run without 'preview':")
        print(f"   python column_reorganizer.py {xml_file} {insert_pos}")
    
    else:
        # Show a brief preview first
        preview = reorganizer.preview_changes(insert_pos)
        affected_count = len(preview.get('affected_formulas', []))
        
        print(f"\n📊 Changes to be made:")
        print(f"   • {affected_count} formulas will be updated")
        print(f"   • {len(preview.get('affected_totales', []))} totales attributes will be updated")
        print(f"   • Column comments will be updated")
        
        # Confirm before proceeding
        confirm = input(f"\n❓ Proceed with updating formulas? (y/N): ")
        
        if confirm.lower() in ['y', 'yes']:
            print(f"\n🚀 Starting formula updates...")
            success = reorganizer.update_formulas_after_manual_insertion(insert_pos)
            
            if success:
                print(f"\n🎉 All done! Your XML formulas have been updated.")
                print(f"💡 Remember to test your application to ensure everything works correctly.")
            else:
                print(f"\n❌ Update failed. Please check the error messages above.")
        else:
            print(f"\n⏹️  Operation cancelled.")


if __name__ == "__main__":
    main()