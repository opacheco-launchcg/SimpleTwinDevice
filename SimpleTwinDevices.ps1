# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

az login

<#
.PARAMETER ResGroupName
Use this to specify the Resource Group name where twin devices will be created.

.PARAMETER IoTHubName
Use this to specify the IoT Hub Name name where twin devices will be created.

.PARAMETER DeviceName
Use this to specify the Parent Device Name name where twin devices will be created.

.PARAMETER CsvPath
Use this to specify the path to the CSV containing the import data.

.EXAMPLE
.\SimpleTwinDevices.ps1
#>

$CsvPath = "C:\Users\OPacheco\Downloads\SimpleTwinDevices\Sample_Telemetry.csv";
$ResGroupName = "MyTestResGroup";
$DeviceName = "iot-dev-test-spike";
$IoTHubName = "TestParentDevice";

#Creates a new Resource Group
az group create --name $ResGroupName --location eastus

#Creates an IoT Hub in the newly created resource group
az iot hub create --resource-group $ResGroupName --name $IoTHubName

#Creates a device that will serve as parent for the twin devices
Add-AzIotHubDevice -ResourceGroupName $ResGroupName  -IotHubName $IoTHubName -DeviceId $DeviceName -AuthMethod "shared_private_key" -EdgeEnabled

Import-Csv -Path $CsvPath | ForEach {
	#Creates the twin Device with the specified name 
	Add-AzIoTHubDevice -ResourceGroupName $ResGroupName -IoTHubName $IoTHubName -ParentDeviceId $DeviceName -DeviceId $_.TwinDeviceName -AuthMethod "shared_private_key"

	$updatedTag = @{};
	$updatedDesired = @{};
	$columns = $_.PSObject.Properties.Name.count - 1;

	#Create the corresponding tags for Weather event 
	if($_.Event.contains("Weather"))
	{
		for($num = 1; $num -le 4; $num++)
		{
			$updatedTag.add($_.PSObject.Properties.Name[$num], $_.PSObject.Properties.Value[$num]);
		}
		Update-AzIotHubDeviceTwin -ResourceGroupName $ResGroupName -IotHubName $IoTHubName -DeviceId $_.TwinDeviceName -Tag $updatedTag
	}
	#Create the corresponding desires for Telemetry event
	elseif($_.Event.contains("Tracker"))
	{
		$updatedDesired.add($_.PSObject.Properties.Name[1], $_.PSObject.Properties.Value[1])
		for($num = 5; $num -le $columns; $num++)
		{
			$updatedDesired.add($_.PSObject.Properties.Name[$num], $_.PSObject.Properties.Value[$num]);
		}
		Update-AzIotHubDeviceTwin -ResourceGroupName $ResGroupName -IotHubName $IoTHubName -DeviceId $_.TwinDeviceName -Desired $updatedDesired
	}
}