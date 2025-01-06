#!/bin/bash

# Create a temporary file for the plugin block
cat <<EOT > rewrite-plugin.xml
        <plugin>
            <groupId>org.openrewrite.maven</groupId>
            <artifactId>rewrite-maven-plugin</artifactId>
            <version>4.45.0</version>
            <configuration>
                <activeRecipes>
                    <recipe>org.openrewrite.java.migrate.UpgradeToJava17</recipe>
                </activeRecipes>
            </configuration>
        </plugin>
EOT

for dir in */; do
    service_dir="${dir%/}"

    echo "Processing $service_dir..."

    if [ -f "$service_dir/pom.xml" ]; then
        echo "Adding OpenRewrite plugin to $service_dir/pom.xml"

        # Insert the content of the temporary file into the pom.xml
        sed -i "/<\/plugins>/r rewrite-plugin.xml" "$service_dir/pom.xml"

        echo "OpenRewrite plugin added to $service_dir/pom.xml"

        # Run OpenRewrite plugin
        (cd "$service_dir" && mvn rewrite:run)
    else
        echo "No pom.xml found in $service_dir. Skipping..."
    fi
done

# Cleanup the temporary file
rm rewrite-plugin.xml