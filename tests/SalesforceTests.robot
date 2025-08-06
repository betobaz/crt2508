# NOTE: readme.txt contains important information you need to take into account
# before running this suite.

*** Settings ***
Resource                        ../resources/common.robot
Suite Setup                     Setup Browser
Suite Teardown                  End suite


*** Test Cases ***
Entering A Lead
    [tags]                      Lead
    Appstate                    Home
    LaunchApp                   Sales
    ClickText                   Leads
    VerifyText                  Change Owner
    ClickText                   New
    VerifyText                  Lead Information
    UseModal                    On                          # Only find fields from open modal dialog

    Picklist                    Salutation                  Ms.
    TypeText                    First Name                  Tina
    TypeText                    Last Name                   Smith
    Picklist                    Lead Status                 New
    # generate random phone number, just as an example
    # NOTE: initialization of random number generator is done on suite setup
    ${rand_phone}=              Generate Random String      14                          [NUMBERS]
    # concatenate leading "+" and random numbers
    ${phone}=                   SetVariable                 +${rand_phone}
    TypeText                    Phone                       ${phone}                    First Name
    TypeText                    Company                     Growmore                    Last Name
    TypeText                    Title                       Manager                     Address Information
    TypeText                    Email                       tina.smith@gmail.com        Rating
    TypeText                    Website                     https://www.growmore.com/

    Picklist                    Lead Source                 Partner
    ClickText                   Save                        partial_match=False
    UseModal                    Off
    Sleep                       1

    ClickText                   Details
    VerifyField                 Name                        Ms. Tina Smith
    VerifyField                 Lead Status                 New
    VerifyField                 Phone                       ${phone}
    VerifyField                 Company                     Growmore
    VerifyField                 Website                     https://www.growmore.com/

    # as an example, let's check Phone number format. Should be "+" and 14 numbers
    ${phone_num}=               GetFieldValue               Phone
    Should Match Regexp         ${phone_num}                ^[+]\\d{14}$

    ClickText                   Leads
    VerifyText                  Tina Smith
    VerifyText                  Manager
    VerifyText                  Growmore
    # just an example of using DateTime Library, let's just log today's date on the LogScreenshot
    ${date} =                   Get Current Date
    Log                         Test run on: ${date}


Converting A Lead To Opportunity-Account-Contact
    [tags]                      Lead
    Appstate                    Home
    LaunchApp                   Sales

    ClickText                   Leads
    ClickText                   Tina Smith

    ClickUntil                  Convert Lead                Convert
    ClickText                   Opportunity                 2
    TypeText                    Opportunity Name            Growmore Pace
    ClickText                   Convert                     2
    VerifyText                  Your lead has been converted                            timeout=30

    ClickText                   Go to Leads
    ClickText                   Opportunities
    VerifyText                  Growmore Pace
    ClickText                   Accounts
    VerifyText                  Growmore
    ClickText                   Contacts
    VerifyText                  Tina Smith


Creating An Account
    [tags]                      Account
    Appstate                    Home
    LaunchApp                   Sales

    ClickText                   Accounts
    ClickUntil                  Account Information         New

    TypeText                    Account Name                Salesforce                  anchor=Parent Account
    TypeText                    Phone                       +12258443456789             anchor=Fax
    TypeText                    Fax                         +12258443456766
    TypeText                    Website                     https://www.salesforce.com
    Picklist                    Type                        Partner
    Picklist                    Industry                    Finance

    TypeText                    Employees                   35000
    TypeText                    Annual Revenue              12 billion
    ClickText                   Save                        partial_match=False

    ClickText                   Details
    VerifyText                  Salesforce
    VerifyText                  35,000


Creating An Opportunity For The Account
    [tags]                      Account
    Appstate                    Home
    LaunchApp                   Sales
    ClickText                   Accounts
    VerifyText                  Salesforce
    VerifyText                  Opportunities

    ClickUntil                  Stage                       Opportunities
    ClickUntil                  Opportunity Information     New
    TypeText                    Opportunity Name            Safesforce Pace             anchor=Cancel               delay=2
    Combobox                    Search Accounts...          Salesforce
    Picklist                    Type                        New Business
    ClickText                   Close Date                  Opportunity Information
    ClickText                   Next Month
    ClickText                   Today

    Picklist                    Stage                       Prospecting
    TypeText                    Amount                      5000000
    Picklist                    Lead Source                 Partner
    TypeText                    Next Step                   Qualification
    TypeText                    Description                 This is first step
    ClickText                   Save                        partial_match=False         # Do not accept partial match, i.e. "Save All"

    Sleep                       1
    ClickText                   Opportunities
    VerifyText                  Safesforce Pace


Change status of opportunity
    [tags]                      status_change
    Appstate                    Home
    ClickText                   Opportunities
    VerifyPageHeader            Opportunities
    ClickText                   Safesforce Pace             delay=2                     # intentionally delay action - 2 seconds
    VerifyText                  Contact Roles

    ClickText                   Show actions for Contact Roles
    ClickText                   Add Contact Roles

    # verify all following texts from the dialog that opens
    VerifyAll                   Cancel, Show Selected, Name, Add Contact Roles
    ComboBox                    Search Contacts...          Tina Smith
    ClickText                   Next                        delay=3
    ClickText                   Edit Role: Item
    ClickText                   --None--
    ClickText                   Decision Maker
    ClickText                   Save                        partial_match=False
    VerifyText                  Tina Smith

    ClickText                   Mark Stage as Complete
    ClickText                   Opportunities               delay=2
    ClickText                   Safesforce Pace
    VerifyStage                 Qualification               true
    VerifyStage                 Prospecting                 false
    VerifyStageColor            Qualification               navy
    VerifyStageColor            Prospecting                 green



Create A Contact For The Account
    [tags]                      salesforce.Account
    Appstate                    Home
    LaunchApp                   Sales
    ClickText                   Accounts
    VerifyText                  Salesforce
    VerifyText                  Contacts

    ClickUntil                  Email                       Contacts
    ClickUntil                  Contact Information         New
    Picklist                    Salutation                  Mr.
    TypeText                    First Name                  Richard
    TypeText                    Last Name                   Brown
    TypeText                    Phone                       +00150345678134             anchor=Mobile
    TypeText                    Mobile                      +00150345678178
    Combobox                    Search Accounts...          Salesforce

    TypeText                    Email                       richard.brown@gmail.com     anchor=Reports To
    TypeText                    Title                       Manager
    ClickText                   Save                        partial_match=False
    Sleep                       1
    ClickText                   Contacts
    VerifyText                  Richard Brown


Delete Test Data
    [tags]                      Test data
    Appstate                    Home
    LaunchApp                   Sales
    ClickText                   Accounts
    VerifyText                  Account Name

    Set Suite Variable          ${data}                     Salesforce
    RunBlock                    NoData                      timeout=180s                exp_handler=DeleteAccounts
    Set Suite Variable          ${data}                     Growmore
    RunBlock                    NoData                      timeout=180s                exp_handler=DeleteAccounts

    ClickText                   Opportunities
    VerifyPageHeader            Opportunities
    VerifyNoText                Safesforce Pace
    VerifyNoText                Growmore Pace
    VerifyNoText                Richard Brown
    VerifyNoText                Tina Smith

    # Delete Leads
    ClickText                   Leads
    VerifyText                  Change Owner
    Set Suite Variable          ${data}                     Tina Smith
    RunBlock                    NoData                      timeout=180s                exp_handler=DeleteLeads
    Set Suite Variable          ${data}                     John Doe
    RunBlock                    NoData                      timeout=180s                exp_handler=DeleteLeads

Create new lead
    Appstate                    Home
    LaunchApp                   Sales
    ClickText                   Leads
    ClickText                   New
    UseModal                    On
    ClickText                   *Last Name
    TypeText                    First Name                  Pedro
    TypeText                    Last Name                   Bazan
    TypeText                    Phone                       555555555
    TypeText                    *Company                    Arcsona
    PickList                    Salutation                  Mr.
    TypeText                    Email                       p@example.com
    ClickText                   Save                        partial_match=False
    UseModal                    Off
    VerifyText                  was created.

Create another lead
    [Documentation]             Create another lead
    [Tags]                      Leads                       Sprint 10                   Regression
    Appstate                    Home
    LaunchApp                   Sales
    ClickText                   Leads
    ClickText                   New
    UseModal                    On
    ClickText                   Cancel                      partial_match=False
    ClickElement                //a
    VerifyText                  Pedro

Create New Lead - Hannah
    [Documentation]             Test Case created using the QEditor
    Appstate                    Home

    LaunchApp                   Sales
    # ClickText                 Leads
    # ClickText                 New
    # UseModal                  On
    # ${LastName}                 Set Variable                CRT Test
    # ${FirstName}                Set Variable                Arcsona
    # ${full_name}                Set Variable                Arcsona ${LastName}
    # ${company}                  Set Variable                Arcsona
    # TypeText                  Last Name                   ${LastName}
    # TypeText                  First Name                  ${FirstName}
    # TypeText                  *Company                    ${company}
    # ClickText                 Save                        partial_match=False
    # UseModal                  Off
    ${LastName}                 Last Name
    ${FirstName}                First Name
    ${full_name}                Set Variable                ${FirstName} ${LastName}
    ${company}                  Company
    Create new Lead             ${FirstName}                ${LastName}                 ${company}
    ClickText                   Details
    VerifyField                 Lead Owner                  Pedro Bazan                 tag=a
    VerifyField                 Name                        ${full_name}
    ${lead_status}              GetFieldValue               Lead Status
    Should Be Equal As Strings                              Open - Not Contacted        ${lead_status}

My new test case    
    ClickText                   Opportunities
    ClickText                   New
    UseModal                    On
    ${today}                    Get Current Date
    ${tomorrow}                 Add Time To Date            ${today}                    1 day                       result_format=%d/%m/%Y
    TypeText                    Close Date                  ${tomorrow}

Create records
    Appstate                    Home
    SalesforceRESTAPI.Authenticate                           ${client_id}                ${client_secret}          login_url=${login_url}
    ${my_acc}=                  SalesforceRESTAPI.Create Record                          Account                   Name=TestCorp250711
    GoTo                        ${login_url}/${my_acc}
    Log To Console              ${login_url}${my_acc}
    &{contact_data}             Create Dictionary
    ...                         FirstName=Alan
    ...                         LastName=Bazan
    Log To Console              ${contact_data}
    ${my_contact}=              SalesforceRESTAPI.Create Record                          Contact                   &{contact_data}
    GoTo                        ${login_url}/${my_contact}
    # --------------------------NOTE--------------------------------------------------------
    # id of created records is returned and stored in variables above.
    # Let's make these suite level variables, so that we can re-use them later
    # --------------------------------------------------------------------------------------
    Set Suite Variable          ${my_acc}
    Set Suite Variable          ${my_contact}

Get Record Info
    [Documentation]             Example test case on how to query data using REST API
    [tags]                      REST API                    Get

    # --------------------------NOTE--------------------------------------------------------
    # Get Record returns record info as json. You can use them as dictionaries, i.e.
    # ${contact}[Name]
    # --------------------------------------------------------------------------------------
    ${account}=                 SalesforceRESTAPI.Get Record                             Account                   ${my_acc}
    Log To Console              ${account}
    Should Be Equal As Strings                              ${account}[Name]            TestCorp250711
    Log To Console              ${account}[Name]
    Log To Console              ${account}[PhotoUrl]
    Log                         ${account}
    ${contact}=                 SalesforceRESTAPI.Get Record                             Contact                   ${my_contact}
    Log                         ${contact}
    Should Be Equal As Strings                              ${contact}[Name]            Alan Bazan

Update data and verify
    [Documentation]             Example test case on how to modify and verify data
    [tags]                      REST API                    Update

    # --------------------------NOTE--------------------------------------------------------
    # Update Record keywords takes record type and field/data to update as argument
    # Note that we link the contact to an account here.
    # --------------------------------------------------------------------------------------
    SalesforceRESTAPI.Update Record                          Contact                     ${my_contact}             FirstName=Jana             Email=jana.doe@fake.com    AccountId=${my_acc}
    SalesforceRESTAPI.Verify Record                          Contact                     ${my_contact}             FirstName=Jane             LastName=Bazan             Email=jana.doe@fake.com    AccountId=${my_acc}


SOQL query 
    [Documentation]             Example test case for demonstrating other REST API keywords in QForce
    [tags]                      REST API                    Misc                        Query

    # --------------------------NOTE--------------------------------------------------------
    # We can query/manipulate data using SOQL Query. See:
    # https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_query.htm
    # --------------------------------------------------------------------------------------
    ${results}=                 SalesforceRESTAPI.QueryRecords                           SELECT id,name from Contact WHERE name LIKE 'Pedro%'
    Log To Console              ${results}[records][0][Id]
    ${results}=                 SalesforceRESTAPI.QueryRecords                           SELECT id,name from Lead WHERE name LIKE 'Pedro%'

Delete Records
    [Documentation]             Example test case on how to delete data and revoke access token
    [tags]                      REST API                    Delete

    # --------------------------NOTE--------------------------------------------------------
    # Delete Record keywords takes record type to be deleted and id as an argument
    # --------------------------------------------------------------------------------------
    SalesforceRESTAPI.Delete Record                          Contact                     ${my_contact}
    SalesforceRESTAPI.Delete Record                          Account                     ${my_acc}

Run apex script
    SalesforceRESTAPI.Execute Apex                           System.debug('Hello, World!');
    ${apex_script}              Set Variable                Account newAccount = new Account();newAccount.Name = 'New Account Name 250711 02'; newAccount.Industry = 'Technology'; newAccount.AnnualRevenue = 1000000; insert newAccount;System.debug('Account created: ' + newAccount.Id);
    SalesforceRESTAPI.Execute Apex                           ${apex_script}

Revoke
    SalesforceRESTAPI.Revoke
    Run Keyword And Expect Error                            ValueError: Token not set*                            SalesforceRESTAPI.Get Record        Account                ${my_acc}     

