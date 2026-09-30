# Module 4: License management

Version: v1.2026.09
Last updated: 2026-09-30

In this module you switch the lab host between Pay-as-you-go and License with Software Assurance. You verify the
change in Azure and see which features require a billable license type.

## Prerequisites
- Complete [Module 3](03-sql-extension.md).
- Use the lab resource group `arcsql-lab-arc-rg` in `swedencentral`.
- Use a test host only. License changes affect billing and feature availability.

## Steps
### 1. Review the current license state
1. In the Azure portal, open **Azure Arc** > **SQL Server instances**.
2. Select your lab instance.
3. On **Overview**, note the current **Host license type**.
4. Select **SQL Server Configuration**. If you do not see that entry, open **Properties** and review **License type**
   under **SQL Server configuration**.
5. Run the following query if you want a read-only check before you make changes:

```powershell
Search-AzGraph -Query @'
resources
| where type =~ "microsoft.hybridcompute/machines/extensions"
| where name =~ "WindowsAgent.SqlServer"
| where resourceGroup =~ "arcsql-lab-arc-rg"
| extend machineName = extract(@"/machines/([^/]+)/extensions/", 1, id)
| project machineName,
          resourceGroup,
          licenseType = tostring(properties.settings.LicenseType),
          extensionVersion = tostring(properties.instanceView.typeHandlerVersion)
'@
```

### 2. Change the host to Pay-as-you-go
> [!IMPORTANT]
> Changing **License type** starts or changes Azure billing for this host. Use a lab or approved test system only.

1. On **SQL Server Configuration**, set **License type** to **Pay-as-you-go**.
2. Review the pricing text on the pane.
3. Select **Save** and wait for the update to finish.
4. Return to **Overview** and confirm that the host license type changed.

### 3. Change the host to license with software assurance
> [!IMPORTANT]
> Changing **License type** changes how Azure bills the host. Use **License with Software Assurance** only if the lab
> server qualifies for that entitlement.

1. Return to **SQL Server Configuration**.
2. Set **License type** to **License with Software Assurance**.
3. Select **Save**.
4. Return to **Overview** and confirm that the host license type changed again.

### 4. Review what the license type controls
1. Open **Best practices assessment** on the SQL Server resource.
2. Open **Monitoring** on the same resource.
3. Note that these features require **Pay-as-you-go** or **License with Software Assurance**. They are not available
   with `LicenseOnly`.
4. If you need bulk license changes or ESU actions outside this lab, use the repo guide
   [Modify license type for Azure Arc-enabled SQL Server](../../arc-sql-modify-license-type/README.md).

## Validate
- **Overview** shows the host license type that you last saved.
- The Resource Graph query returns the `WindowsAgent.SqlServer` extension in `arcsql-lab-arc-rg`.
- The query shows the expected `licenseType` value after each change.
- **Best practices assessment** and **Monitoring** are available when the host uses Pay-as-you-go or License with
  Software Assurance.

## Troubleshooting
- If the **License type** control is unavailable, make sure you opened the SQL Server enabled by Azure Arc resource,
  not only the parent Arc-enabled server resource.
- If **Save** fails, verify that your account can update resources in `arcsql-lab-arc-rg`.
- If the overview pane does not update, refresh the browser tab and rerun the Resource Graph query.

Back to the [module index](../README.md#modules).
