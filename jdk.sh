#!/bin/bash

# Directory containing all JARs
JAR_DIR="dependencies"
OUTPUT_FILE="compatibility_report.txt"

# Packages/classes removed or moved from JDK 8 to JDK 17
REMOVED_PACKAGES=("javax.xml.bind" "javax.activation" "javax.annotation"
                  "javax.transaction" "jdk.nashorn.api" "javafx"
                  "sun.misc" "java.corba" "java.xml.ws")

echo "Compatibility Analysis Report" > $OUTPUT_FILE

# Iterate over each JAR in the directory
for JAR in "$JAR_DIR"/*.jar; do
  echo "Analyzing $JAR..." >> $OUTPUT_FILE
  jdeps -v --multi-release 17 -cp "$JAR" >> $OUTPUT_FILE 2>&1
  
  for PACKAGE in "${REMOVED_PACKAGES[@]}"; do
    if jdeps -v "$JAR" | grep -q "$PACKAGE"; then
      echo "  --> Found usage of removed/moved package: $PACKAGE" >> $OUTPUT_FILE
    fi
  done
  echo "" >> $OUTPUT_FILE
done

echo "Analysis complete. Check $OUTPUT_FILE for results."