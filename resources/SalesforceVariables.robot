*** Variables ***
# --- Credentials (override via CLI: --variable SALESFORCE_USERNAME:you@org.com) ---
${SALESFORCE_USERNAME}        dineshv3@gmail.com
${SALESFORCE_PASSWORD}        AdarshChak@27_00
# Security token is appended to password when logging in from an untrusted IP.
# Leave empty if your org uses IP whitelisting or SSO.
${SALESFORCE_SECURITY_TOKEN}  ${EMPTY}

# --- URLs ---
${SALESFORCE_LOGIN_URL}       https://adarsh-academy-dev-ed.my.salesforce.com/
# Set to https://test.salesforce.com for sandboxes
${SALESFORCE_ENV_URL}         https://adarsh-academy-dev-ed.my.salesforce.com/

# --- Browser ---
${BROWSER}                    chrome
${HEADLESS}                   ${FALSE}

# --- Timeouts ---
${TIMEOUT_SHORT}              10s
${TIMEOUT_LONG}               30s
