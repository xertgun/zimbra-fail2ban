# 🧱 Zimbra Fail2Ban Security Protection Rules
Comprehensive Fail2Ban filters, jail configuration, and automated daily/weekly email defense reporters designed to protect Zimbra Collaboration Suite (ZCS 8.8.15) against brute-force attacks, webshell/PHP scanners, command injection, and exploit attempts.
> 📌 Tested & Compatible with: Zimbra Collaboration Suite 8.8.15 (ZCS 8.8.15 GA) running on Ubuntu / Debian / RHEL.

## 🛡️ Protected Modules & Attack Vectors

| Jail Name | Log Source | Vector / Protection Scope |
| :--- | :--- | :--- |
| **`zimbra-smtp`** | `/var/log/zimbra.log` | SASL authentication brute-force attacks |
| **`zimbra-web`** | `/opt/zimbra/log/mailbox.log` | Webmail & Admin Panel login brute-force attempts |
| **`zimbra-audit`** | `/opt/zimbra/log/audit.log` | Audit log authentication failures & account lockouts |
| **`zimbra-web-exploit`** | `/opt/zimbra/log/nginx.access.log` | Malicious web requests (`.jsp`, SOAP exploits, autodiscover probes) |
| **`zimbra-exploit`** | `/var/log/zimbra.log` | Illegal address syntax & header injection attempts |
| **`zimbra-cmd-injection`** | `/var/log/zimbra.log` | Postfix SMTP RCPT command injection attempts (`wget`, `curl`, `sh`) |
| **`zimbra-php-scan`** | `/opt/zimbra/log/nginx.access.log` | Automated vulnerability scanners (`phpMyAdmin`, `.php`, `.asp` probes) |

## 🚀 Installation & Setup
1. Install Fail2Ban (if not already installed)
   ```bash
   sudo apt update && sudo apt install fail2ban -y
   ```
2. Download and Copy Filter Configurations
   Clone this repository and copy the filters to Fail2Ban directory:
   ```bash
   git clone https://github.com/xertgun/zimbra-fail2ban.git
   cd zimbra-fail2ban
   ```
   Copy filters
   ```bash
   sudo cp filter.d/* /etc/fail2ban/filter.d/
   ```
   Copy jail configuration
   ```bash
   sudo cp jail.d/zimbra.local /etc/fail2ban/jail.d/
   ```

3. Customize Configuration
   Edit /etc/fail2ban/jail.d/zimbra.local to update notification settings and trusted IP addresses:
   ```bash
   sudo nano /etc/fail2ban/jail.d/zimbra.local
   ```
     - Set `ignoreip` to include your trusted IP ranges / administrative subnets.
     - Update `destemail` and `sender` addresses for email alerts.

4. Restart & Verify Fail2Ban
   Restart Fail2Ban to apply rules:
   ```bash
   sudo systemctl restart fail2ban
   sudo fail2ban-client status
   ```

## 📊 Automated Daily HTML Defense Reporter
This repository includes automated reporting scripts inside the `scripts/` directory that parse Fail2Ban logs and dispatch clean, responsive HTML defense summaries:
- `reportf2b-daily.sh`: Daily security brief containing ban counts by jail, hourly attack intensity, and top aggressive attackers.
- `reportf2b-weekly.sh`: Weekly aggregated defense summary with active/total ban statistics and formatted IP tags.

### Setup Reporting Scripts:
   1. Copy script and make it executable:
   ```bash
   sudo cp scripts/reportf2b-daily.sh /usr/local/bin/reportf2b-daily
   sudo cp scripts/reportf2b-weekly.sh /usr/local/bin/reportf2b-weekly
   sudo chmod +x /usr/local/bin/reportf2b-daily /usr/local/bin/reportf2b-weekly
   ```

   2. Edit the script to configure your email address:
   ```bash
   sudo nano /usr/local/bin/reportf2b-daily
   sudo nano /usr/local/bin/reportf2b-weekly
   ```
   ```conf
   # Change RECIPIENT="admin@yourdomain.com"
   ```

   3. Add to Root Crontab (`sudo crontab -e`) to schedule daily execution at 22:50:
   ```cron
   # Send Fail2Ban Weekly Security Summary every Monday at 09:00
   00 09 * * 1 /usr/local/bin/reportf2b-weekly > /dev/null 2>&1
   # Send Fail2Ban Daily Defense Report every night at 22:50
   50 22 * * * /usr/local/bin/reportf2b-daily > /dev/null 2>&1
   ```

## 💡 Why This Project Exists
   This project was created after multiple real-world intrusion attempts against Zimbra 8.8.15 servers.
   The default Zimbra and standard Fail2Ban configurations were not providing enough visibility against:
   - Webmail brute force
   - SOAP attacks
   - Command injection attempts
   - PHP scanner probes
   - Vulnerability scanners

This repository contains production-tested filters and reporting tools.

## 🔗 Related Projects
- [zimbra-security-check](https://github.com/xertgun/zimbra-security-check): Daily integrity scanner & automated incident reporter for Zimbra.
- [zimbra-certbot-renew](https://github.com/xertgun/zimbra-certbot-renew) - Automated Let's Encrypt SSL certificate renewal and zero-downtime deployment script for Zimbra ZCS.
