import os
import sys
import json
import random
import datetime
import requests
import csv
import asyncio
import time
import pandas as pd
from io import BytesIO
from azure.iot.device.aio import IoTHubDeviceClient
from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient

async def main():
    json_file = "update-reported-props.json"
    csv_file = "sample_telemetry_day.csv"
    container_name = "azure-webjobs-telemetry"
    storage_constr = "DefaultEndpointsProtocol=https;AccountName=rgdevscusspike001b132;AccountKey=UiBp4QC+xcYa6fl/e3E/hFTMHxMsHIEnx9/yhH4j2MVyPaLR/DmAWFQ5X2E9grcTF+c1ZlTm1M9W+AStzf8Cug==;EndpointSuffix=core.windows.net"

    # connect to blob containers
    blob_service_client = BlobServiceClient.from_connection_string(storage_constr)
    container_client = blob_service_client.get_container_client(container_name)

    # get json config data file
    blob_client = container_client.get_blob_client(json_file)
    streamdownloader = blob_client.download_blob()
    data = json.loads(streamdownloader.readall())

    # get connection string from config using device name as param
    deviceId = data["deviceIds"][str(random.randint(0, 1))]
    conn_str = data["connStrings"][deviceId]
    device_client = IoTHubDeviceClient.create_from_connection_string(conn_str)

    # connect the client.
    await device_client.connect()

    # get the current time string in HH:MM:SS format
    current_time = datetime.datetime.now().strftime("%H:%M:%S")

    # read the csv file
    blob_client = container_client.get_blob_client(csv_file)
    with BytesIO() as input_blob:
        blob_client.download_blob().download_to_stream(input_blob)
        input_blob.seek(0)
        reader = pd.read_csv(input_blob, low_memory = False)
    
    # filter first row using the current time HH:MM:SS
    current_row = reader[reader[data["colNames"]["2"]].eq(current_time)].iloc[0]

    # create the reported property
    reported_properties = {data["colNames"]["3"] : current_row[3] }

    # update the reported properties
    print("Sending property '" + data["colNames"]["3"] + "' value '" + str(current_row[3]) + "' to twin device " + deviceId)
    await device_client.patch_twin_reported_properties(reported_properties)

    # Finally, shut down the client
    await device_client.shutdown()

if __name__ == "__main__":
    while(True):
        asyncio.run(main())
        time.sleep(300)
