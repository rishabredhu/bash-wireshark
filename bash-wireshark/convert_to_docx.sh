#!/bin/bash

# Script to convert analysis.txt to docx format using pandoc

# Function to convert txt to docx
convert_to_docx() {
    local input_file="wireshark_ip_lab_output/analysis.txt"
    local output_file="wireshark_ip_lab_output/analysis.docx"
    
    # Check if input file exists
    if [ ! -f "$input_file" ]; then
        echo "Error: Input file $input_file not found!"
        exit 1
    fi
    
    # Convert to docx using pandoc
    echo "Converting $input_file to DOCX format..."
    pandoc -f markdown -t docx "$input_file" -o "$output_file"
    
    if [ -f "$output_file" ]; then
        echo "Conversion complete! Output file: $output_file"
    else
        echo "Error: Conversion failed!"
        exit 1
    fi
}

# Main execution
echo "Starting conversion process..."
convert_to_docx