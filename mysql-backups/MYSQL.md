# Automatic mysql backups on heroku deployment

Set up external mysqly backups to an S3 bucket to take place automatically every time you deploy to Heroku.

## Steps
1) Create an S3 bucket
2) Using your Amazon console, add an IAM user with the following security policy:

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1210229835000",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::YOUR-S3-BUCKET-NAME/*"
      ]
    }
  ]
}
```
(Replace the 'YOUR-S3-BUCKET-NAME' in the security policy with your s3 bucket name)

This will give the user write access to the bucket. Copy over the user's AWS access key and secret key to the environment variables.

3) Add the following environment variables
```

DB_PASSWORD (from database url)

DB_USER (from database url)

DB_HOST (from database url)

DATABASE (database name from database url)

APP (your heroku app name)

S3_BUCKET_PATH (the name of your s3 backups e.g. app-backups)

AWS_ACCESS_KEY_ID (for your newly created IAM user)

AWS_DEFAULT_REGION (e.g. eu-west-1)

AWS_SECRET_ACCESS_KEY (for your newly created IAM user)
```

4) Add a mysql buildpack to your Heroku app with the following command in your terminal

```heroku buildpacks:add --index 1 https://github.com/Shopify/heroku-buildpack-mysql.git --app YOURHEROKUAPPNAME```

5) Copy over our bin folder and .buildpacks file

> After deploying, you can test whether the script will run by running the following command in your terminal: `$ heroku run ./bin/backup.sh`. It is also a good idea to test it will run locally using by running `$ ./bin/backup.sh` which will require you to give the script executable permissions: `chmod +x ./bin/backup.sh`

6) Add the following scripts to your package.json

```
"backup":"bash ./bin/backup.sh",
"postinstall": "npm run backup"
```

The automatic backups on deploy should now be complete! The postinstall script should automatically run after your node modules have installed on Heroku and should save a backup of your database to the specified S3 bucket.


7) Set up a [Heroku Scheduler](https://devcenter.heroku.com/articles/scheduler) to perform daily backups. Just add the backup script `$ bash ./bin/backup.sh` to a scheduler and set it to run every night.
