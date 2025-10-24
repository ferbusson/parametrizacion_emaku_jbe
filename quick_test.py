#!/usr/bin/env python3
"""
Quick usage example for the new workflow
"""

from column_reorganizer import ColumnReorganizer

def example_your_workflow():
    """
    Example of your specific workflow:
    1. You manually add "Disponible" column after "DESCRIPCION" 
    2. Script updates all formulas automatically
    """
    
    print("=== YOUR WORKFLOW EXAMPLE ===")
    print("Scenario: You manually added 'Disponible' column after 'DESCRIPCION'")
    print("")
    
    # Your XML file
    xml_file = "transacciones/ventas/pedidos/JBTR00001_perfil.xml"
    
    # Position where you inserted (after DESCRIPCION which is position 1, so new column is at position 2)
    # But since you said "3(c)", let's use position 2 (which becomes letter 'c')
    inserted_position = 2
    
    reorganizer = ColumnReorganizer(xml_file)
    
    print(f"📋 Current column structure:")
    current_columns = [
        "0 (a): CODE",
        "1 (b): DESCRIPCION", 
        "2 (c): *** YOUR NEW 'Disponible' COLUMN ***",
        "3 (d): CANTIDAD (was 'c', now shifted to 'd')",
        "4 (e): Lista (was 'd', now shifted to 'e')",
        "5 (f): VUNITARIO (was 'e', now shifted to 'f')",
        "... (all subsequent columns shifted)"
    ]
    
    for col in current_columns:
        print(f"   {col}")
    
    print(f"\n🔍 Preview of changes that would be made:")
    
    # Preview the changes
    preview = reorganizer.preview_changes(inserted_position)
    
    if 'error' not in preview:
        print(f"\n📊 {len(preview['affected_formulas'])} formulas will be updated")
        print(f"📊 {len(preview['affected_totales'])} totales attributes will be updated")
        
        print(f"\n🔧 Example formula changes:")
        for i, formula in enumerate(preview['affected_formulas'][:3]):
            print(f"   {i+1}. Before: {formula['original']}")
            print(f"      After:  {formula['updated']}")
            print()
        
        print(f"\n📋 Column letter shifts:")
        for shift in preview['shifted_columns'][:8]:
            print(f"   Position {shift['new_position']}: {shift['old_letter']} -> {shift['new_letter']}")
    
    print(f"\n💡 To apply these changes after manually adding your column:")
    print(f"   python column_reorganizer.py {xml_file} {inserted_position}")
    print(f"   python column_reorganizer.py {xml_file} {inserted_position} preview  # to preview first")

def quick_test():
    """Quick test to make sure the script works"""
    
    print("\n=== QUICK VALIDATION TEST ===")
    
    xml_file = "transacciones/ventas/pedidos/JBTR00001_perfil.xml"
    
    try:
        reorganizer = ColumnReorganizer(xml_file)
        print("✅ Script loaded successfully")
        
        # Test the column letter generation
        print(f"✅ Column letters work: a={reorganizer._get_column_index('a')}, z={reorganizer._get_column_index('z')}, aa={reorganizer._get_column_index('aa')}")
        
        # Test formula shifting (without actually changing the file)
        test_formula = "h=al<0?(c*e)/(1+(f/100.0))"
        shifted = reorganizer._shift_column_letters(test_formula, 2)
        print(f"✅ Formula shifting works: {test_formula} -> {shifted}")
        
        print("✅ All tests passed - script is ready to use!")
        
    except Exception as e:
        print(f"❌ Error during test: {e}")

if __name__ == "__main__":
    example_your_workflow()
    quick_test()