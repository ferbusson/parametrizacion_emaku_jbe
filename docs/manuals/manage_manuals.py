#!/usr/bin/env python3
"""
Manual Management Tool
Interactive tool for creating and maintaining user manuals
"""

import argparse
import json
from pathlib import Path
from datetime import datetime

class ManualManager:
    def __init__(self, project_root):
        self.project_root = Path(project_root)
        self.manuals_dir = self.project_root / "docs" / "manuals"
        
    def interactive_manual_builder(self):
        """Interactive tool to help build manuals step by step"""
        print("\n🎯 EMK Manual Builder")
        print("=" * 50)
        
        # Show available forms
        forms_list = self.show_available_forms()
        
        # Get user choice
        print("\nHow to select a form:")
        print("• Enter the JBTR code (e.g., JBTR00001)")
        print("• Enter the number from the list above")
        print("• Enter part of the filename")
        
        form_choice = input("\nWhich form would you like to work on? ").strip()
        
        if not form_choice:
            print("❌ No form selected")
            return
            
        # Handle numeric choice from list
        if form_choice.isdigit():
            choice_num = int(form_choice)
            if 1 <= choice_num <= len(forms_list):
                form_path = forms_list[choice_num - 1]  # Convert to 0-based index
                print(f"📝 Selected: {form_path.stem}")
            else:
                print(f"❌ Invalid number. Please choose 1-{len(forms_list)}")
                return
        else:
            # Find the form by name/code
            form_path = self.find_form(form_choice)
            if not form_path:
                print(f"❌ Form not found: {form_choice}")
                return
            
        # Check if manual exists
        manual_path = self.get_manual_path(form_path)
        
        if manual_path.exists():
            print(f"📋 Manual exists: {manual_path}")
            print("Choose action:")
            print("1. Enhance existing manual")
            print("2. View current manual")
            print("3. Regenerate from scratch")
            
            choice = input("Select option (1-3): ").strip()
            
            if choice == "1":
                self.enhance_manual(manual_path, form_path)
            elif choice == "2":
                self.view_manual(manual_path)
            elif choice == "3":
                self.regenerate_manual(form_path)
        else:
            print(f"📝 Creating new manual for {form_path.name}")
            self.create_new_manual(form_path)
            
    def show_available_forms(self):
        """Show all available XML forms and return the list"""
        xml_files = list(self.project_root.glob("**/JBTR*_perfil.xml"))
        # Sort by JBTR number for consistent ordering
        xml_files.sort(key=lambda x: x.stem)
        
        print(f"\n📋 Available Forms ({len(xml_files)} found):")
        print("-" * 50)
        
        for i, xml_file in enumerate(xml_files, 1):
            relative_path = xml_file.relative_to(self.project_root)
            category = self.get_category_from_path(relative_path)
            # Extract JBTR code for clarity
            jbtr_code = xml_file.stem.replace('_perfil', '')
            print(f"{i:2d}. {jbtr_code:<12} ({category}) - {relative_path}")
            
        return xml_files
            
    def get_category_from_path(self, xml_path):
        """Determine category from file path"""
        path_str = str(xml_path).lower()
        if 'venta' in path_str:
            return 'Sales'
        elif 'compra' in path_str:
            return 'Purchases'
        elif 'inventario' in path_str or 'producto' in path_str:
            return 'Inventory'
        else:
            return 'General'
            
    def find_form(self, form_choice):
        """Find XML form by code or filename"""
        xml_files = list(self.project_root.glob("**/JBTR*_perfil.xml"))
        
        for xml_file in xml_files:
            if (form_choice.upper() in xml_file.stem.upper() or 
                form_choice.upper() in xml_file.name.upper()):
                return xml_file
        return None
        
    def get_manual_path(self, form_path):
        """Get the manual file path for a form"""
        relative_path = form_path.relative_to(self.project_root)
        category = self.determine_manual_category(relative_path)
        manual_name = form_path.stem.replace('_perfil', '') + '.md'
        return self.manuals_dir / category / manual_name
        
    def determine_manual_category(self, xml_path):
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
            
    def enhance_manual(self, manual_path, form_path):
        """Guide user through enhancing an existing manual"""
        print(f"\n🔧 Enhancing manual: {manual_path.name}")
        print("-" * 40)
        
        # Read current manual
        with open(manual_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        print("What would you like to add/update?")
        print("1. Business Context (Purpose, Users, When to use)")
        print("2. Step-by-Step Procedures") 
        print("3. Field Descriptions")
        print("4. Common Scenarios")
        print("5. Troubleshooting")
        print("6. Integration Points")
        
        choice = input("Select section to enhance (1-6): ").strip()
        
        if choice == "1":
            self.add_business_context(manual_path, content)
        elif choice == "2":
            self.add_procedures(manual_path, content)
        elif choice == "3":
            self.add_field_descriptions(manual_path, content)
        elif choice == "4":
            self.add_scenarios(manual_path, content)
        elif choice == "5":
            self.add_troubleshooting(manual_path, content)
        elif choice == "6":
            self.add_integration_points(manual_path, content)
        else:
            print("❌ Invalid choice")
            
        
    def create_new_manual(self, form_path):
        """Create a new manual from scratch"""
        from generate_manuals import ManualGenerator
        
        print(f"🆕 Creating new manual for {form_path.name}")
        
        generator = ManualGenerator(self.project_root)
        manual_content = generator.generate_form_manual(form_path)
        
        if manual_content:
            manual_path = self.get_manual_path(form_path)
            manual_path.parent.mkdir(parents=True, exist_ok=True)
            
            with open(manual_path, 'w', encoding='utf-8') as f:
                f.write(manual_content)
                
            print(f"✅ Created new manual: {manual_path}")
        else:
            print(f"❌ Failed to generate manual for {form_path.name}")
            
    def regenerate_manual(self, form_path):
        """Regenerate manual from XML form"""
        print(f"🔄 Regenerating manual for {form_path.name}")
        
        manual_path = self.get_manual_path(form_path)
        
        # Backup existing manual if it exists
        if manual_path.exists():
            backup_path = manual_path.with_suffix(f'.backup.{datetime.now().strftime("%Y%m%d_%H%M%S")}.md')
            with open(manual_path, 'r', encoding='utf-8') as f:
                content = f.read()
            with open(backup_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"📄 Backup saved: {backup_path}")
        
        # Generate new manual
        self.create_new_manual(form_path)
        
    def add_procedures(self, manual_path, current_content):
        """Help user add step-by-step procedures"""
        print("\n📝 Adding Step-by-Step Procedures")
        print("=" * 35)
        
        procedures = []
        
        print("Add common procedures for this form:")
        while True:
            proc_name = input("Enter procedure name (or 'done' to finish): ").strip()
            if proc_name.lower() == 'done':
                break
                
            proc_description = input(f"Brief description of '{proc_name}': ")
            steps = []
            
            print("Enter the steps for this procedure (empty line to finish):")
            step_num = 1
            while True:
                step = input(f"Step {step_num}: ").strip()
                if not step:
                    break
                steps.append(step)
                step_num += 1
                
            procedures.append({
                'name': proc_name,
                'description': proc_description,
                'steps': steps
            })
            
        if procedures:
            proc_section = "\n## 📝 Step-by-Step Procedures\n\n"
            
            for proc in procedures:
                proc_section += f"### {proc['name']}\n"
                proc_section += f"{proc['description']}\n\n"
                for i, step in enumerate(proc['steps'], 1):
                    proc_section += f"{i}. {step}\n"
                proc_section += "\n"
                
            # Add to manual
            new_content = current_content + proc_section
                
            # Save updated manual
            with open(manual_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
                
            print(f"✅ {len(procedures)} procedures added to {manual_path}")
            
    def add_field_descriptions(self, manual_path, current_content):
        """Help user add field descriptions"""
        print("\n📝 Adding Field Descriptions")
        print("=" * 30)
        
        print("For each important field, provide business context:")
        
        field_descriptions = []
        while True:
            field_id = input("Enter field ID (or 'done' to finish): ").strip()
            if field_id.lower() == 'done':
                break
                
            field_name = input(f"Display name for '{field_id}': ")
            field_purpose = input(f"What is '{field_id}' used for in business? ")
            
            field_descriptions.append({
                'id': field_id,
                'name': field_name, 
                'purpose': field_purpose
            })
            
        if field_descriptions:
            field_section = "\n## 📋 Enhanced Field Reference\n\n"
            field_section += "| Field ID | Business Name | Purpose |\n"
            field_section += "|----------|---------------|----------|\n"
            
            for field in field_descriptions:
                field_section += f"| {field['id']} | {field['name']} | {field['purpose']} |\n"
                
            # Add to manual
            new_content = current_content + field_section
                
            # Save updated manual
            with open(manual_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
                
            print(f"✅ {len(field_descriptions)} field descriptions added to {manual_path}")
            
    def add_troubleshooting(self, manual_path, current_content):
        """Help user add troubleshooting information"""
        print("\n🐛 Adding Troubleshooting Information")
        print("=" * 40)
        
        issues = []
        while True:
            issue = input("Describe a common issue (or 'done' to finish): ").strip()
            if issue.lower() == 'done':
                break
                
            cause = input(f"What causes this issue? ")
            solution = input(f"How to fix it? ")
            
            issues.append({
                'issue': issue,
                'cause': cause,
                'solution': solution
            })
            
        if issues:
            trouble_section = "\n## 🐛 Troubleshooting\n\n"
            trouble_section += "### Common Issues\n\n"
            
            for issue in issues:
                trouble_section += f"**Issue**: {issue['issue']}\n"
                trouble_section += f"- **Cause**: {issue['cause']}\n"
                trouble_section += f"- **Solution**: {issue['solution']}\n\n"
                
            # Add to manual
            new_content = current_content + trouble_section
                
            # Save updated manual
            with open(manual_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
                
            print(f"✅ {len(issues)} troubleshooting entries added to {manual_path}")
            
    def add_integration_points(self, manual_path, current_content):
        """Help user add integration point information"""
        print("\n🔗 Adding Integration Points")
        print("=" * 30)
        
        integrations = []
        while True:
            system = input("Enter related system/form (or 'done' to finish): ").strip()
            if system.lower() == 'done':
                break
                
            relationship = input(f"How does this form connect to '{system}'? ")
            
            integrations.append({
                'system': system,
                'relationship': relationship
            })
            
        if integrations:
            int_section = "\n## 🔗 Integration Points\n\n"
            
            for integration in integrations:
                int_section += f"### {integration['system']}\n"
                int_section += f"{integration['relationship']}\n\n"
                
            # Add to manual
            new_content = current_content + int_section
                
            # Save updated manual
            with open(manual_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
                
            print(f"✅ {len(integrations)} integration points added to {manual_path}")

    def add_business_context(self, manual_path, current_content):
        """Help user add business context"""
        print("\n📋 Adding Business Context")
        print("=" * 30)
        
        # Get business purpose
        purpose = input("What is the main business purpose of this form?\n> ")
        
        # Get user roles  
        users = input("Who typically uses this form? (roles, departments)\n> ")
        
        # Get usage context
        when_to_use = input("When in the business process is this form used?\n> ")
        
        # Get prerequisites
        prerequisites = input("What setup/data is needed before using this form?\n> ")
        
        # Create enhanced content
        business_section = f"""
## 🎯 Business Context

### What It Does
{purpose}

### Who Uses It
{users}

### When To Use
{when_to_use}

### Prerequisites
{prerequisites}
"""
        
        # Insert into manual (replace placeholder if exists)
        if "Business Context" in current_content:
            # Update existing section
            import re
            pattern = r'## 🎯 Business Context.*?(?=##|\Z)'
            new_content = re.sub(pattern, business_section.strip() + '\n\n', current_content, flags=re.DOTALL)
        else:
            # Insert after Purpose section
            new_content = current_content.replace(
                "This form handles business transactions and data entry for the system.",
                business_section
            )
            
        # Save updated manual
        with open(manual_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
            
        print(f"✅ Business context added to {manual_path}")
        
    def add_scenarios(self, manual_path, current_content):
        """Help user add common scenarios"""
        print("\n🎬 Adding Common Scenarios")
        print("=" * 30)
        
        scenarios = []
        
        while True:
            scenario_name = input("Enter scenario name (or 'done' to finish): ").strip()
            if scenario_name.lower() == 'done':
                break
                
            situation = input(f"Describe when '{scenario_name}' happens: ")
            steps = []
            
            print("Enter the steps for this scenario (empty line to finish):")
            step_num = 1
            while True:
                step = input(f"Step {step_num}: ").strip()
                if not step:
                    break
                steps.append(step)
                step_num += 1
                
            scenarios.append({
                'name': scenario_name,
                'situation': situation,
                'steps': steps
            })
            
        if scenarios:
            scenario_section = "\n## 🎬 Common Scenarios\n\n"
            
            for scenario in scenarios:
                scenario_section += f"### Scenario: {scenario['name']}\n"
                scenario_section += f"**Situation**: {scenario['situation']}\n\n"
                scenario_section += "**Steps**:\n"
                for i, step in enumerate(scenario['steps'], 1):
                    scenario_section += f"{i}. {step}\n"
                scenario_section += "\n"
                
            # Add to manual
            if "Common Scenarios" in current_content:
                import re
                pattern = r'## 🎬 Common Scenarios.*?(?=##|\Z)'
                new_content = re.sub(pattern, scenario_section.strip() + '\n\n', current_content, flags=re.DOTALL)
            else:
                new_content = current_content + scenario_section
                
            # Save updated manual
            with open(manual_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
                
            print(f"✅ {len(scenarios)} scenarios added to {manual_path}")
        
    def view_manual(self, manual_path):
        """Display manual content"""
        print(f"\n📖 Viewing: {manual_path.name}")
        print("=" * 50)
        
        with open(manual_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Show first part of manual
        lines = content.split('\n')
        for i, line in enumerate(lines[:30]):
            print(f"{i+1:2d}: {line}")
            
        if len(lines) > 30:
            print(f"\n... and {len(lines) - 30} more lines")
            
        print(f"\n📁 Full manual location: {manual_path}")
        
    def list_manuals_status(self):
        """Show status of all manuals"""
        print("\n📊 Manual Status Report")
        print("=" * 50)
        
        xml_files = list(self.project_root.glob("**/JBTR*_perfil.xml"))
        
        for xml_file in xml_files:
            manual_path = self.get_manual_path(xml_file)
            
            if manual_path.exists():
                # Check if enhanced
                with open(manual_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    
                has_business_context = "What It Does" in content and len(content.split("What It Does")[1].split("\n")[0]) > 50
                has_scenarios = "Common Scenarios" in content
                has_procedures = "Step-by-Step" in content
                
                status = "📋 Base"
                if has_business_context and has_scenarios and has_procedures:
                    status = "✅ Complete"
                elif has_business_context or has_scenarios:
                    status = "🔶 Partial"
                    
                print(f"{xml_file.stem:<20} {status}")
            else:
                print(f"{xml_file.stem:<20} ❌ Missing")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Manual Management Tool")
    parser.add_argument('action', choices=['interactive', 'status'], 
                       help='Action to perform')
    
    args = parser.parse_args()
    
    manager = ManualManager("/home/drus/workspace/parametrizacion_emaku_jbe")
    
    if args.action == 'interactive':
        manager.interactive_manual_builder()
    elif args.action == 'status':
        manager.list_manuals_status()