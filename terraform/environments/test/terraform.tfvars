# Azure subscription vars
subscription_id = "dace3890-d3f3-4198-9c08-1d3d7651c931"
client_id       = "88f50b4e-0cf9-4bf7-bc95-2ba21db360bc"
client_secret   = "tjQ8Q~KFW9Yh4qi4dLautJby3mzAWaQmqogo6aUF"
tenant_id       = "23888ed7-fee0-481c-8d17-c013a869a4e8"

# Resource Group/Location
location            = "eastus"
resource_group      = "hieuvv-udacity-p03-rg"
application_type    = "hieuvv-udacity-p03-app"

# Network
virtual_network_name = "udacity-hieuvv-p03-vnet"
address_space        = ["10.5.0.0/16"]
address_prefix_test  = "10.5.1.0/24"

# VM
name_image     = "VM"
name_vm        = "VM-QA"
name_size      = "Standard_B1s" # Standard_DS1_v2
type_storage   = "Standard_LRS"
admin_username = "admin01012023"
admin_password = "123@123Aa"
public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj07p+G6rulG6AOW+EVLPjCR1oBjtKjs5oVlLrGQep1mE3+kchVualISSnzwnms5r+jjrQx3Lrxq08lBRDs4K27kDK9kVSd7REIT9+uSKBH4UYQx7HcYoxLCjDGUYVqpq75VxL8Ans1sK2STrwZ5OH63QVkRSIfxjmNH5P2cOEaRvXYo7Q0kuUizrrGbxB3iBVZ3p9XRcmhYbKbyxFHv+lPNGZ8L3GeeBiNrRIv3pS1gWBBRHVDUGpQbfch9oL2Vek5KkWAQUz1hGipdaCBDUfsb8HHKWy3YL48/X+xR2Wri62W6EwxMKaNoOMPVvrlaV0dTZm2cNCU1Nfllok2x4Yz4Ionq867VPHmn8ZJjR9KMuFtd8pSRgbGB6PWOXZcxFR6tN0op2TTggw8grHhg3C2oeUoBG+s82bL4Oh0lLlHRIL/WFSvBDGDC33kcb/jBGaACK2+DjduJfO35LuoNn8CCEJrPigekl2WooUtJryZ2cSP0RlbUcdVFEwFKzegbc="

#public key on pipeline
public_key_path = "~/.ssh/id_rsa.pub"
