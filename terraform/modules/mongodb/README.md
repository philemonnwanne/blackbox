# How to Deploy MongoDB Atlas with Terraform on AWS

## Step 1: Create a MongoDB Atlas account

[Sign up for a free MongoDB Atlas account](https://www.mongodb.com/cloud/atlas/register), verify your email address, and log into your new account.

## Step 2: Generate MongoDB Atlas API access keys

Once you have an account created and are logged into MongoDB Atlas, you will need to generate an API key to authenticate the Terraform [MongoDB Atlas Provider](https://registry.terraform.io/providers/mongodb/mongodbatlas/).

Go to the top of the Atlas UI, click the `Gear Icon` to the right of the organization name you created, click `Access Manager` in the lefthand menu bar, click the `API Keys` tab, and then click the green `Create API Key` box.

Enter a description for the API key that will help you remember what it’s being used for — for example `Terraform API Key`. Next, you’ll select the appropriate permission for what you want to accomplish with Terraform. Both the `Organization Owner` and `Organization Project Creator` roles will provide access to complete this task, but by using the `principle of least privilege`, select the `Organization Project Creator role` in the dropdown menu and click Next.

Make sure to copy your `private key` and store it in a `secure location`. After you leave the current page, your full private key `will not be accessible`.

## Step 3: Add API Key Access List entry

MongoDB Atlas API keys have [specific endpoints](https://www.mongodb.com/docs/atlas/configure-api-access/#use-api-resources-that-require-an-access-list) that require an API Key Access List. Creating an API Key Access List ensures that API calls must originate from IPs or CIDR ranges given access.

On the same page, scroll down and click `Add Access List Entry`. If you are unsure of the IP address that you are running Terraform on (and you are performing this step from that machine), simply click `Use Current IP Address` and `Save`. Another option is to open up your IP Access List to all, but this comes with significant potential risk. To do this, you can add the following two CIDRs: `0.0.0.0/1` and `128.0.0.0/1`. These entries will open your IP Access List to at most 4,294,967,296 (or 2^32) IPv4 addresses and should be used with caution.

## Step 4: Defining the MongoDB Atlas Provider with environment variables

We will need to configure the MongoDB Atlas Provider using the MongoDB Atlas API Key you generated earlier (Step 2). We will be securely storing these secrets as [environment variables](https://www.cherryservers.com/blog/how-to-set-list-and-manage-linux-environment-variables#:~:text=Linux%20environment%20variables%20are%20dynamic,defined%20in%20the%20SHELL%20variable).

First, go to the terminal window and create Environment Variables with the below commands. This prevents you from having to hard-code secrets directly into Terraform config files (which is not recommended):

```sh
export MONGODB_ATLAS_PUBLIC_KEY="<insert your public key here>"
export MONGODB_ATLAS_PRIVATE_KEY="<insert your private key here>"
```