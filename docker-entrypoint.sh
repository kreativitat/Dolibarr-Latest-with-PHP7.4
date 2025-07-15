#!/bin/bash
set -e

echo "Starting Dolibarr with PHP 7.4..."

# Set up cron jobs
echo "Setting up cron jobs..."
echo '*/5 * * * * www-data php /var/www/html/scripts/cron/cron_run_jobs.php tBR6eHjwyG7Z5v512Fs349OrDMrWk5tY DeGema_Bot > /dev/null 2>&1' > /etc/cron.d/dolibarr-cron
echo '42 3 * * * www-data php /var/www/html/custom/dolisync/api/cronjob.php > /dev/null 2>&1' >> /etc/cron.d/dolibarr-cron
chmod 0644 /etc/cron.d/dolibarr-cron
crontab /etc/cron.d/dolibarr-cron

# Start cron service
service cron start

# Ensure proper permissions
chown -R www-data:www-data /var/www/html
chown -R www-data:www-data /var/www/documents

echo "Cron jobs configured:"
echo "- Every 5 minutes: Dolibarr cron_run_jobs.php"
echo "- Daily at 3:42 AM: DolSync cronjob.php"
echo "PHP 7.4 - No deprecation warnings!"

# Debug: Show directory contents
echo "Contents of /var/www/html:"
ls -la /var/www/html/ | head -10

echo "Contents of custom folder:"
ls -la /var/www/html/custom/ 2>/dev/null || echo "Custom folder not found"

# Start Apache
exec "$@"