# Pre-requisites

- You must have Terraform installed on your computer.
- You must have an Amazon Web Services (AWS) account.
- You must exported your AWS credentials.

Please note that this code was written for Terraform 1.x.

## Deploy App Locally 👨🏾‍💻

To run the tripvibe app locally, follow these steps:

Clone the repository: `git clone https://github.com/junaidsaleem10144/tripvibe.git`

Navigate to the project directory:

```sh
cd tripvibe
```

## Install the dependencies

⬅️ Navigate to the `backend` folder and run

```sh
npm install
```

Navigate to the `frontend` folder and run ➡️

```sh
npm install
```

## Start the Backend Server

Create a `.env` file in the `backend` folder and provide the necessary environment variables. You can refer to the `.env.example` file for the required variables.

```json
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

## Start the Frontend Client

Create a `.env` file in the `frontend` folder and provide the follwoing environment variable.

```env
VITE_BACKEND_URL="http://127.0.0.1:4000/api"
```

Then run

```sh
npm run dev
```

Now, you can access the tripvibe app by opening your browser and visiting `http://localhost:4000`

# Deploy with Docker-Compose 🐬

Create a .env file in the root directory and while in the root directory run

```sh
docker-compose up
```

# Deploy with Terraform 🐢

Navigate to the `terraform/env/dev` directory then run 

```sh
terraform plan
```

Once you have confirmed that you're good with the proposed changes, run

```sh
terraform apply
```

Then click `yes` to allow terraform make the desired changes to your infrastructure.
