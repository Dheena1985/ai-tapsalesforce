*** Settings ***
Documentation     Salesforce login and authorization automation.
...               Override credentials at runtime:
...               robot --variable SALESFORCE_USERNAME:you@org.com --variable SALESFORCE_PASSWORD:secret tests/SalesforceLogin.robot
Resource          ../resources/SalesforceResources.robot
Library           SeleniumLibrary

Suite Setup       Open Salesforce Browser
Suite Teardown    #Close Salesforce Browser
Test Teardown     Run Keyword If Test Failed    Capture Page Screenshot    EMBED

*** Test Cases ***
Salesforce Login And Authorize With Valid Credentials
    [Documentation]    Full login flow: enter credentials, handle OAuth Allow page if present,
    ...                and verify the Lightning home page loads successfully.
    [Tags]             login    smoke    authorization

    Input Salesforce Credentials
    Submit Salesforce Login
    Sleep    10s    reason=Allow time for manual authenticator approval
    Handle Post Login Steps
    Verify Salesforce Login Success
    Click App Launcher
    Open Sales Cloud App
    Verify Sales Cloud App Opened

Salesforce Login With Invalid Credentials Should Show Error
    [Documentation]    Confirms that incorrect credentials produce an error message.
    [Tags]             login    negative

    Go To    ${SALESFORCE_ENV_URL}
    Wait Until Page Contains Element    id=username    timeout=${TIMEOUT_LONG}
    Input Text    id=username    invalid@example.com
    Input Text    id=password    wrongpassword
    Click Button    id=Login
    Login Should Fail With Message    Please check your username and password
