#!/usr/bin/env bash

set -euo pipefail

OUTPUT_DIR="/var/www/html/viikko3"
GITHUB_URL="https://github.com/DeveMike/Bash-and-a-Server-Status-Report-Linux"

WARNING_LIMIT=80

get_disk_status() {
    local usage="$1"
    if [ "$usage" -ge "$WARNING_LIMIT" ]; then
        echo "WARNING"
    else
        echo "OK"
    fi
}

GENERATED_AT="$(date '+%d.%m.%Y %H:%M:%S %Z')"
UPTIME_TEXT="$(uptime -p)"
DISK_PERCENT="$(df -P / | awk 'NR == 2 {print $5}' | tr -d '%')"
DISK_STATUS="$(get_disk_status "$DISK_PERCENT")"
DISK_USAGE="$DISK_PERCENT %"
MEM_TOTAL="$(free -m | awk '/^Mem:/ {print $2}')"
MEM_AVAILABLE="$(free -m | awk '/^Mem:/ {print $7}')"

TEMP_FILE="$(mktemp "$OUTPUT_DIR/.index.XXXXXX")"

cat > "$TEMP_FILE" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Week 3 – Server Status Report</title>
    <style>
        body {
            font-family: "Courier New", monospace;
            max-width: 900px;
            margin: 40px auto;
            padding: 0 20px;
            line-height: 1.6;
            background: #000000;
            color: #00ff41;
        }

        h1, h2, h3 {
            color: #00ff41;
            text-shadow: 0 0 8px #00ff41;
        }

        section {
            margin: 24px 0;
            padding: 24px;
            background: #0a0f0a;
            border: 1px solid #00ff41;
            border-radius: 12px;
        }

        .table-container {
            overflow-x: auto;
        }

        table {
            border-collapse: collapse;
            width: 100%;
        }

        th, td {
            border: 1px solid #008f11;
            padding: 12px;
            text-align: left;
        }

        th {
            background: #003b00;
        }

        code {
            background: #003b00;
            padding: 2px 5px;
            border-radius: 4px;
            overflow-wrap: anywhere;
        }

        a {
            color: #7fff00;
        }

        .note {
            color: #008f11;
        }
    </style>
</head>
<body>
    <header>
        <h1>Server Status Report</h1>
        <p>Week 3: Linux command line and Bash scripting</p>
        <p>This is an automatically updated server status report running on an Ubuntu Linux virtual machine in CSC cPouta, created by DeveMike.</p>
    </header>

    <section>
        <h2>Current server status</h2>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th scope="col">Information</th>
                        <th scope="col">Value</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <th scope="row">Report generated</th>
                        <td>$GENERATED_AT</td>
                    </tr>
                    <tr>
                        <th scope="row">Server uptime</th>
                        <td>$UPTIME_TEXT</td>
                    </tr>
                    <tr>
                        <th scope="row">Root filesystem disk usage</th>
                        <td>$DISK_USAGE</td>
                    </tr>
                    <tr>
                        <th scope="row">Disk space status</th>
                        <td>$DISK_STATUS</td>
                    </tr>
                    <tr>
                        <th scope="row">Total RAM</th>
                        <td>$MEM_TOTAL MiB</td>
                    </tr>
                    <tr>
                        <th scope="row">Available RAM</th>
                        <td>$MEM_AVAILABLE MiB</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <p>
            Disk space status is <strong>OK</strong> below 80% usage
            and <strong>WARNING</strong> at 80% or above.
        </p>

        <p class="note">
            Bash generates this report once per minute.
            Wait approximately 1–2 minutes and reload the page
            to see a new generation time.
        </p>
    </section>

    <section>
        <h2>Commands used</h2>
        <ul>
            <li>
                <code>date</code>:
                displays the current date, time and time zone
                using the format specified in the script.
            </li>
            <li>
                <code>uptime -p</code>:
                displays how long the server has been running.
            </li>
            <li>
                <code>df -P / | awk 'NR == 2 {print &#36;5}'</code>:
                passes filesystem information to awk, which extracts
                the usage percentage from the second row.
            </li>
            <li>
                <code>free -m</code>:
                displays memory information in mebibytes (MiB).
            </li>
        </ul>
    </section>

    <section>
        <h2>How the script works</h2>
        <p>
            The script collects server information using Linux commands
            and stores the results in Bash variables through command
            substitution. A function uses an if statement to determine
            the disk space status.
        </p>
        <p>
            The script generates a temporary HTML file and then moves
            the completed file into place as index.html.
            Nginx serves this file at /viikko3/.
        </p>
        <p>
          The get_disk_status function takes the disk usage percentage and calls it usage. If usage is greater than or equal to WARNING_LIMIT (80), it prints WARNING. Otherwise it prints OK.</p>
        <p>
          Example of piping: <code>df -P / | awk 'NR == 2 {print &#36;5}' | tr -d '%'</code>. df -P / shows disk usage of the root filesystem in a fixed POSIX format. awk picks the fifth column from the second row, and tr removes the percent sign, because the if statement can only compare whole numbers.
        </p>
    </section>

    <section>
        <h2>Scheduling</h2>
          <p>
	    I used cron. The schedule * * * * * means minute, hour, day, month and weekday, and a star means “every”, so the script runs every minute. The output is appended to a log file. The schedule continues after a reboot because the cron service is enabled and starts automatically at boot. 
	  </p>
    </section>

    <section>
        <h2>Test results</h2>

        <h3>Syntax check and manual execution</h3>
        <p>
            <p><code>bash -n report.sh</code> reads the script and checks that the syntax is correct without running it. It found no errors and printed Syntax OK. When I ran <code>./report.sh</code> manually, it printed a log line (for example 14.11.2026 17:15:13 EET levy 4 % OK) and created index.html, and the new report was visible in the browser.</p>
        </p>

        <h3>Disk space status tests</h3>
        <p>
            <p>I tested the status logic by temporarily adding a line <code>DISK_PERCENT=50</code> right after the df line, before the status is calculated. I ran the script, then changed the value to 80 and 90. Finally I removed the test line, and the real value (4 %, OK) was restored.</p>
        </p>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th scope="col">Test input</th>
                        <th scope="col">Expected status</th>
                        <th scope="col">Actual status</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>50%</td>
                        <td>OK</td>
                        <td>OK</td>
                    </tr>
                    <tr>
                        <td>80%</td>
                        <td>WARNING</td>
                        <td>WARNING</td>
                    </tr>
                    <tr>
                        <td>90%</td>
                        <td>WARNING</td>
                        <td>WARNING</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <h3>Automatic updates</h3>
        <p>
            The log showed two consecutive automatic updates at 17:37:01 and 17:38:01, so the report is updated every minute.
        </p>

        <h3>Reboot test</h3>
        <p>
            Before the reboot I ran <code>tail -n 2 ~/viikko3-report.log</code> to see the last log lines and wrote down the last update before the reboot (17:42:01). I checked the current uptime with <code>uptime -p</code> and restarted the VM with <code>sudo reboot</code> at about 17:43, which closed the SSH connection.
        </p>
         <p>
	    After about a minute I logged in again. <code>uptime -p</code> showed "up 1 minute", so the machine had restarted. <code>systemctl is-active nginx cron viikko2 mariadb</code> printed active four times: Nginx serves the pages, cron runs the script, viikko2 is the Week 2 application and mariadb is its database. The log continued at 17:44:01 without any manual action. I also checked that both the Week 2 and Week 3 pages opened in the browser.
        </p>
    </section>

    <section>
        <h2>A problem solved or a lesson learned</h2>
        <p>At one point my script did not have the chmod and mv lines. Because of that the page did not update and temporary files were left in the folder. I added the lines and deleted the extra files.</p>
    </section>

    <footer>
        <p><a href="$GITHUB_URL">View the source code on GitHub</a></p>
    </footer>
</body>
</html>
EOF

chmod 644 "$TEMP_FILE"
mv "$TEMP_FILE" "$OUTPUT_DIR/index.html"

echo "$GENERATED_AT levy $DISK_PERCENT % $DISK_STATUS"
