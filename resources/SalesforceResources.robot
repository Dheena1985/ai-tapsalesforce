*** Settings ***
Resource         SalesforceVariables.robot
Library          SeleniumLibrary
Library          String

# --- Locators ---
*** Variables ***
${USERNAME_FIELD}       id=username
${PASSWORD_FIELD}       id=password
${LOGIN_BUTTON}         id=Login
${ERROR_MESSAGE}        id=error
${VERIFY_EMAIL_HEADER}  xpath=//h1[contains(text(),'Check Your Email') or contains(text(),'Verify Your Identity')]
${AUTH_ALLOW_BUTTON}    xpath=//input[@value='Allow'] | //button[normalize-space()='Allow'] | //a[normalize-space()='Allow']
${HOME_INDICATOR}       xpath=//*[contains(@class,'oneAppViewport') or contains(@class,'slds-global-header') or contains(@class,'homeTab')]
${APP_LAUNCHER_BUTTON} xpath=//button[@title='App Launcher' or contains(@aria-label,'App Launcher')]//svg | //button[contains(@aria-label,'App Launcher')]//use
${APP_LAUNCHER_PANEL}  xpath=//div[contains(@class,'app-launcher') or contains(@class,'appLauncher')]
${APP_LAUNCHER_SEARCH} xpath=//input[contains(@placeholder,'Search apps') or contains(@placeholder,'Search items') or @type='search']
${SALES_CLOUD_TILE} xpath=//span[normalize-space()='Sales' or normalize-space()='Sales Cloud'] | //a[.//span[normalize-space()='Sales' or normalize-space()='Sales Cloud']]
${SALES_CLOUD_APP_INDICATOR} xpath=//span[normalize-space()='Sales' or normalize-space()='Sales Cloud'] | //h1[contains(normalize-space(),'Sales') or contains(normalize-space(),'Sales Cloud')]

*** Keywords ***

# ---------------------------------------------------------------------------
# Browser lifecycle
# ---------------------------------------------------------------------------
Open Salesforce Browser
    [Documentation]    Opens Chrome and navigates to the login URL. Uses Selenium Manager to auto-download ChromeDriver.
    ${options}=    Evaluate    __import__('selenium').webdriver.ChromeOptions()
    Run Keyword If    ${HEADLESS}    Call Method    ${options}    add_argument    --headless=new
    Call Method    ${options}    add_argument    --disable-notifications
    Call Method    ${options}    add_argument    --disable-infobars
    Open Browser    ${SALESFORCE_ENV_URL}    browser=Chrome    options=${options}
    Maximize Browser Window
    Set Selenium Timeout    ${TIMEOUT_SHORT}
    Set Selenium Implicit Wait    2s
    Wait Until Page Contains Element    ${USERNAME_FIELD}    timeout=${TIMEOUT_LONG}

Close Salesforce Browser
    Capture Page Screenshot    EMBED
    Close All Browsers

# ---------------------------------------------------------------------------
# Login flow
# ---------------------------------------------------------------------------
Input Salesforce Credentials
    [Documentation]    Types username and password (with optional security token appended).
    ${full_password}=    Catenate    SEPARATOR=    ${SALESFORCE_PASSWORD}    ${SALESFORCE_SECURITY_TOKEN}
    Input Text    ${USERNAME_FIELD}    ${SALESFORCE_USERNAME}
    Input Text    ${PASSWORD_FIELD}    ${full_password}

Submit Salesforce Login
    [Documentation]    Clicks the Login button and waits for post-login navigation.
    Click Button    ${LOGIN_BUTTON}
    # Salesforce may redirect through several pages before reaching home
    Sleep    2s    reason=Allow redirect chain to start

Handle Post Login Steps
    [Documentation]    Deals with any intermediate pages: identity verification prompt or OAuth Allow page.
    ${identity_visible}=    Run Keyword And Return Status
    ...    Wait Until Page Contains Element    ${VERIFY_EMAIL_HEADER}    timeout=20s
    Run Keyword If    ${identity_visible}    Log    Identity verification prompt detected — manual step required or use a trusted IP    WARN

    ${allow_visible}=    Run Keyword And Return Status
    ...    Wait Until Page Contains Element    ${AUTH_ALLOW_BUTTON}    timeout=20s
    Run Keyword If    ${allow_visible}    Authorize Connected App

Authorize Connected App
    [Documentation]    Clicks the Allow button on the Salesforce OAuth authorization page.
    Log    Salesforce authorization page detected — clicking Allow
    Click Element    ${AUTH_ALLOW_BUTTON}
    Wait Until Page Does Not Contain Element    ${AUTH_ALLOW_BUTTON}    timeout=${TIMEOUT_LONG}

Verify Salesforce Login Success
    [Documentation]    Confirms the Salesforce home/Lightning shell is loaded.
    Wait Until Page Contains Element    ${HOME_INDICATOR}    timeout=${TIMEOUT_LONG}
    ${url}=    Get Location
    Should Not Contain    ${url}    /login    msg=Still on login page — authentication may have failed
    Log    Login successful. Current URL: ${url}

Click App Launcher
    [Documentation]    Opens the Salesforce App Launcher from the Lightning header.
    Wait Until Page Contains Element    ${APP_LAUNCHER_BUTTON}    timeout=${TIMEOUT_LONG}
    Click Element    ${APP_LAUNCHER_BUTTON}
    Wait Until Page Contains Element    ${APP_LAUNCHER_PANEL}    timeout=${TIMEOUT_LONG}
    Log    App Launcher opened successfully.

Open Sales Cloud App
    [Documentation]    Searches the App Launcher for Sales Cloud and opens it.
    Wait Until Page Contains Element    ${APP_LAUNCHER_SEARCH}    timeout=${TIMEOUT_LONG}
    Input Text    ${APP_LAUNCHER_SEARCH}    Sales
    Sleep    1s    reason=Allow app launcher search results to populate
    Wait Until Page Contains Element    ${SALES_CLOUD_TILE}    timeout=${TIMEOUT_LONG}
    Click Element    ${SALES_CLOUD_TILE}
    Wait Until Page Does Not Contain Element    ${APP_LAUNCHER_PANEL}    timeout=${TIMEOUT_LONG}
    Log    Sales Cloud opened successfully.

Verify Sales Cloud App Opened
    [Documentation]    Confirms the Sales Cloud application is loaded after selection.
    Wait Until Page Contains Element    ${SALES_CLOUD_APP_INDICATOR}    timeout=${TIMEOUT_LONG}
    ${url}=    Get Location
    Should Contain    ${url}    /lightning    msg=Sales Cloud did not load in a Lightning page
    Log    Sales Cloud application verified successfully. Current URL: ${url}

# ---------------------------------------------------------------------------
# Error helpers
# ---------------------------------------------------------------------------
Login Should Fail With Message
    [Arguments]    ${expected_message}
    Wait Until Page Contains Element    ${ERROR_MESSAGE}    timeout=${TIMEOUT_SHORT}
    ${actual}=    Get Text    ${ERROR_MESSAGE}
    Should Contain    ${actual}    ${expected_message}
