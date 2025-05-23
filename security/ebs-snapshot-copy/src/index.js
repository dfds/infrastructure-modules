import { EC2, ModifySnapshotAttributeCommand }from "@aws-sdk/client-ec2";
const client = new EC2({ region: process.env.AWS_REGION_RUN });
export const handler = async (event, context) => {
  const str = event.detail.snapshot_id
  const regex = /snap-\w+/;
  const match = str.match(regex);
  if (match) {
      const snapshotId = match[0];
      const input = {
        Attribute: "createVolumePermission",
        UserIds: process.env.DESTINATION_ACCOUNTS.split(","),
        OperationType: "add",
        SnapshotId: snapshotId
      };
    try {
      const command = new ModifySnapshotAttributeCommand(input);
      const data = await client.send(command);
        console.log(data);
      return data;
    }
    catch (err) {
      console.log(err, err.stack);
      throw err;
    }
  }
  else{
    console.log("no match!")
  }
};