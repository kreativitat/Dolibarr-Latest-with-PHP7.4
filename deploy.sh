#!/bin/bash
# Deployment script for Dolibarr on bizserver

SERVER="kreativitat@bizserver"
REMOTE_DIR="/home/kreativitat/dolibarr-setup"
DATA_DIR="/home/kreativitat/data"

echo "==================================="
echo "Dolibarr Deployment Script"
echo "==================================="

# Step 1: Copy files to server
echo ""
echo "Step 1: Copying files to server..."
ssh $SERVER "mkdir -p $REMOTE_DIR"
rsync -avz --exclude 'data/' --exclude '.git/' ./ $SERVER:$REMOTE_DIR/

# Step 2: Create data directories on server
echo ""
echo "Step 2: Creating data directories..."
ssh $SERVER "mkdir -p $DATA_DIR/{html,documents,database,backup,custom,duplicati}"

# Step 3: Verify directories
echo ""
echo "Step 3: Verifying directories..."
ssh $SERVER "ls -la $DATA_DIR/"

# Step 4: Deploy Docker stack
echo ""
echo "Step 4: Starting Docker services..."
ssh $SERVER "cd $REMOTE_DIR && docker-compose down && docker-compose up -d --build"

# Step 5: Check status
echo ""
echo "Step 5: Checking service status..."
ssh $SERVER "cd $REMOTE_DIR && docker-compose ps"

echo ""
echo "==================================="
echo "Deployment complete!"
echo "==================================="
echo ""
echo "Access your services at:"
echo "  Dolibarr:    http://bizserver:8081"
echo "  PHPMyAdmin:  http://bizserver:8082"
echo "  VS Code:     http://bizserver:8083"
echo "  Duplicati:   http://bizserver:8085"
echo ""
echo "Data is stored in: /home/kreativitat/data/"
echo ""
