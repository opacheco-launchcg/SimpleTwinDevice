# create-twin-devices  
Powershell script to create and update twin devices in an Azure IoT Hub  

- Prerequisites: Install the following in your local computer  

https://docs.microsoft.com/en-us/cli/azure/ - Azure CLI  
https://dotnet.microsoft.com/en-us/download/dotnet/3.1 - .NET SDK 3.1.28  

- To use the script, simply use the powershell command (all params are optional):  

create-twin-devices.ps1 -addTags [1/true, 0/false] -addParams [1/true, 0/false] -createAll [1/true, 0/false]  

-addTags: If true, will create/update twin devices Tags  
-addParams: If true, will create/update twin devices Desired Properties  
-createAll: If true, will attempt to create Resource Group, IoT Hub, Parent Device and Twin Devices  

# update-reported-props
Python script to process telemetry data and send it as reported properties  

- Prerequisites: Install the following in your local computer  

https://www.python.org/downloads/ - Python  
Once Python is installed run the following commands  

pip install azure-iot-device
pip install pandas  

- To use the script, run cmd. Navigate to the folder containing the script and run  

python update-reported-props.py deviceName 

-deviceName: The name of the device which will be updated. The connection string to this device must be specified in the json file

# create-postgresql-script  
SQL script to create the postgreSQL database schema  

- Prerequisites: Install the following in your local computer  

https://www.enterprisedb.com/downloads/postgres-postgresql-downloads - PostgreSQL  

Follow [this guide](https://docs.microsoft.com/en-us/azure/postgresql/single-server/tutorial-design-database-using-azure-portal) to create a PotgreSQL server in the desired IoT Hub  
Once this is done, open a cmd window, go to the installation folder of postgreSQL and run the following:

psql "host={your_servername}.postgres.database.azure.com port=5432 dbname=postgres user={your_user} password={your_password} sslmode=require"  

This will connect to your db server and allow you to run SQL commands. Create a Database in your server using the following command:  

CREATE DATABASE database_name;

You can connect to the created database and run the schema script. Here's an example of how to create a connection to the Azure server

![Connect to Azure](https://github.com/opacheco-launchcg/telemetry-scripts/blob/main/create-postgresql-script/pgadmin-connection.JPG)
