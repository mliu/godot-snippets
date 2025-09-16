import xml.etree.ElementTree as ET
import os

def extract_characters_from_spritesheet(input_file, output_dir="extracted_characters"):
    """
    Extract individual characters from a 12x3 spritesheet SVG.
    Each character is 16x16 pixels.
    """
    
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    # Parse the SVG file
    tree = ET.parse(input_file)
    root = tree.getroot()
    
    # SVG namespace
    ns = {'svg': 'http://www.w3.org/2000/svg'}
    
    # Grid dimensions
    grid_cols = 12
    grid_rows = 3
    char_width = 16
    char_height = 16
    
    # Extract each character
    for row in range(grid_rows):
        for col in range(grid_cols):
            # Calculate position
            x = col * char_width
            y = row * char_height
            
            # Create new SVG for this character
            new_svg = ET.Element('svg', {
                'xmlns': 'http://www.w3.org/2000/svg',
                'width': str(char_width),
                'height': str(char_height),
                'viewBox': f'0 0 {char_width} {char_height}'
            })
            
            # Create a group with transform to extract the character
            group = ET.SubElement(new_svg, 'g', {
                'transform': f'translate({-x}, {-y})'
            })
            
            # Copy all elements from original SVG
            for element in root:
                if element.tag.endswith('}svg') or element.tag == 'svg':
                    continue  # Skip nested svg elements
                group.append(element)
            
            # Create filename (row_col format, or you can customize this)
            char_number = row * grid_cols + col
            filename = f"char_{char_number:02d}_r{row}c{col}.svg"
            
            # Write the new SVG file
            output_path = os.path.join(output_dir, filename)
            new_tree = ET.ElementTree(new_svg)
            ET.indent(new_tree, space="  ", level=0)  # Pretty print
            new_tree.write(output_path, encoding='utf-8', xml_declaration=True)
    
    print(f"Extracted {grid_rows * grid_cols} characters to '{output_dir}' directory")

# Alternative version that creates a clipping mask for cleaner extraction
def extract_characters_with_clipping(input_file, output_dir="extracted_characters_clipped"):
    """
    Extract characters using SVG clipping for cleaner results.
    """
    
    os.makedirs(output_dir, exist_ok=True)
    
    tree = ET.parse(input_file)
    root = tree.getroot()
    
    grid_cols = 12
    grid_rows = 3
    char_width = 16
    char_height = 16
    
    for row in range(grid_rows):
        for col in range(grid_cols):
            x = col * char_width
            y = row * char_height
            
            # Create new SVG
            new_svg = ET.Element('svg', {
                'xmlns': 'http://www.w3.org/2000/svg',
                'width': str(char_width),
                'height': str(char_height),
                'viewBox': f'{x} {y} {char_width} {char_height}'
            })
            
            # Copy all elements from original SVG
            for element in root:
                if element.tag.endswith('}svg') or element.tag == 'svg':
                    continue
                new_svg.append(element)
            
            char_number = row * grid_cols + col
            filename = f"char_{char_number:02d}_r{row}c{col}.svg"
            
            output_path = os.path.join(output_dir, filename)
            new_tree = ET.ElementTree(new_svg)
            ET.indent(new_tree, space="  ", level=0)
            new_tree.write(output_path, encoding='utf-8', xml_declaration=True)
    
    print(f"Extracted {grid_rows * grid_cols} characters with clipping to '{output_dir}' directory")

if __name__ == "__main__":
    # Usage example
    input_file = "input.svg"  # Replace with your file path
    
    print("Choose extraction method:")
    print("1. Transform method (moves content)")
    print("2. Clipping method (changes viewBox)")
    
    choice = input("Enter 1 or 2: ").strip()
    
    if choice == "1":
        extract_characters_from_spritesheet(input_file)
    else:
        extract_characters_with_clipping(input_file)
    
    print("Done!")
