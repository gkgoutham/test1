#!/bin/bash

# Specify the OpenRewrite plugin XML block
rewrite_plugin="
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
"

# Iterate over each service directory
for dir in */; do
    # Remove trailing slash from directory name
    service_dir="${dir%/}"

    echo "Processing $service_dir..."

    # Check if the pom.xml exists
    if [ -f "$service_dir/pom.xml" ]; then
        # Add the OpenRewrite plugin to the pom.xml
        sed -i "/<\/plugins>/i $rewrite_plugin" "$service_dir/pom.xml"

        echo "Added OpenRewrite plugin to $service_dir/pom.xml"

        # Run OpenRewrite to apply the JDK upgrade recipe
        (cd "$service_dir" && mvn rewrite:run)
    else
        echo "No pom.xml found in $service_dir. Skipping..."
    fi
done

echo "All services processed. Check the results."