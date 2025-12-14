#!/usr/bin/env python3
"""
User Manual Generator for EMK System
Automatically generates user manuals from XML forms and SQL queries
"""

import xml.etree.ElementTree as ET
from pathlib import Path
import re
from datetime import datetime

class ManualGenerator:
    def __init__(self, project_root):
        self.project_root = Path(project_root)
        self.manuals_dir = self.project_root / "docs" / "manuals"
        
    def analyze_xml_form(self, xml_path):
        """Analyze XML form and extract components, fields, and structure"""
        with open(xml_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        try:
            root = ET.fromstring(content)
        except ET.ParseError as e:
            print(f"Error parsing XML: {e}")
            return None
            
        analysis = {
            'file': xml_path.name,
            'components': [],
            'tables': [],
            'print_actions': [],
            'validation_rules': [],
            'driver_components': []
        }
        
        # Find all components with driver IDs
        for component in root.findall(".//component"):
            driver_elem = component.find("driver")
            if driver_elem is not None and driver_elem.get('id'):
                comp_info = {
                    'id': driver_elem.get('id'),
                    'class': driver_elem.text,
                    'methods': []
                }
                
                # Find methods
                for method in component.findall(".//method"):
                    comp_info['methods'].append(method.text)
                    
                analysis['components'].append(comp_info)
                
        # Find table references  
        tables = set()
        for component in root.findall(".//component"):
            driver = component.find("driver")
            if driver is not None and driver.text and 'TableFindData' in driver.text:
                if driver.get('id'):
                    tables.add(driver.get('id'))
        analysis['tables'] = list(tables)
        
        # Find print actions
        for action in root.findall(".//action[@type='printer']"):
            template = action.find("printerTemplate")
            if template is not None:
                analysis['print_actions'].append(template.text)
                
        # Find validation rules
        for component in root.findall(".//component"):
            for arg in component.findall(".//arg"):
                if arg.get('attribute') == 'conditional':
                    driver = component.find(".//driver")
                    if driver is not None and driver.get('id'):
                        analysis['validation_rules'].append(driver.get('id'))
                        break
                
        return analysis
        
    def generate_form_manual(self, xml_path, business_context=None):
        """Generate a user manual for a specific XML form"""
        analysis = self.analyze_xml_form(xml_path)
        if not analysis:
            return None
            
        form_name = xml_path.stem.replace('_perfil', '').replace('JBTR', 'Form ')
        
        manual_content = f"""# 📋 {form_name} User Manual

## 📖 Overview
This manual covers the usage of the {form_name} transaction form in the EMK system.

**Form File**: `{analysis['file']}`  
**Last Updated**: {datetime.now().strftime('%Y-%m-%d %H:%M')}

## 🎯 Purpose
{business_context or 'This form handles business transactions and data entry for the system.'}

## 🏗️ Form Structure

### 📊 Main Components
"""

        # Add components section
        if analysis['components']:
            for comp in analysis['components'][:10]:  # Limit to first 10
                manual_content += f"""
#### {comp['id']} 
- **Type**: `{comp['class']}`
- **Methods**: {', '.join(comp['methods']) if comp['methods'] else 'Standard operations'}
"""

        # Add tables section
        if analysis['tables']:
            manual_content += f"""
### 🗃️ Data Tables
This form interacts with the following data tables:
"""
            for table in analysis['tables']:
                manual_content += f"- **{table}**: Data input/lookup table\\n"

        # Add print actions
        if analysis['print_actions']:
            manual_content += f"""
### 🖨️ Print Templates
Available print formats:
"""
            for template in analysis['print_actions']:
                template_name = template.split('/')[-1].replace('.xml', '')
                manual_content += f"- **{template_name}**: {template}\\n"

        # Add validation section
        if analysis['validation_rules']:
            manual_content += f"""
### ✅ Validation Rules
Form fields with validation:
"""
            for rule in analysis['validation_rules']:
                manual_content += f"- **{rule}**: Has conditional validation\\n"

        # Add standard sections
        manual_content += f"""

## 👤 User Roles
- **Primary Users**: [To be documented with your input]
- **Required Permissions**: [To be documented]

## 📝 Step-by-Step Procedures

### Opening the Form
1. Navigate to the appropriate menu section
2. Select the {form_name} option
3. Wait for the form to load completely

### Data Entry Process
1. **Fill Required Fields**: Complete all mandatory fields marked with validation
2. **Verify Information**: Review entered data for accuracy
3. **Save or Process**: Use appropriate action button to process the transaction

### Print Options
{self._generate_print_instructions(analysis['print_actions'])}

## 🔧 Field Reference

{self._generate_field_reference(analysis['components'])}

## ❓ Common Scenarios
[To be documented with your business expertise]

## 🐛 Troubleshooting

### Common Issues
- **Form doesn't load**: Check network connection and user permissions
- **Validation errors**: Ensure all required fields are properly filled
- **Print issues**: Verify printer configuration and template availability

### Error Messages
[To be documented as issues are identified]

## 🔗 Integration Points
This form may integrate with:
{self._generate_integration_points(analysis['tables'])}

## 📞 Support
For technical support or questions about this form, contact your system administrator.

---
*This manual was auto-generated from form analysis. Please provide business context to enhance the documentation.*
"""

        return manual_content
        
    def _generate_print_instructions(self, print_actions):
        if not print_actions:
            return "No print templates configured."
            
        instructions = ""
        for template in print_actions:
            template_name = template.split('/')[-1].replace('.xml', '')
            instructions += f"- **{template_name}**: Available for document printing\\n"
        return instructions
        
    def _generate_field_reference(self, components):
        if not components:
            return "No documented components."
            
        reference = "| Field ID | Component Type | Purpose |\\n"
        reference += "|----------|----------------|---------|\\n"
        
        for comp in components[:15]:  # Limit to prevent huge tables
            comp_type = comp['class'].split('.')[-1] if comp['class'] else 'Unknown'
            reference += f"| {comp['id']} | {comp_type} | [To be documented] |\\n"
            
        return reference
        
    def _generate_integration_points(self, tables):
        if not tables:
            return "No identified integrations."
            
        points = ""
        for table in tables:
            points += f"- **{table}**: Data lookup and validation\\n"
        return points
        
    def generate_all_manuals(self):
        """Generate manuals for all XML forms in the project"""
        xml_files = list(self.project_root.glob("**/JBTR*_perfil.xml"))
        
        print(f"Found {len(xml_files)} XML forms to document")
        
        for xml_file in xml_files:
            print(f"Generating manual for {xml_file.name}...")
            
            manual_content = self.generate_form_manual(xml_file)
            if manual_content:
                # Determine output path based on form location
                relative_path = xml_file.relative_to(self.project_root)
                category = self._determine_category(relative_path)
                
                output_path = self.manuals_dir / category / f"{xml_file.stem.replace('_perfil', '')}.md"
                output_path.parent.mkdir(parents=True, exist_ok=True)
                
                with open(output_path, 'w', encoding='utf-8') as f:
                    f.write(manual_content)
                    
                print(f"✅ Created manual: {output_path}")
                
    def _determine_category(self, xml_path):
        """Determine manual category based on file path"""
        path_str = str(xml_path).lower()
        
        if 'venta' in path_str:
            return 'sales'
        elif 'compra' in path_str:
            return 'purchases'
        elif 'inventario' in path_str or 'producto' in path_str:
            return 'inventory'
        elif 'tercero' in path_str:
            return 'contacts'
        elif 'nomina' in path_str:
            return 'payroll'
        else:
            return 'general'

if __name__ == "__main__":
    generator = ManualGenerator("/home/drus/workspace/parametrizacion_emaku_jbe")
    generator.generate_all_manuals()