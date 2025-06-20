import { EC2, ModifySnapshotAttributeCommand, CreateTagsCommand } from "@aws-sdk/client-ec2";
const client = new EC2({ region: process.env.AWS_REGION_RUN });
export const handler = async (event, context) => {
  const str = event.detail.snapshot_id
  const regex = /snap-\w+/;
  const match = str.match(regex);
  if (match) {
    const snapshotId = match[0];
    const att_input = {
      Attribute: "createVolumePermission",
      UserIds: process.env.DESTINATION_ACCOUNTS.split(","),
      OperationType: "add",
      SnapshotId: snapshotId
    };
    try {
      const att_command = new ModifySnapshotAttributeCommand(att_input);
      const att_response = await client.send(att_command);
      console.log(att_response);
    }
    catch (err) {
      console.log(err, err.stack);
      throw err;
    }
    return {
      statusCode: 200,
      body: JSON.stringify({
        message: "Snapshot attribute modified successfully",
        snapshotId: snapshotId
      })
    }
  }
  else {
    console.log("no snapshot ID was found!")
  }
};