This example updates the credentials from the create credentials example.

To run this example:

1. Open a Terminal or shell instance.

2. Copy the below egcurl statement and paste it to the Terminal or shell instance.

3. Specify the location of your `.edgerc` file and the section header of the set of credentials to use.

   The defaults here expect the `.edgerc` at your home directory and use the credentials under the heading of default.

4. Add the `credential_id` for the set of credentials created using the create example as a path parameter.

5. Edit the `expiresOn` date to today's date. Optionally, you can change the `description` value. The date cannot be more than two years out or it will return a 400.

4. Press `Enter` to run the egcurl statement.

   A successful call returns.

For more information on the call used in this example, see https://techdocs.akamai.com/iam-api/reference/put-self-credential.

```
credential_id=123456

python3 egcurl --eg-edgerc ~/.edgerc --eg-section default --request PUT \
  --url "https://luna.akamaiapis.net/identity-management/v3/api-clients/self/credentials/$credential_id" \
  --header "Accept: application/json" \
  --header "Content-Type: application/json" \
  --data '
{
    "status": "ACTIVE",
    "expiresOn": "2024-06-11T23:06:59.000Z",
    "description": "Update this credential"
}'
```