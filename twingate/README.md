# Creating the Twingate infrastructure

To create the Twingate infrastructure we will need a way to authenticate with Twingate. To do this we will create a new API key which we will use with Terraform.

In order to do so: Navigate to `Settings -> API` then `Generate a new Token`

You will need to set your token with `Read, Write & Provision` permissions, but you may want to restrict the allowed IP range to only where you will run your Terraform commands from.

Click on `generate` and `copy the token`.

## Setup Twingate Environment Variables

Set the follwing as environment variables

```bash
TF_VAR_tg_api_key="token-generated-earlier"
TF_VAR_tg_network="twingate-network" #e.g https://mycorp.twingate.com
```
