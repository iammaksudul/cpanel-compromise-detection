#!/bin/bash

# Email address to notify about compromised accounts
ADMIN_EMAIL="admin@yourdomain.com"

# Log file for suspicious activity
LOG_FILE="/var/log/cpanel-compromise-detection.log"

# Function to send email notification
send_email_notification() {
    compromised_user=$1
    echo -e "Subject: WARNING: Potential Compromise Detected on cPanel Account - $compromised_user\n\nThe cPanel account $compromised_user has been flagged for suspicious activity. Please review the logs immediately." | sendmail $ADMIN_EMAIL
}

# Function to log suspicious activity
log_suspicious_activity() {
    compromised_user=$1
    echo "$(date) - Suspicious activity detected for $compromised_user" >> $LOG_FILE
}

echo "Starting scan for all cPanel accounts..."

# Get the list of all cPanel users from the system
CPANEL_USERS=$(ls /var/cpanel/users/)

# Loop through each user account
for USER in $CPANEL_USERS; do
    echo "Checking account: $USER"
    compromised=false

    # Check Apache access logs for suspicious activity
    ACCESS_LOG="/usr/local/apache/domlogs/$USER"
    if [ -f "$ACCESS_LOG" ]; then
        echo "Checking Apache access logs..."
        suspicious_access=$(grep -i "POST" "$ACCESS_LOG" | tail -n 20)
        suspicious_eval=$(grep -i "eval(" "$ACCESS_LOG" | tail -n 20)
        
        if [ ! -z "$suspicious_access" ] || [ ! -z "$suspicious_eval" ]; then
            echo "Suspicious access found in Apache logs for user $USER."
            compromised=true
        fi
    else
        echo "No Apache access logs found for user $USER."
    fi

    # Check for suspicious files in the public_html directory
    PUBLIC_HTML_DIR="/home/$USER/public_html"
    if [ -d "$PUBLIC_HTML_DIR" ]; then
        echo "Checking public_html directory for suspicious files..."
        suspicious_php_files=$(find "$PUBLIC_HTML_DIR" -type f -name "*.php" -exec grep -l "eval(" {} \;)
        
        if [ ! -z "$suspicious_php_files" ]; then
            echo "Suspicious PHP files found in $USER's public_html directory."
            compromised=true
        fi
    else
        echo "No public_html directory found for user $USER."
    fi

    # Check for modified .htaccess file
    HTACCESS_FILE="/home/$USER/public_html/.htaccess"
    if [ -f "$HTACCESS_FILE" ]; then
        echo "Checking .htaccess file for suspicious redirects or malware..."
        suspicious_redirects=$(grep -i "Redirect" "$HTACCESS_FILE")
        suspicious_php_value=$(grep -i "php_value" "$HTACCESS_FILE")
        
        if [ ! -z "$suspicious_redirects" ] || [ ! -z "$suspicious_php_value" ]; then
            echo "Suspicious entries found in .htaccess for user $USER."
            compromised=true
        fi
    else
        echo "No .htaccess file found for user $USER."
    fi

    # Check for unauthorized access attempts in the secure log
    SECURE_LOG="/var/log/secure"
    if [ -f "$SECURE_LOG" ]; then
        echo "Checking /var/log/secure for unauthorized access attempts for user $USER..."
        unauthorized_ssh=$(grep "$USER" "$SECURE_LOG" | grep "Failed password")
        
        if [ ! -z "$unauthorized_ssh" ]; then
            echo "Unauthorized SSH access attempts detected for user $USER."
            compromised=true
        fi
    else
        echo "No secure log found."
    fi

    # Check for unusual WHM access
    WHM_LOG="/usr/local/cpanel/logs/access_log"
    if [ -f "$WHM_LOG" ]; then
        echo "Checking WHM logs for suspicious activity for user $USER..."
        suspicious_whm_login=$(grep "$USER" "$WHM_LOG" | grep "login failed")
        
        if [ ! -z "$suspicious_whm_login" ]; then
            echo "Suspicious login attempts found in WHM logs for user $USER."
            compromised=true
        fi
    else
        echo "No WHM log found."
    fi

    # Check for cron jobs that may be suspicious
    CRON_DIR="/var/spool/cron"
    if [ -f "$CRON_DIR/root" ]; then
        suspicious_cron_jobs=$(grep "$USER" "$CRON_DIR/root")
        
        if [ ! -z "$suspicious_cron_jobs" ]; then
            echo "Suspicious cron jobs found for user $USER."
            compromised=true
        fi
    fi

    # Check for unusual file creation in the user's directory
    RECENT_FILES=$(find /home/$USER -type f -mtime -7)
    if [ ! -z "$RECENT_FILES" ]; then
        echo "Recent files created in the $USER's directory."
        compromised=true
    fi

    # If any suspicious activity is found, flag the account as compromised
    if $compromised; then
        echo "Account $USER has been flagged as potentially compromised!"
        log_suspicious_activity "$USER"
        send_email_notification "$USER"
    else
        echo "No suspicious activity detected for user $USER."
    fi
    echo "-----------------------------------"
done

echo "Scan completed!"
