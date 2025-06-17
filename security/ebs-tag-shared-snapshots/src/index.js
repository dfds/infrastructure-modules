import { EC2, ModifySnapshotAttributeCommand, CreateTagsCommand } from "@aws-sdk/client-ec2";
const client = new EC2({ region: process.env.AWS_REGION_RUN });
export const handler = async (event, context) => {
  const str = event.detail.snapshot_id
  const regex = /snap-\w+/;
  const match = str.match(regex);
  if (match) {
    console.log(event)
    const snapshotId = match[0];
    const snapshot_tags = process.env.SNAPSHOT_TAGS.split(',').map(tag => {
        var [Key, Value] = tag.split('=');
        return { Key, Value };
        })
    console.log(snapshot_tags);
    const tag_input = {
      Resources: [
        snapshotId
      ],
      Tags: snapshot_tags
    };
    try {
      const tag_command = new CreateTagsCommand(tag_input);
      const tag_response = await client.send(tag_command);
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