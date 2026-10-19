#!/bin/bash
# ==============================================================================
# Script Name : reportf2b-weekly.sh
# Description : Weekly HTML defense report generator for Fail2Ban on Zimbra
# Author      : EGTA Software (Ertan Günay)
# Repository  : https://github.com/xertgun/zimbra-fail2ban
# ==============================================================================

# --- Configuration Settings ---
RECIPIENT="admin@yourdomain.com"
SENDER="EGTA Defense System <root@$(hostname -f)>"
SERVER_NAME=$(hostname -f)
REPORT_DATE=$(date +'%d/%m/%Y')

SUBJECT="[Weekly Defense Report] $SERVER_NAME - $REPORT_DATE"

# --- Report Generation and Dispatch ---
(
  echo "From: $SENDER"
  echo "To: $RECIPIENT"
  echo "Subject: $SUBJECT"
  echo "Content-Type: text/html; charset=UTF-8"
  echo ""
  echo "<html><body style=\"font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;background-color:#f4f6f9;margin:0;padding:20px;\">"
  echo "<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"background-color:#f4f6f9;padding:20px;\"><tr><td align=\"center\">"
  echo "<table width=\"650\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"background:#ffffff;border-radius:10px;box-shadow:0 4px 15px rgba(0,0,0,0.05);overflow:hidden;\">"

  # Header
  echo "  <tr><td style=\"background:linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);padding:25px;color:#fff;text-align:center;\">"
  echo "    <h2 style=\"margin:0;font-size:22px;letter-spacing:0.5px;color:#ffffff;\">🛡️ Fail2Ban Weekly Security Summary</h2>"
  echo "    <p style=\"margin:8px 0 0 0;color:#e0e0e0;font-size:13px;\"><b>Server:</b> $SERVER_NAME &nbsp;|&nbsp; <b>Date:</b> $REPORT_DATE</p>"
  echo "  </td></tr>"

  echo "  <tr><td style=\"padding:25px;\">"

  JAILS=$(fail2ban-client status 2>/dev/null | grep "Jail list" | sed 's/.*list://' | sed 's/,//g')
  
  TOTAL_ACTIVE=0
  JAIL_COUNT=0
  JAIL_HTML=""

  if [ -z "$JAILS" ]; then
      JAIL_HTML="<table width=\"100%\" cellpadding=\"15\" cellspacing=\"0\" border=\"0\" style=\"background:#e8f8f5;border:1px dashed #27ae60;border-radius:8px;\"><tr><td align=\"center\" style=\"color:#27ae60;\">"
      JAIL_HTML+="<h3 style=\"margin:0 0 5px 0;\">✨ System Stable and Secure</h3>"
      JAIL_HTML+="<p style=\"margin:0;font-size:13px;color:#555;\">No active Fail2Ban protection rules (jails) detected.</p></td></tr></table>"
  else
      for jail in $JAILS; do
          JAIL_COUNT=$((JAIL_COUNT+1))
          STATUS=$(fail2ban-client status "$jail" 2>/dev/null)
          
          CURRENT=$(echo "$STATUS" | grep "Currently banned" | sed 's/.*:[ \t]*//' | tr -d '\r')
          TOTAL=$(echo "$STATUS" | grep "Total banned" | sed 's/.*:[ \t]*//' | tr -d '\r')
          
          [[ ! "$CURRENT" =~ ^[0-9]+$ ]] && CURRENT=0
          [[ ! "$TOTAL" =~ ^[0-9]+$ ]] && TOTAL=0
          
          TOTAL_ACTIVE=$((TOTAL_ACTIVE+CURRENT))

          IP_LIST=$(echo "$STATUS" | grep "Banned IP list" | sed 's/.*list://' | sed 's/^[ \t]*//')
          read -r -a IP_ARRAY <<< "$IP_LIST"
          IP_COUNT=${#IP_ARRAY[@]}

          STATUS_BORDER="#27ae60"
          STATUS_BG="#f8f9fa"
          [ "$CURRENT" -gt 0 ] && STATUS_BORDER="#e74c3c" && STATUS_BG="#fdfefe"

          JAIL_HTML+="<table width=\"100%\" cellpadding=\"12\" cellspacing=\"0\" border=\"0\" style=\"background:$STATUS_BG;border:1px solid #e1e8ed;border-left:5px solid $STATUS_BORDER;border-radius:6px;margin-bottom:12px;\">"
          JAIL_HTML+="  <tr>"
          JAIL_HTML+="    <td>"
          JAIL_HTML+="      <table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">"
          JAIL_HTML+="        <tr>"
          JAIL_HTML+="          <td style=\"color:#2c3e50;font-size:15px;font-weight:bold;\">📌 Service: <span style=\"color:#2980b9;\">$jail</span></td>"
          JAIL_HTML+="          <td align=\"right\"><span style=\"font-size:12px;background:#e2e8f0;padding:3px 8px;border-radius:12px;color:#4a5568;\">Active: <b>$CURRENT</b> | Total: $TOTAL</span></td>"
          JAIL_HTML+="        </tr>"
          JAIL_HTML+="      </table>"

          if [ "$IP_COUNT" -gt 0 ]; then
              IP_SPAN_LIST=""
              idx=0
              for ip in "${IP_ARRAY[@]}"; do
                  if [ $idx -ge 20 ]; then
                      break
                  fi
                  if [ $((idx % 2)) -eq 0 ]; then
                      IP_STYLE="color:#1d4ed8; background:#dbeafe; padding:1px 5px; border-radius:4px; margin:2px 3px 2px 0; display:inline-block; white-space:nowrap;"
                  else
                      IP_STYLE="color:#b45309; background:#fef3c7; padding:1px 5px; border-radius:4px; margin:2px 3px 2px 0; display:inline-block; white-space:nowrap;"
                  fi
                  IP_SPAN_LIST+="<span style=\"$IP_STYLE\">$ip</span>"
                  idx=$((idx+1))
              done

              EKSTRA=""
              if [ "$IP_COUNT" -gt 20 ]; then
                  EKSTRA="<span style=\"color:#e74c3c;font-style:italic;margin-left:4px;white-space:nowrap;\">...and $((IP_COUNT-20)) more IPs</span>"
              fi

              JAIL_HTML+="      <table width=\"100%\" cellpadding=\"8\" cellspacing=\"0\" border=\"0\" style=\"margin-top:8px;\">"
              JAIL_HTML+="        <tr>"
              JAIL_HTML+="          <td style=\"background:#edf2f7;border-radius:4px;font-family:monospace;font-size:12px;color:#2d3748;\">"
              JAIL_HTML+="            <b>Banned IPs:</b><div style=\"margin-top:4px;\">$IP_SPAN_LIST$EKSTRA</div>"
              JAIL_HTML+="          </td>"
              JAIL_HTML+="        </tr>"
              JAIL_HTML+="      </table>"
          fi
          JAIL_HTML+="    </td>"
          JAIL_HTML+="  </tr>"
          JAIL_HTML+="</table>"
      done
  fi

  # Summary Bar
  echo "  <table width=\"100%\" cellpadding=\"12\" cellspacing=\"0\" border=\"0\" style=\"background:#f8fafc;border:1px solid #e2e8f0;border-radius:8px;margin-bottom:20px;text-align:center;\">"
  echo "    <tr>"
  echo "      <td width=\"50%\" style=\"border-right:1px solid #e2e8f0;\"><span style=\"font-size:12px;color:#64748b;display:block;\">MONITORED SERVICES</span><b style=\"font-size:18px;color:#1e293b;\">$JAIL_COUNT</b></td>"
  echo "      <td width=\"50%\"><span style=\"font-size:12px;color:#64748b;display:block;\">CURRENT ACTIVE BANS</span><b style=\"font-size:18px;color:$([ $TOTAL_ACTIVE -gt 0 ] && echo '#e74c3c' || echo '#27ae60');\">$TOTAL_ACTIVE</b></td>"
  echo "    </tr>"
  echo "  </table>"

  # Insert Jail HTML Content
  echo "$JAIL_HTML"

  # Footer
  echo "  <p style=\"font-size:11px;color:#94a3b8;text-align:center;margin-top:25px;border-top:1px solid #f1f5f9;padding-top:15px;\">This report was automatically generated by EGTA Defense System.</p>"
  echo "  </td></tr>"
  echo "</table>"
  echo "</td></tr></table>"
  echo "</body></html>"
) | /opt/zimbra/common/sbin/sendmail -t

if [ $? -eq 0 ]; then
    echo "Weekly e-mail report sent successfully."
else
    echo "ERROR: Failed to send e-mail report!"
fi
