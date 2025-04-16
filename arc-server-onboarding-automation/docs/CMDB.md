# CMDB

The file `CMDB.csv` is used as a CMDB to store information about the customers such as company name, address, servers, etc.

The CMDB file is used as an example, and the information within it will be utilized by the scripts for configuration and provisioning. It is recommended to modify the methods for connecting to and updating the CMDB according to your specific setup.

## Structure

The file uses a semicolon (`;`) as the delimiter to separate fields. The first row contains the headers, which describe the type of data in each column.

## Headers

Here are the headers and their meanings:

- **Name**: The name of the customer.
- **Tenant_Domain_Name**: The tenant name. This field will be used to create a customer Azure tenant named `Customer_Tenant_Domain_Name`.
- **Company_Name**: The name of the company.
- **Contact_First_Name**: The first name of the contact person.
- **Contact_Last_Name**: The last name of the contact person.
- **Email**: Email of the contact person.
- **Address**: The address of the company.
- **Postal_Code**: The postal code of the company.
- **City**: The city where the company is located.
- **Country**: The country where the company is located.
- **Server_Name**: Name of the server.
- **Server_Unique_Identifier**: UUID of the server.
- **SQL_Foreign_Name**: The foreign name of the SQL Server instance.
- **SQL_Server_Version**: The server version of the SQL Server instance.
- **Tenant_Id**: The tenant ID. This field can be empty and will be updated once the customer tenant is created.
- **Subscription_Id**: The subscription ID. This field can be empty and will be updated once the customer tenant is created.
- **AppId**: The application ID. This field can be empty and will be updated once the customer SPN is created.
- **App_Secret**: This field can be empty and will be updated once the customer SPN is created.

## Example

```csv
Name;Tenant_Domain_Name;Company_Name;Contact_First_Name;Contact_Last_Name;Email;Address;Postal;City;Country;Server_Name;Server_Unique_Identifier;SQL_Foreign_Name;SQL_Server_Version;Tenant_Id;Subscription_Id;AppId;App_Secret
Contoso;contoso.onmicrosoft.com;Contoso;John;Doe;simona.toader@microsoft.com;Kanalvej 7;2800;Kongens Lyngby;Denmark;ExampleServerName;123e4567-e89b-12d3-a456-426614174000;ExampleSQL;15.0.2000.5;;;;