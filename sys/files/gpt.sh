#!/usr/bin/env sh

# Available agents - add more here as needed
AGENTS=$(cat <<EOF
claude
glm
EOF
)

PROJECTS_DIR="$HOME/Workspace/gpt-projects"

# Ensure projects directory exists
mkdir -p "$PROJECTS_DIR"

# Select agent
AGENT=$(echo "$AGENTS" | fzf --prompt="Select agent: " --height=10 --border) || exit 1

# Get list of existing projects
PROJECT_LIST=$(ls -1 "$PROJECTS_DIR" 2>/dev/null)

# Select project (or create new)
PROJECT=$(echo "$PROJECT_LIST
+ create new project" | fzf --prompt="Select project: " --height=15 --border) || exit 1

IS_NEW_PROJECT=false

if [ "$PROJECT" = "+ create new project" ]; then
    # Prompt for new project name
    PROJECT_NAME=$(fzf --prompt="Enter new project name: " --print-query --height=10 --border < /dev/null | head -1)

    if [ -z "$PROJECT_NAME" ]; then
        echo "No project name provided. Exiting."
        exit 1
    fi

    # Create the project directory
    mkdir -p "$PROJECTS_DIR/$PROJECT_NAME"
    PROJECT="$PROJECT_NAME"
    IS_NEW_PROJECT=true
    echo "Created new project: $PROJECT"
fi

cd "$PROJECTS_DIR/$PROJECT" || exit 1

if [ "$IS_NEW_PROJECT" = true ]; then
    $AGENT
else
    $AGENT --continue
fi
