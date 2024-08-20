This example creates your new API client credentials.

To run this example:

1. Open a Terminal or shell instance.

2. Copy the below egcurl statement and paste it to the Terminal or shell instance.

3. Specify the location of your `.edgerc` file and the section header of the set of credentials to use.

5. Press `Enter` to run the egcurl statement.

   A successful call returns a new API client with its `credentialId`. Use this ID in both the update and delete examples.

For more information on the call used in this example, see https://techdocs.akamai.com/iam-api/reference/post-self-credentials.

```
python3 egcurl --eg-edgerc ~/.edgerc --eg-section default --request POST \
     --url "https://luna.akamaiapis.net/identity-management/v3/api-clients/self/credentials" \
     --header 'accept: application/json'
```