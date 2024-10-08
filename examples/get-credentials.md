This example returns a list of your API client credentials.

To run this example:

1. Open a Terminal or shell instance.

2. Copy the below egcurl statement and paste it to the Terminal or shell instance.

3. Append the path to your `.edgerc` file and the section header of the set of credentials to use.

   The defaults here expect the `.edgerc` at your home directory and use the credentials under the heading of default.

4. Press `Enter` to run the egcurl statement.

   A successful call returns your credentials grouped by `credential_id`.

For more information on the call used in this example, see https://techdocs.akamai.com/iam-api/reference/get-self-credentials.

```
python3 egcurl --eg-edgerc ~/.edgerc --eg-section default --request GET \
    --url "https://luna.akamaiapis.net/identity-management/v3/api-clients/self/credentials" \
    --header "Accept: application/json"
```