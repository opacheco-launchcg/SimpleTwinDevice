import os
import sys
import asyncio
import json
import csv
import random
from azure.iot.device.aio import IoTHubDeviceClient

async def main():   
    with open('.\\update-reported-props.json') as json_data_file:
        data = json.load(json_data_file)

    # get connection string from config using device name as param
    conn_str = data['connStrings'][sys.argv[1]]
    device_client = IoTHubDeviceClient.create_from_connection_string(conn_str)

    # connect the client.
    await device_client.connect()

    # open data telemetry file
    reported_properties = {};
    with open('.\\sample_telemetry.csv', mode='r') as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        for row in csv_reader:
            if row[0] == sys.argv[1]:
                reported_properties = {};
                for idx in data['colNames']:
                    reported_properties = {data['colNames'][idx] : row[int(idx)] }

                    # update the reported properties
                    await device_client.patch_twin_reported_properties(reported_properties)

    # Finally, shut down the client
    await device_client.shutdown()

if __name__ == "__main__":
    asyncio.run(main())
