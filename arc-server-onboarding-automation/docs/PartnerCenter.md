## Creating Customer Tenants in Partner Center Using the Partner Center API

To create customer tenants in Partner Center using the Partner Center API, follow these steps:

1. **Authenticate**: Obtain an access token by following the Partner Center API authentication process.
2. **Create a Customer**: Use the Partner Center API to create a new customer tenant. Provide the necessary details such as the company name, address, and contact information.

### Prerequisites

Before you start, ensure you have the following:

- A Partner Center account with API access and the necessary permissions.
- Partner Center API credentials (Client ID, Client Secret).
- Customer information including company name, primary contact details, and domain information.

### Setup

1. **App Registration**: Create an app registration in the Azure partner tenant.
2. **Store Credentials**: Store the app's client ID and client secret in Azure Key Vault. These credentials will be retrieved and used to authenticate and obtain the access token needed to use the Partner Center APIs.
3. **Customer information**: In order to create a customer tenant, we need to get the customer infocmation such as company name, address, etc. You probably have that stored in a database, cmdb, etc. In order to do so, 