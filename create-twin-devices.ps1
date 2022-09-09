# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
#Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
param ([bool] $addTags = $true,[bool] $addProps = $true, [bool] $createAll = $false)

az login
Write-Output "Login sucessfully"

<#
.PARAMETER ResGroupName
Use this to specify the Resource Group name where twin devices will be created.

.PARAMETER IoTHubName
Use this to specify the IoT Hub Name name where twin devices will be created.

.PARAMETER DeviceName
Use this to specify the Parent Device Name name where twin devices will be created.

.PARAMETER TagCsvPath
Use this to specify the path to the CSV containing the Tags import data.

.PARAMETER DesiredCsvPath
Use this to specify the path to the CSV containing the Desired properties import data.

.EXAMPLE
.\create-twin-devices.ps1
#>

$TagCsvPath = ".\sample_tags.csv";
$DesiredCsvPath = ".\sample_desired.csv";

$ResGroupName = "MyTestResGroup";
$DeviceName = "TestParentDevice";
$IoTHubName = "iot-dev-test-spike";

if($createAll)
{
	#Creates a new Resource Group
	az group create --name $ResGroupName --location eastus
	Write-Output ("Created Resouce Group " + $ResGroupName)

	#Creates an IoT Hub in the newly created resource group
	az iot hub create --resource-group $ResGroupName --name $IoTHubName
	Write-Output ("Created IoT Hub " + $IoTHubName)

	#Creates a device that will serve as parent for the twin devices
	Add-AzIotHubDevice -ResourceGroupName $ResGroupName  -IotHubName $IoTHubName -DeviceId $DeviceName -AuthMethod "shared_private_key" -EdgeEnabled
	Write-Output ("Created Parent Device " + $DeviceName)
}

Import-Csv -Path $TagCsvPath | ForEach {
	if($createAll)
	{
		#Creates the twin Device
		Add-AzIoTHubDevice -ResourceGroupName $ResGroupName -IoTHubName $IoTHubName -ParentDeviceId $DeviceName -DeviceId $_.TwinDeviceName -AuthMethod "shared_private_key"
		Write-Output ("Created Twin Device " + $_.TwinDeviceName)
	}
	
	if($addTags)
	{
		$updatedTag = @{};
		$columns = $_.PSObject.Properties.Name.count - 1;

		for($num = 1; $num -le $columns; $num++)
		{
			$updatedTag.add($_.PSObject.Properties.Name[$num], $_.PSObject.Properties.Value[$num]);
		}
		
		#Creates/updates the tags for the twin device
		Update-AzIotHubDeviceTwin -ResourceGroupName $ResGroupName -IotHubName $IoTHubName -DeviceId $_.TwinDeviceName -Tag $updatedTag
		Write-Output ("Added Tags to Twin Device " + $_.TwinDeviceName)
	}
}

if($addProps)
{
	Import-Csv -Path $DesiredCsvPath | ForEach {
		
		$updatedDesired = @{};
		for($num = 1; $num -le $columns; $num++)
		{ 
			if($_.PSObject.Properties.Value[$num]) 
			{
				$updatedDesired.add($_.PSObject.Properties.Name[$num], $_.PSObject.Properties.Value[$num]);
			}
		}
		
		#Creates/updates the desired properties for the twin device
		Update-AzIotHubDeviceTwin -ResourceGroupName $ResGroupName -IotHubName $IoTHubName -DeviceId $_.TwinDeviceName -Desired $updatedDesired
		Write-Output "Added Desired Properties to Twin Device " + $_.TwinDeviceName
	}
}