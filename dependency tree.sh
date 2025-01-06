#!/bin/bash

# Define the file to save the output CSV
output_file="dependency_tree.csv"

# Initialize the CSV file with headers
echo "Directory,Dependency,Version" > "$output_file"

# Loop through each directory in the current directory
for dir in */; do
    # Remove trailing slash to get directory name
    dir_name="${dir%/}"

    # Check if the directory contains a Maven project (pom.xml)
    if [ -f "$dir_name/pom.xml" ]; then
        echo "Processing directory: $dir_name"

        # Run Maven dependency:tree command and parse the output
        dependencies=$(cd "$dir_name" && mvn dependency:tree -DoutputType=text -q | grep -oP "(\w[\w\.\-]+):(\w[\w\.\-]+):(\w[\w\.\-]+):(\w[\w\.\-]+):(\w[\w\.\-]+)" | awk -F ':' '{print $2","$3}')

        # Save parsed dependencies to the CSV file
        while IFS= read -r line; do
            echo "$dir_name,$line" >> "$output_file"
        done <<< "$dependencies"
    else
        echo "Skipping $dir_name (no pom.xml found)"
    fi
done

echo "Dependency tree saved to $output_file"