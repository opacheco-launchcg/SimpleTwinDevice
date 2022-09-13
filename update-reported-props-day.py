import os
import sys
import asyncio
import json
import csv
import random
import datetime
import pandas as pd
from azure.iot.device.aio import IoTHubDeviceClient

async def main():   
    with open('.\\update-reported-props.json') as json_data_file:
        data = json.load(json_data_file)

    # get connection string from config using device name as param
    deviceId = data['deviceIds'][str(random.randint(0, 9))]
    conn_str = data['connStrings'][deviceId]
    device_client = IoTHubDeviceClient.create_from_connection_string(conn_str)

    # connect the client.
    await device_client.connect()

    # get the current time string in HH:MM:SS format
    current_time = datetime.datetime.now().strftime("%H:%M:%S")

    # read the csv file, low_memory prevents error when data doesn't match in all rows
    rows = pd.read_csv(".\\sample_telemetry_day.csv", low_memory=False)

    # filter rows using the current time HH:MM:SS
    current_rows = rows[rows['time']==current_time]

    # get first row data
    current_row = current_rows.iloc[0]
    reported_properties = {data['colNames']["3"] : current_row[3] }

    # update the reported properties
    print("Sending property '" + data['colNames']["3"] + "' value '" + str(current_row[3]) + "' to twin device " + deviceId)
    await device_client.patch_twin_reported_properties(reported_properties)

    # Finally, shut down the client
    await device_client.shutdown()

if __name__ == "__main__":
    asyncio.run(main())
