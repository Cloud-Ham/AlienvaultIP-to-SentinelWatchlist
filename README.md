# AlienvaultIP-to-SentinelWatchlist

BETA Version: Awaiting deployment in 2nd Azure environment

This repo will create automation to pull from Alienvault's reputation generic IPv4 address list [Available here](https://reputation.alienvault.com/reputation.generic). This is a bit overkill for the requirements, and I would generally advise looking into the "Threat Intelligence Upload Indicators API (Preview)" connector in Sentinel. Which if you'd like to review what's needed for that, I'd read through [this page](https://learn.microsoft.com/en-us/azure/databricks/dev-tools/app-aad-token#get-an-azure-ad-access-token).

There were a couple of reasons I wanted to create this, and why it acts the way that it does:

* The supported connector requires an Azure AD Application for use. Depending on where this is deployed, it may run into a conflict or additional requirements that add a level of overhead to it (Change Control, Lifecycle management, etc.). By developing a connection without needing Azure AD, it gives power back to SOC analysts who do not have Azure AD permissions.
* The default implementation of this has the Logic App API connections based on User Authentication. This provides a possible but very limited risk (Your credentials do not leave Azure). The reason for this is to get SOC operationally running and let you decide post-deployment if you would like to swap any of the API connections in the Logic App to something else. If you have a Managed Identity or Service Principal with limited permissions able to run the actions, I highly recommend swapping to those after deploying.
* Some manual actions are required after deploying the terraform files. This is due to the fact that user authentication does not carry over very well, and the terraform is unaware of what connection you will establish.

Let me know if you run into any issues, and feel free to contribute.

# Requirements

* Existing Log Analytics Workspace onboarded to Sentinel
* User who deploys this should have permissions to deploy the App Service Plan, the Function App, and the Logic App (Contributor or Owner at a Resource Group scope will work)

# What this deploys

* Azure Function App (Windows, Node.JS, Javascript, Consumption)
* Azure Function App Function (Parses the input)
* Azure Logic App (Consumption), set to execute every 24 hours
* (Through Terraform) Azure Sentinel Watchlist: AlienvaultIPList [This will be replaced at Logic App Execution]
* (Through Logic App) Azure Sentinel Watchlist: AlienvaultIPList

# How to deploy:

__CAUTION__: Deploying this terraform template after it's already been deployed will result in the Logic App overwriting it's configuration. If you wish to manage this in terraform, remove the Logic App from the template after deploying it.

* Download this repository & extract contents
* Run standard terraform processes
    * terraform init
    * terraform plan
    * terraform apply
* After deployment, go to the Logic App in the Portal and do the following:
    * In the visual designer, create a Recurrence Trigger with any details
    * Create a Sentinel Action with dummy values. I recommend "Add alert to sentinel" and setting the input fields to "a". Make sure that you have a connection to a user account established. It should say "Connected to (EMAIL)"
    * Save the changes, and go to the Code View
    * There are three lines in the parameters section towards the bottom, "connectionId", "connectionName", and "id". Copy these lines and save them for the next step.
* Go to the "workflow.json" file in your local files. Use the three lines you copied in the previous step to replace the three similar lines in workflow.json (Should be around lines 175-177)
* Go to the Logic App's code view, and copy the contents from workflow.json into it. Save the changes.
* Go to the Logic App's visual designer and ensure that all of the actions are present and no connection issues exist
* (Optional) Change the connections on the Sentinel actions in the Logic App to whichever you prefer (User, Service Principal, or Managed Identity)

To provide all variables at runtime:
```
terraform apply -auto-approve -var="rg_name=RESOURCE_GROUP_NAME" -var="deploy_location=DEPLOY_REGION" -var="subscription_id=SUBSCRIPTION_ID" -var="workspace_id=LOG_ANALYTICS_WORKSPACE_ID" -var="workspace_name=LOG_ANALYTICS_WORKSPACE_NAME" -var="watchlist_name=WATCHLIST_NAME"
```

# Important information

This automation will destroy the watchlist and create a new one with the most current values at each Logic App execution. This will help prevent duplicates and an endlessly growing watchlist, but will not keep history.

# Known issues

The AlienvaultIPList has a dummy value "999.999.999.999" in it. Nothing should ever match to it. The reason this exists is because I wanted to keep the steps of "Create Watchlist" and "Add item to watchlist" separate, mostly for troubleshooting purposes. It becomes easier to account for values being added watching loops and input/output for each loop. There is the possibility of deleting the dummy value after everything is done at the end of the logic app, but it adds in some more complexity (The Logic App would need to query the watchlist in Log Analytics, and then delete the item once it finds the GUID value)

The Delay in the Logic App is set to 10 minutes. The Delay is implemented due to the fact that the Deletion step will be considered complete before the watchlist is actually completed, causing a conflict when it attempts to create the new watchlist. In testing, 5 minutes was too quick. 10 minutes did not fail.