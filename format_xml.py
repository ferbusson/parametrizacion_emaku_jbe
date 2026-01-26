#!/usr/bin/env python3
"""
XML Formatter Script
Pretty-prints XML files with proper indentation.

Usage: python3 format_xml.py <xml_file_path>
"""

import sys
import xml.dom.minidom

def format_xml_file(file_path):
    """Parse and pretty-print an XML file in place."""
    try:
        # Parse the XML file
        dom = xml.dom.minidom.parse(file_path)

        # Pretty print with 2-space indentation
        pretty_xml = dom.toprettyxml(indent='  ')

        # Remove empty lines to keep it compact
        pretty_xml = '\n'.join([line for line in pretty_xml.split('\n') if line.strip()])

        # Write back to file
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(pretty_xml)

        print(f"Successfully formatted {file_path}")

    except Exception as e:
        print(f"Error formatting {file_path}: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 format_xml.py <xml_file_path>")
        sys.exit(1)

    file_path = sys.argv[1]
    format_xml_file(file_path)