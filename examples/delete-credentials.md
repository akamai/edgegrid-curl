This example deletes your API client credentials.

To run this example:

1. Open a Terminal or shell instance.

2. Copy the below egcurl statement and paste it to the Terminal or shell instance.

3. Specify the location of your `.edgerc` file and the section header of the set of credentials to use.

   The defaults here expect the `.edgerc` at your home directory and use the credentials under the heading of default.

4. Add the `credential_id` from the update example to the path. You can only delete inactive credentials. Sending the request on an active set will return a 400. Use the update credentials example for deactivation.
   
   > **Important:** Don't use the credentials you're actively using when deleting a set of credentials. Otherwise, you'll block your access to the Akamai APIs.

5. Press `Enter` to run the egcurl statement.

   A successful call returns "" null.

For more information on the call used in this example, see https://techdocs.akamai.com/iam-api/reference/delete-self-credential.

```
credential_id=123456

python3 egcurl --eg-edgerc ~/.edgerc --eg-section default --request DELETE \
     --url "https://luna.akamaiapis.net/identity-management/v3/api-clients/self/credentials/$credential_id" \
     --header 'accept: application/json'
```