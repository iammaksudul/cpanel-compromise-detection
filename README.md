# cPanel Compromise Detection Script

This script scans all cPanel accounts on a server to detect potential signs of compromise. It checks Apache logs, `.htaccess` files, SSH logs, cron jobs, and other critical areas of the server for suspicious activity. When any potential compromise is detected, it logs the activity and sends an email notification to the administrator.

## Features

- **Checks Apache Logs**: Looks for suspicious activity such as `POST` requests or `eval()` function calls in Apache logs.
- **Monitors `.htaccess` File**: Scans `.htaccess` files for malicious redirects or PHP configurations.
- **Scans SSH Logs**: Looks for failed login attempts for each user in `/var/log/secure`.
- **Scans cPanel and WHM Logs**: Detects failed login attempts from the cPanel or WHM logs.
- **Cron Jobs Monitoring**: Scans for unusual cron jobs associated with cPanel users.
- **Suspicious File Creation**: Detects any files created in the last 7 days, which might indicate unauthorized activity.
- **Email Alerts**: Sends email notifications to the system administrator when suspicious activity is detected for any user.
- **Logging**: Logs suspicious activity to `/var/log/cpanel-compromise-detection.log` for auditing.

## Prerequisites

Ensure you have the following before running the script:

- **Root access** to the server.
- **Sendmail** or another mail transfer agent (MTA) configured to send emails.
- **Basic knowledge of Linux and cPanel administration**.
  
## Installation

### 1. Clone or download this repository:

```bash
git clone https://github.com/your-username/cpanel-compromise-detection.git
cd cpanel-compromise-detection
```

### 2. Make the script executable:

```bash
chmod +x cpanel-compromise-detection.sh
```

### 3. Configure Email Address

Ensure that the `ADMIN_EMAIL` variable in the script is set to the email address that should receive notifications about compromised accounts.

```bash
ADMIN_EMAIL="your-email@domain.com"
```

### 4. Run the script

Execute the script with root privileges:

```bash
sudo ./cpanel-compromise-detection.sh
```

The script will scan all cPanel accounts and notify the administrator about any potential compromises detected.

## Configuration After Setup

### 1. Modify Email Settings:

You can modify the email notification settings directly within the script. Ensure your server is properly configured to send emails using `sendmail` or another MTA of your choice.

### 2. View Logs:

You can check the logs for suspicious activities in `/var/log/cpanel-compromise-detection.log`.

### 3. Review Notifications:

Check your email inbox for alerts about compromised accounts. You will receive an email whenever suspicious activity is detected on any cPanel account.

## Troubleshooting

- **Failed Email Notifications**: Ensure the server's mail system is configured correctly. You can test email functionality by sending a test email via `sendmail` or `mail` command.
  
  ```bash
  echo "Test" | sendmail admin@yourdomain.com
  ```

- **Access Logs Not Found**: If the script can't find the Apache logs or other log files, ensure that the log paths are correct and the necessary services are running on the server.

## Customize Script

You can customize the script for your own needs:

- **PHP Version Check**: Add checks for specific PHP versions if needed.
- **Additional File Scans**: Customize the list of directories to scan for suspicious files or logs.
  
## License

This script is open-source and available under the **MIT License**. Feel free to fork, modify, and redistribute it as needed.

---

## Hire Me as a DevOps Engineer

If you need a professional DevOps engineer to manage and optimize your server infrastructure, I am available for hire! 

Check out my portfolio and get in touch:

[**Hire Me - Kh Maksudul Alam**](https://www.maksudulalam.com/)


