#!/bin/bash

# Check if docker is installed and runable by the current user
if ! command -v docker &> /dev/null
then
    echo "Docker could not be found. Please install Docker and try again."
    echo "Reference: https://docs.docker.com/engine/install/"
    echo "Try adding the current user to the docker group by running:"
    echo "sudo usermod -aG docker \$USER"
    echo "You may need to log out and back in for this to take effect."
    exit
fi

# Check if docker-compose or docker compose is installed and runable by the current user
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null
then
    echo "Neither Docker-compose v1 nor v2 could be found. Please install docker compose and try again."
    echo "Reference: https://docs.docker.com/compose/install/"
    echo "Try adding the current user to the docker group by running:"
    echo "sudo usermod -aG docker \$USER"
    echo "You may need to log out and back in for this to take effect."
    exit
fi

# Check if the 'platform' directory exists
if [ -d "platform" ]; then
  # Create a backup name with a datetime-hourminute suffix
  backup_name="platform_$(date "+%Y%m%d_%H%M")"
  echo "Directory 'platform' already exists. Backing it up as '$backup_name'."

  # Rename the existing directory to the backup name
  mv platform "$backup_name"

  echo "Backup complete. Proceeding with the installation."
fi

# Clone the repository
if ! git clone git@github.com:xqliu/platform.git; then
  echo -e ""
  echo " ------------------------------------------------------------------------- "
  echo "  Error: No access to https://github.com/xqliu/platform.git                "
  echo "  Please purchase the platform on lcdp.ai first.                           "
  echo "  If you have already purchased the platform,                              "
  echo "  Please post on https://community.lcdp.ai for us to grant you the access. "
  echo "  You need a personal access token to access the platform.                 "
  echo "  Go to https://github.com/settings/tokens?type=beta to create a token.    "
  echo " ------------------------------------------------------------------------- "
  exit 1
fi

# Change directory to the cloned repository
cd platform

# Login to the docker hub using a read-only token
cat token.txt |  docker login -u muyantech --password-stdin

mkdir -p ./runtime/database/data

# Check which version of docker-compose is installed and run the appropriate commands
if command -v docker-compose &> /dev/null
then
    # No need to build the image now
    # We will use pre-build image for both backend and frontend
    # Build the Docker image
    # docker-compose build

    # Run the Docker container in detached mode
    docker-compose up -d
elif docker compose version &> /dev/null
then
    # No need to build the image now
    # We will use pre-build image for both backend and frontend
    # Build the Docker image
    # docker compose build

    # Run the Docker container in detached mode
    docker compose up -d
fi
# Installation steps above...

# After successful installation, display the database, access information, documentation link, and login credentials
# Wait for backend service to be ready
echo "Waiting for backend service to become ready..."
while ! curl -s http://localhost:8080/actuator/health | grep -q '"status":"UP"'; do
    sleep 10
    echo "Waiting for backend service..."
done
echo "Backend service is now ready."
echo ""

# 尝试在不同的操作系统上打开默认浏览器
open_url() {
    url="$1"
    if command -v xdg-open > /dev/null 2>&1; then
        xdg-open "$url"
    elif command -v gnome-open > /dev/null 2>&1; then
        gnome-open "$url"
    elif command -v open > /dev/null 2>&1; then
        open "$url"
    else
        echo "Cannot detect the web browser to open the URL automatically. Please manually open $url"
        echo ""
    fi
}

# Open the frontend in the default browser
open_url "http://localhost:3000/start"

# Simplified success message
echo "Installation completed successfully. Your platform is now ready for use."
echo ""
echo "Access Information:"
echo "  - Frontend: http://localhost:3000/"
echo "  - Backend: http://localhost:8080/"
echo "  - Username: admin@muyan.cloud"
echo "  - Password: password"
echo ""
echo "For further details and next steps, refer to the README or visit https://docs.lcdp.ai/en/quickstart/DOCKER.html"

# Reminder to change directory for development
echo "Enjoy using the application!"
