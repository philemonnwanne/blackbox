# Pre-requisites

- You must have Terraform installed on your computer
- You must have an Amazon Web Services (AWS) account
- Create an s3 bucket
  - Click on Object Ownership and set it to `
    Bucket owner preferred`
  - Disable `Block all public access` settings
  - Then click on `Create bucket`

Please note that this code was written for Terraform 1.4.x

## Deploy App Locally 👨🏾‍💻

To run the tripvibe app locally, follow these steps

Clone the repository

```sh
git clone https://github.com/philemonnwanne/tripvibe
```

Navigate to the project directory:

```sh
cd tripvibe
```

### Install the dependencies

⬅️ Navigate to the `backend` folder and run

```sh
npm install
```

➡️ Navigate to the `frontend` folder and run

```sh
npm install
```

### Start the Backend Server

Create a `.env` file in the `backend` folder and provide the necessary environment variables. You can refer to the `.env.example` file for the required variables.

```.env
FRONTEND_URL=""
S3_BUCKET_NAME=""
AWS_REGION=""
AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""
MONGO_URL=""
```

Then run

```sh
npm start dev
```

### Start the Frontend Client

Create a `.env` file in the `frontend` folder and provide the following environment variable.

```env
VITE_BACKEND_URL="http://127.0.0.1:4000/api"
```

Then run

```sh
npm run dev
```

Now, you can access the tripvibe app by opening your browser and visiting `http://localhost:5173`

## Deploy with Docker-Compose 🐬

While in the root directory, create a .env file

```ruby
# FRONTEND
VITE_BACKEND_URL="http://127.0.0.1:4000/api"

# BACKEND
FRONTEND_URL="http://127.0.0.1:5173"
S3_BUCKET_NAME=""
AWS_REGION=""
AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""
MONGO_URL="mongodb://127.0.0.1:27017"
JWT_TOKEN=""

# DATABASE
MONGO_INITDB_ROOT_USERNAME="enter your username"
MONGO_INITDB_ROOT_PASSWORD="enter your password"

# APP VARS
APP_NAME="tripvibe"
```

Then run

```sh
docker-compose up
```

## Deploy with Terraform 🐢

You must have exported your AWS credentials

```sh
export AWS_REGION=(your aws region)
export AWS_ACCESS_KEY_ID=(your access key id)
export AWS_SECRET_ACCESS_KEY=(your secret access key)
```

### Please note that this example will deploy real resources into your AWS account. We have made every effort to ensure all the resources qualify for the [AWS Free Tier](https://aws.amazon.com/free/), but we are not responsible for any charges you may incur.*

### Required varibles

```python
grafana
domain name
grafana_account_id
external_id
aws_acm_certificate
```

Navigate to the frontend directory and run `npm run build` to generate a build folder, which terraform will upload its contents to your s3 bucket

Navigate to the `terraform/env/dev` directory then run 

```sh
terraform init
terraform plan
```

Once you have confirmed that you're good with the proposed changes, run

```sh
terraform apply
```

Clean up when you're done:

```sh
terraform destroy
```

## Deploy with Github Actions 🔁
