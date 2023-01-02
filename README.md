# Table of Contents - Ensuring Quality Releases

- **[Overview](#Overview)**
- **[Dependencies](#Dependencies)**
- **[Azure Resources](#Azure-Resources)**
- **[Installation Configuration Steps](#Installation-Configuration-Steps)**
- **[Monitoring And Logging Result](#Monitoring-And-Logging-Result)**
- **[Clean Up](#Clean-Up)**

## Overview

This project desmostrates the workflow for realease quality ensuring using Azure cloud. This will implement automated testing, performance monitoring, loggin using Azure DevOps, JMeter, Selenium, Postman and Terraform.

<!-- TODO: Add intro picture -->
![intro](././imgs/intro.png)

## Dependencies
| Dependency   | Link                                                                 |
| ------------ | -------------------------------------------------------------------- |
| Terraform    | https://www.terraform.io/downloads.html                              |
| JMeter       | https://jmeter.apache.org/download_jmeter.cgi                        |
| Postman      | https://www.postman.com/downloads/                                   |
| Python       | https://www.python.org/downloads/                                    |
| Selenium     | https://sites.google.com/a/chromium.org/chromedriver/getting-started |
| Azure DevOps | https://azure.microsoft.com/en-us/services/devops/                   |

## Azure Resources
 - Azure account  
 - Azure Storage account (resource)
 - Azure Log Workspace (resource)
 - Terraform Service principle (resource)
 - Azure CLI (resource)

## Installation Configuration Steps

### Terraform in Azure
1. Clone source repo
2. Open a Terminal in VS Code and connect to your Azure Account and get the Subscription ID

    ```bash
    az login 
    az account list --output table
    ```

3. Configure storage account to Store Terraform state
   
   Execute the script **terraform/environments/test/configure-tfstate-storage-account.sh** :
   
   ```bash
   ./terraform/environments/test/configure-tfstate-storage-account.sh
   ```

   ![Configure storage account](./imgs/01.configure-storage-account.png)

   The resource group and storage account will be created on Azure cloud. 

   
   ![Storage account on Azure cloud](./imgs/03.storage-account-on-azure.png)
   
   Take notes of `storage_account_name`, `container_name`, `access_key` . They are will be used in `main.tf` terrafrom files

    ```terraform
    terraform {
        backend "azurerm" {
            storage_account_name = "hieuvvstorage1999"
            container_name       = "hieuvvcontainer1999"
            key                  = "test.terraform.tfstate"
            access_key           = "wEef3qU/SXyP8D+sgeZwD28vXTkLbAtmIwMjT/DW7IiLbsbblJrwG9+t3wrFFEAm32vh2CCOOpF++AStbdZd7w=="
        }
    }
    ```
    
    ![azurerm-backend](./imgs/02.terraform-azurerm-backend.png)


#### Create a Service Principal for Terraform

1. Create a Service Principal with **Contributor** role, performing the following steps:

    ```bash
    az ad sp create-for-rbac --role Contributor --scopes /subscriptions/<your-subscription-id> --query "{ client_id: appId, client_secret: password, tenant_id: tenant }" 
    ```

    ![Service Principal Contributor](./imgs/04.service-principal-contributor.png)

    Take notes of `appId`, `password`, and `tenant` as will be used at `terraform/environments/test/terraform.tfvars` file 

2. On your terminal create a SSH key and also perform a keyscan of your github to get the known hosts.

    ```bash
    ssh-keygen -t rsa
    cat ~/.ssh/id_rsa.pub
    ```

    Copy the public key and save to variable `public_key` in the `terraform.tfvars`.

#### Apply the Terraform configuration

  ```bash
  cd terraform/environments/test
  terraform init #terraform init -reconfigure
  terraform plan -out solution.plan
  terraform apply
  ```

  All the Terraform resources will be created on Azure cloud.

  ![Azure cloud](./imgs/05.terraform-resources-azure.png)

### Azure DevOps

You need an Azure DevOps account and then follow these steps to setup the Pipelines.

#### 1. Install AzureDevOps Extensions:

  * [JMeter](https://marketplace.visualstudio.com/items?itemName=AlexandreGattiker.jmeter-tasks&targetId=625be685-7d04-4b91-8e92-0a3f91f6c3ac&utm_source=vstsproduct&utm_medium=ExtHubManageList)

  * [PublishHTMLReports](https://marketplace.visualstudio.com/items?itemName=LakshayKaushik.PublishHTMLReports&targetId=625be685-7d04-4b91-8e92-0a3f91f6c3ac&utm_source=vstsproduct&utm_medium=ExtHubManageList)

  * [Terraform](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks&targetId=625be685-7d04-4b91-8e92-0a3f91f6c3ac&utm_source=vstsproduct&utm_medium=ExtHubManageList)

#### 2. Create a Project in your Organization

Click into your Organization > New Project

#### 3. Create the Service Connection

In Project Settings > Pipelines > Service Connection > Create service connection

1. Select Azure Resource Manager
2. Select Service principal (automatic)
3. Select Scope level: Subscription
4. Login into your Azure account
5. Select your subscription
6. Select your Resource group
7. Enter service connection name
8. **Check: Grant access permission to all pipelines**
9. Click Save

![Service Connection](./imgs/06.azure-devops-service-connection.png)

#### 4. Add Library Sercure Files

In Pipelines > Library > Secure files

  * The ssh private key file : `id_rsa`
  * The terraform tfvars file : `terraform.tfvars`
  
  ![library-secure-files](./imgs/07.library-secure-files.png)

#### 5. Update azure-pipelines.yaml

Get your "Known Hosts Entry" is the displayed third value that doesn't begin with # in the GitBash results:<br/>
    
```bash
ssh-keyscan github.com
```

Take note value in highlight below to fill `knownHostsEntry`

![azurerm-ssh-key-scan](./imgs/08.ssh-keyscan.png)

| # # | parameter          | description                                                   |
| --- | ------------------ | ------------------------------------------------------------- |
| 1   | knownHostsEntry    | the knownHost of your ssh-keyscan github                      |
| 2   | sshPublicKey       | your public ssh key (from id_rsa.pub)                         |
| 3   | storageAccountName | Value from Configure storage account to Store Terraform state |

#### 6. Create groups of variables

Create groups of variables that you can share across multiple pipelines.

1. In Pipelines > Library > "Variable groups" > Add new variables group: `ssh-config`.
2. Add `knownHostsEntry`, `sshPublicKey`, `StorageAccountName` and value this in Variables > Select type to secret > Save

![variable group](./imgs/09.variable-group.png)

#### 7. Create a New Pipeline in your Azure DevOPs Project

Make sure your GitHub repository has **azure-pipelines.yaml** file.

##### 7.1. Create Pipelines

1. Tab Pipelines
2. Click Create Pipeline
3. Where is your code? Choose Github (Yaml)
4. Select your Repository
5. Login GitHub account and grant access for Azure DevOps
6. Configure your pipeline:
   1. Choose "Existing Azure Pipelines yaml file"
   2. Continue
   3. Run

![img](./imgs/10.select-existing-yaml-file.png)

![img](./imgs/11.run-pipeline.png)

##### 7.2. Apcept permission for Azure Resources Create with terraform

  ![img](./imgs/12.permission-needed.png)

  ![img](./imgs/13.permission-permit.png)

##### 7.3. Registration VM on environment Pipeline

When step deploy virtual machine(VM) if you can see error : "No resource found ...". you must Registration VM on environment Pipeline and you only need to run it once (from 7.4 to 7.6)

![img](./imgs/14.devops-error-no-resource.png)

##### 7.4. Create Test environment script

1. In tab Pipelines > click Environments
2. Select "VM_TEST" environment
3. Select "Add resource"
4. choose "Virtual machines"
5. Select "Linux"
6. Choose icon "Copy command ..."
7. Close

![img](./imgs/15.devops-add-resource.png)

![img](./imgs/16.devops-add-resource-script.png)

##### 8.5. SSH to VM and Execute commands

In this step, you need to SSH to your VM and execute the commands copied from step `7.4`.

You will need:
1. `admin_username` from `terraform.tfvars`
2. `public_ip`: VM Public IP address get from your public IP address
3. Run this command from your terminal: `ssh admin_username@public_ip`

![vm public ip](./imgs/17.vm-public-ip.png)

![img](./imgs/18.excute-add-resource-script.png)

![img](./imgs/19.excute-script-in-vm.png)

Get at the end a result like:

![img](./imgs/20.result-add-resource-vm.png)

##### 7.6. Back to pipeline and re-run

Go back to the error Azure Pipelines step and click re-run failed task. The susscessful should be like this.

![img](./imgs/21.rerun-task-deploy-vm.png)

### 8. Wait the Pipeline is going to execute

After a successfully pipelines, there are the following Stages:

1. Azure Resources Create
2. Build
3. Deploy App
4. Test

![img](./imgs/22.automation-test-result.png)

If you got 403 Forbidden when trying to the webapp website, try to change the webapp plan from F1 to B1 or any "Pay-as-you-go" plan.

The FakeRestAPI belongs to this lab runs on .NET Framework 4.6, which only runs on Windows server. So, change the `os_type = "Windows"` in the `appservice.tf` file to make sure the build run.

[App Service Plan](https://learn.microsoft.com/en-us/rest/api/appservice/app-service-plans)
[Terraform AzureRM App service](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan)

### Configure Logging for the VM in the Azure Portal

1. Create a Log Analytics workspace. It will be created on the same RG used by terraform

    ![img](./imgs/23.log-analytics-workspace.png)

2. Set up email alerts in the App Service:
 
 * Log into Azure portal and go to the AppService that you have created.
 * On the left-hand side, under Monitoring, click Alerts, then New Alert Rule.
 * Verify the resource is correct, then, click “Add a Condition” and choose Http 404
 * Then, set the Threshold value of 1. Then click Done
 * After that, create an action group and name it myActionGroup, short name mag.
 * Then, add “Send Email” for the Action Name, and choose Email/SMS/Push/Voice for the action type, and enter your email. Click OK
 * Name the alert rule Http 404 errors are greater than 1, and leave the severity at 3, then click “Create”
  Wait ten minutes for the alert to take effect. If you then visit the URL of the app service and try to go to a non-existent page more than once it should trigger the email alert.

3. Log Analytics
  * Go to the `App service* Diagnostic Settings > + Add Diagnostic Setting`. Tick `AppServiceHTTPLogs` and Send to Log Analytics Workspace created on step above and  `Save`. 

  * Go back to the `App service > App Service Logs `. Turn on `Detailed Error Messages` and `Failed Request Tracing` > `Save`. 
  * Restart the app service.

4. Set up log analytics workspace properly to get logs:

  * Go to Virtual Machines and Connect the VM created on Terraform to the Workspace ( Connect). Just wait that shows `Connected`.

    * Set up custom logging , in the log analytics workspace go to Advanced Settings > Data > Custom Logs > Add > Choose File. Select the file selenium.log > Next > Next. Put in the following paths as type Linux:

    /var/log/selenium/selenium.log

    Give it a name ( `selenium_logs_CL`) and click Done. Tick the box Apply below configuration to my linux machines.

  * Go to the App Service web page and navigate on the links and also generate 404 not found, example:

  * Home Page: https://udacity-thoanvtt-project03-app-appservice.azurewebsites.net

  * 404 Page: http://hieuvv-udacity-p03-app-appservice.azurewebsites.net/test404

  * After some minutes ( 3 to 10 minutes) , check the email configured since an alert message will be received. and also check the Log Analytics Logs , so you can get visualize the logs and analyze with more detail.

  ![img](./imgs/24.azure-monitor-alert-triggered-email.png)

  * The alert will also be tracking on Azure portal
  
  ![img](./imgs/24.azure-monitor-alert-triggered.png)


## Monitoring And Logging Result

In this step, you will configure Azure Log Analytics to consume and aggregate custom application events in order to discover root causes of operational faults, and subsequently address them.

### Environment Creation & Deployment

  #### The pipeline build results page

  ![Pipeline-Result](./imgs/25.automation-test-result.png)

  #### Terraform Init

  ![Terraform](./imgs/26.terraform-init-in-pipeline.png)

  #### Terraform Validate

  ![Terraform](./imgs/27.terraform-validate-in-pipeline.png)

  #### Terraform Plan

  ![Terraform](./imgs/28.1.terraform-plan-in-pipeline.png)

  ![Terraform](./imgs/28.2.terraform-plan-in-pipeline.png)

  #### Terraform Apply

  ![Terraform](./imgs/29.1.terraform-apply-in-pipeline.png)

  ![Terraform](./imgs/29.2.terraform-apply-in-pipeline.png)

### Deploy WebApp FakeRestAPI

  ![DeployWebApp](./imgs/30.1.deploy-azure-web-app.png)

  ![FakeRestAPI](./imgs/30.2.fakerestapi.png)

### Automated Testing

  #### UI Testing - Selenium

  ![Selenium test](./imgs/34.selenium-logging.png)

  #### Performance Testing - JMeter

  ![JMeterLogOutput](./imgs/31.1.jmeter-log-output-stress-test.png)

  ![JMeterLogOutput](./imgs/31.2.jmeter-log-output-endurance-test.png)

  #### JMeter Stress Test

  ![Stress test](./imgs/32.publish-stress-test-results.png)

  #### JMeter Endurance Test

  ![Endurance test](./imgs/33.publish-endurance-test-results.png)

  #### Regression Tests - Postman

  ![Regression test](./imgs/35.1.test-run-regression-postman.png)

  ![Regression test](./imgs/35.2.junit-regression-test-summary.png)

  <!-- ![Regression test](./imgs/35.3.junit-regression-test-result.png) -->

  #### Validation Tests
  ![Validation test](./imgs/36.1.test-run-validation-postman.png)

  ![Validation test](./imgs/junit-validation-test-summary.png)

  ![Validation test](./imgs/junit-validation-test-result.png)

  #### The artifact is downloaded from the Azure DevOps and available under the /projectartifactsrequirements folder.

