# Check if network connectivity for Azure Connected Machine Agent is blocked - Azure Arc

To onboard a server to Azure Arc and utilize its capabilities you need to install the Azure Connected Machine agent.

The Azure Connected Machine agent communicates from your non-Azure environment to Azure using several URLs. For more information on those URLs please refer to the [official documentation](https://learn.microsoft.com/en-us/azure/azure-arc/servers/network-requirements).

If outbound connectivity from your environment is restricted by your firewall or proxy server, you need to ensure that the correct URLs are not blocked.

At the very minimum, the agent needs to be able to communicate with URLs such as:

* *.guestconfiguration.azure.com (Extension management and guest configuration services)
* *his.arc.azure.com (Metadata and Hybrid Identity Service)
* login.microsoftonline.com (Microsoft Entra ID)
* login.windows.net (Microsoft Entra ID)
* pas.windows.net (Microsoft Entra ID)
* management.azure.com (Azure Resource Manager)

To check if network connectivity for the Azure Connected Machine agent is blocked you can use the [azcmagent CLI tool](https://learn.microsoft.com/en-us/azure/azure-arc/servers/manage-agent).

The azcmagent CLI is installed with the Azure Connected Machine agent and controls actions specific to the server where it's running.

One of the switches available with the azcmagent is `check`. This runs a series of network connectivity checks to see if the agent can successfully communicate with required network endpoints.

## Check Azure Arc connectivity using public endpoints

To use the azcmagent CLI tool log onto a server that has the Azure Connected Machine agent installed on it.

Launch a command prompt or PowerShell terminal window.

Type in
```
azcmagent check --location "ukwest"
```

The command outputs a table showing connectivity test results for each required endpoint. In this example, all URLs are reachable and are going directly to the URLs.

![Azcmagent check output](/arc-sql-connectivity/media/azcmagent-output-1.png)

> 💡 If you are using a different Azure region, ensure you input the correct name for your region. If you are unsure of the region name you can run the command `az account list-locations -o table` from Azure CLI to get a list.

## Check Azure Arc connectivity using private endpoints

If you are using private endpoints for connectivity you can use the following command to check:

```
azcmagent check --location "useast" --enable-pls-check
```

> 💡 If you are using a different Azure region, ensure you input the correct name for your region. If you are unsure of the region name you can run the command `az account list-locations -o table` from Azure CLI to get a list.

## Check Azure Arc connectivity using a proxy

If you are using a proxy to route traffic the command you would check network connectivity is the same as if you are using public endpoints.

```
azcmagent check --location "westeurope"
```

![azcmagent output](/arc-sql-connectivity/media/azcmagent-output-2.png)

In this example, you can see from the table the traffic is going through a proxy server and some of the URLs are unreachable.

## Conclusion

In conclusion, ensuring seamless connectivity for the Azure Connected Machine agent is crucial for a successful onboarding process to Azure Arc.

This involves verifying the accessibility of specific URLs through either public or private endpoints, with additional considerations for environments employing proxy servers.

Utilizing the azcmagent CLI tool provides a straightforward means to conduct network connectivity checks, allowing users to address any potential restrictions or blockages, and ensuring a smooth integration of servers into the Azure Arc ecosystem.

---

*Originally published at [techielass.com](https://techielass.com)*

*Author: [Sarah Lean 🏴󠁧󠁢󠁳󠁣󠁴󠁿](https://dev.to/techielass)*