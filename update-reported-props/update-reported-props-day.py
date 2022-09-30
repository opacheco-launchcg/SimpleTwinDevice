import os
import sys
import asyncio
import json
import random
import datetime
import csv
from azure.iot.device.aio import IoTHubDeviceClient

async def main():
    print("Begin")
    with open(".\\update-reported-props.json") as json_data_file:
        data = json.load(json_data_file)

    # get connection string from config using device name as param
    deviceId = data["deviceIds"][str(random.randint(0, 1))]
    conn_str = data["connStrings"][deviceId]
    device_client = IoTHubDeviceClient.create_from_connection_string(conn_str)

    # connect the client.
    await device_client.connect()

    # get the current time string in HH:MM:SS format
    current_time = datetime.datetime.now().strftime("%H:%M:%S")

    # read the csv file, filter first row using the current time HH:MM:SS
    with open('.\\sample_telemetry_day.csv', encoding='utf8') as csvfile:
        reader = csv.reader(csvfile)
        current_row = next(filter(lambda row: row[2] == current_time, reader), None)

    # create the reported property
    reported_properties = {data["colNames"]["3"] : current_row[3] }

    # update the reported properties
    print("Sending property '" + data["colNames"]["3"] + "' value '" + str(current_row[3]) + "' to twin device " + deviceId)
    await device_client.patch_twin_reported_properties(reported_properties)

    # Finally, shut down the client
    await device_client.shutdown()


if __name__ == "__main__":
    asyncio.run(main())
