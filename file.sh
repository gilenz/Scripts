#!/bin/bash

# Define the content of the pre-commit hook
read -r -d '' HOOK_CONTENT << 'EOF'
#!/bin/bash

#Read the current version from the VERSION.txt file
current_version=$(cat VERSION.txt)

# Split the version into an array using '.' as the delimiter
IFS='.' read -r -a version_parts <<< "$current_version"

# Bump the patch version (the last part of the version)
version_parts[2]=$((version_parts[2] + 1))

# If the patch version exceeds 9, reset it to 0 and bump the minor version
if [ ${version_parts[2]} -gt 9 ]; then
    version_parts[2]=0
    version_parts[1]=$((version_parts[1] + 1))
fi

# Combine the version parts back into a single string
new_version="${version_parts[0]}.${version_parts[1]}.${version_parts[2]}"

# Write the new version back to the VERSION.txt file
echo $new_version > VERSION.txt

# Add the VERSION.txt file to the commit
git add VERSION.txt

echo "Version bumped to $new_version"
EOF

# Create the pre-commit file
echo "$HOOK_CONTENT" > pre-commit

# Make the pre-commit file executable
chmod +x pre-commit

# Move the pre-commit file to the .git/hooks directory
if [ -d .git/hooks ]; then
    mv pre-commit .git/hooks/
    echo "pre-commit hook installed successfully."
else
    echo "Error: .git/hooks directory not found. Are you sure this is a Git repository?"
fi

