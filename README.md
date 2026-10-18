# 🧱 Zimbra Fail2Ban Security Protection Rules
Comprehensive Fail2Ban filters, jail configuration, and automated daily email defense reporter designed to protect Zimbra Collaboration Suite (ZCS 8.8.15) against brute-force attacks, webshell/PHP scanners, command injection, and exploit attempts.
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
This repository includes `reportf2b-daily.sh`, an automated script that parses Fail2Ban logs and sends a clean, responsive HTML defense report containing:
- Ban counts grouped by Jail
- Hourly attack intensity breakdown
- Top 5 aggressive attacker IP addresses
- Total currently active banned IPs

### Setup Daily Reporter Script:
   1. Copy script and make it executable:
   ```bash
   sudo cp reportf2b-daily.sh /usr/local/bin/reportf2b-daily
   sudo chmod +x /usr/local/bin/reportf2b-daily
   ```

   2. Edit the script to configure your email address:
   ```bash
   sudo nano /usr/local/bin/reportf2b-daily
   # Change RECIPIENT="admin@yourdomain.com"
   ```

   3. Add to Root Crontab (`sudo crontab -e`) to schedule daily execution at 22:50:
   ```cron
   
   # Send Fail2Ban Daily Defense Report every night at 22:50
   50 22 * * * /usr/local/bin/reportf2b-daily > /dev/null 2>&1
   ```

## 🔗 Related Projects
- [zimbra-security-check](https://github.com/xertgun/zimbra-security-check): Daily integrity scanner & automated incident reporter for Zimbra.
