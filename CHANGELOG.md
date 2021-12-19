# Changelog
## v3.0.1
19 December 2021
*   IMPROVED: Add helptext for custom actions and scripts about Apprise notification library

## v3.0.0
28 August 2021

*   NEW: Notifications and integrations
*   NEW: Changelog displayed when updating
*   NEW: New-look WebUI page

**Notifications and Integrations**

Currently, supported mechanisms for notifications/integrations are:
*   Email
*   Discord webhook (https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks)
*   Pushover (https://pushover.net/)
*   Custom actions (write your own scripts to do whatever you'd like)
*   Healthcheck monitoring (https://healthchecks.io/)
*   InfluxDB data export (if you already run InfluxDB, you can push connmon data to it and visualize it in Grafana, for example)

There are 4 events which trigger the notifications:
*   On each ping test
*   Ping threshold exceeded
*   Jitter threshold exceeded
*   Line Quality threshold exceeded

**Email configuration**

connmon v3.0.0 marks a move to a standalone email configuration that can be utilised by other scripts. If you have Diversion installed, connmon will detect this and migrate Diversion's config to the new standalone location with is /jffs/addons/amtm/mail
connmon will create links for Diversion to follow the configuration to the above location.

## v2.11.7
4 August 2021

*   CHANGED: service-event hook is more selective when it calls connmon

## v2.11.6
23 June 2021

*   FIXED: WebUI charts using Day grouping wouldn't display data between midnight and 1am
*   FIXED: Database reset would incorrectly report disk space availability

## v2.11.5
20 June 2021

*   NEW: Automatic database analysis after adding new results and pruning old records

## v2.11.4
30 May 2021

*   IMPROVED: Line quality calculation - credit @waluwaz
*   FIXED: min/max for zoom/pan of charts

## v2.11.3
28 April 2021

*   NEW: WebUI toggle (cookie) for changing column order of Last X table

## v2.11.2
25 April 2021

*   NEW: Setting to choose whether to include ping tests in QoS or not
*   IMPROVED: Show IP used for test when using a domain to ping
*   IMPROVED: Show placeholder text in WebUI while data is loading

## v2.11.1
24 April 2021
*   FIXED: Installing for the first time would hang

## v2.11.0
22 April 2021

*   NEW: Configure how long data is kept in the database
*   NEW: Configure how many recent results are displayed in the WebUI
*   NEW: Ping target/destination and ping duration are now logged alongside ping test results
*   IMPROVED: CPU intensive tasks are now run with a lower priority to minimise hogging the CPU
*   IMPROVED: Recent ping results table in WebUI is now sortable and scrollable

## v2.10.0
17 April 2021

*   NEW: Choice of data aggregation for charts in WebUI: raw, hourly and daily
*   IMPROVED: Use of keyboard keys d,r,l,f for chart functions (drag zoom, reset zoom, toggle lines, toggle fill)
*   IMPROVED: Use of indexes in database for small performance increases
*   IMPROVED: Use ajax to load dependent files in WebUI to avoid complete page load failures if a file was unavailable
*   IMPROVED: Stale connmon processes will be cleared on each ping test
*   REMOVED: Setting toggle for raw vs. average

## v2.9.1
24 March 2021

*   FIXED: Saving schedule from WebUI
*   FIXED: Collapsing headers in WebUI after running a ping test
*   CHANGED: Cookie expiry for collapsed section increase from 31 days to 10 years

## v2.9.0
23 March 2021

*   NEW: Option to turn automatic ping tests on/off
*   NEW: CLI menu shows URL for WebUI page
*   NEW: CLI commands for about and help
*   IMPROVED: Scheduling of automatic ping tests is now much more flexible
*   IMPROVED: Update function now includes a prompt rather than applying update
*   IMPROVED: Use colours in CLI menu to highlight settings
*   CHANGED: NTP timeout increased to 10 minutes

## v2.8.5
6 March 2021

*   NEW: Add option to reset database (CLI menu only)
*   CHANGED: Allow ping frequency maximum to be every 30 minutes (up from 10)
*   CHANGED: Exclude pings from QoS instead of marking as default
*   FIXED: Print correct test length at CLI

## v2.8.4
13 February 2021

*   IMPROVED: WebUI tab mounting on reboot

## v2.8.3
20 January 2021

*   FIXED: Logarithmic scale wasn't being formatted correctly

## v2.8.2
18 January 2021

*   NEW: Option to display charts with a logarithmic scale on y-axis
*   CHANGED: Charts now use values at 2 decimal places instead of 3
*   IMPROVED: Export now produces a csv rather than a zip
*   FIXED: Last X table can now be collapsed and expanded

## v2.8.1
14 January 2021

*   CHANGED: connmon now launches on boot from post-mount not services-start

## v2.8.0
22 November 2020

*   NEW: Add WebUI table for last 10 ping tests
*   NEW: Show result of manual ping test in WebUI
*   NEW: Configure which hours connmon should run
*   IMPROVED: CSV export has been condensed to a combined csv with all available metrics
*   CHANGED: Use 7za instead of 7z (MIPS fix)
*   CHANGED: Rename Packet_Loss column in db to LineQuality to reflect actual stored values

## v2.7.1
7 November 2020

*   IMPROVED: Run ping test in WebUI with progress shown (via Ajax)

## v2.7.0
24 October 2020

*   NEW: All connmon options can be configured in the WebUI
*   NEW: Ping test duration and frequency is now user configurable
*   CHANGED: WebUI check for updates no longer needs a page refresh (thanks to @dave14305 !)
*   CHANGED: WebUI tab name is now connmon and not Uptime Monitoring
*   IMPROVED: Reduced use of lock files to make script more responsive from the WebUI
