---
title: Integrations
parent: Features
layout: home
nav_order: 7
---

# Integrations

Integrations allow new leads to be automatically added to your outreach tool or CRM.

## Available integrations

We have the following native integrations:

1. HubSpot
2. Apollo
3. Snov
4. Webhook

Any other system (that has an open API) can be integrated with SignalsAPI via webhook and receive leads in real time. Contact mykola@signalsapi.com if you need help with integration or would like to&#x20;

## Setting up

1. Open Settings -> Integrations -> Add Integration.
2. Choose a system you would like to integrate with, and follow system-specific instructions below.
3. Edit or create a search and choose added integration in the "Destination" field.

## Approval and upload

If your search does not have "Manual Approval" enabled, your leads will be uploaded immediately.

If your search has "Manual Approval" enabled, your leads will be uploaded to the integrated system only after you open each of them and click "Approve".

Lead status changes to "Approved" when you click "Approve". After lead was uploaded, status changes to "Uploaded".

## Integrating with HubSpot

After adding this integration, you will be automatically redirected to HubSpot, where you will be asked to confirm the integration. After you confirm it, you will be redirected back.

When adding/editing a HubSpot export, you can optionally choose which lists the new contacts should be added to.

To edit lists, open your HubSpot, go to CRM -> Lists, and then add "Contact-based" lists with type "Static". Then choose one of these lists when adding or editing a HubSpot export in SignalsAPI.

## Integrating with Apollo

Apollo integration requires an Apollo API key and a list of destinations

* API key can be found here: [https://developer.apollo.io/keys/](https://developer.apollo.io/keys/)

Destination is a combination of a Sequence and Mailbox used to send emails. After adding an Apollo integration:

* Open Integrations -> Apollo -> Add Destination
* Name
  * Choose a name you can recognize this destination by. Sequence name will do.
* Sequence ID
  * Sequence ID can be found in Apollo. Open Apollo Sequence you would like to add as a destination, and copy its ID from browser URL\
    E.g. URL: https://app.apollo.io/#/sequences/**65d1b26f8fd3fb06d8e9f3f9**\
    Sequence ID: **65d1b26f8fd3fb06d8e9f3f9**
* Mailbox ID
  * Mailbox ID can also be found in Apollo. Open Apollo Mailbox you would like to use, and copy its ID from browser URL\
    E.g. URL: https://app.apollo.io/#/users/64ecb09cb3fc7000a3f52f36/mailboxes/**64ecb09bb3fc7000a3f52e50**/settings\
    Mailbox ID: **64ecb09bb3fc7000a3f52e50**

## Integrating with Snov.io

Snov.io integration requires a Snov.io API User ID and API Secret.

They can be found here: [https://app.snov.io/account/api](https://app.snov.io/account/api)

## Integrating with Bullhorn

Bullhorn integration requires a API Username and API Password, Client ID and Client Key.

Contact Bullhorn support to obtain them with a message like this: "Hey, I am setting up an integration with SignalsAPI.com, and they ask to provide an API key. Could I get one?".

They will ask you about:

1. "Terms of service URL" -- answer "Not needed"
2. "Redirect URL" -- provide this one https://app.signalsapi.com/integrations/bullhorn/callback

They will provide 4 values:
- Client ID
- Client Secret
- API Username
- API Password

Add Bullhorn export to your SignalsAPI account and provide these values when prompted.

## Integrating with Zoho

[https://youtu.be/xRhsO_mXxFM](https://youtu.be/xRhsO_mXxFM)

## Integrating with Firefish

[https://youtu.be/CTC4VHMeYqw](https://youtu.be/CTC4VHMeYqw)
