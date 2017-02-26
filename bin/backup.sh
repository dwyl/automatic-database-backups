#!/bin/bash

# edited version of the backup.sh from the repo:
# https://github.com/kbaum/heroku-database-backups
# p.s. THANKS kbaum <3

# terminate script as soon as any command fails
set -e

if [[ -z "$APP" ]]; then
  echo "Missing APP variable which must be set to the name of your app where the db is located"
  exit 1
fi

if [[ -z "$DATABASE" ]]; then
  echo "Missing DATABASE variable which must be set to the name of the DATABASE you would like to backup"
  exit 1
fi

if [[ -z "$S3_BUCKET_PATH" ]]; then
  echo "Missing S3_BUCKET_PATH variable which must be set the directory in s3 where you would like to store your database backups"
  exit 1
fi

#install aws-cli
curl https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o awscli-bundle.zip
unzip awscli-bundle.zip
chmod +x ./awscli-bundle/install
./awscli-bundle/install -i /tmp/aws

BACKUP_FILE_NAME="$(date +"%Y-%m-%d-%H-%M")-$APP-$DATABASE.dump"

# the next curl command logs us in with the heroku api key (i think)
curl -H "Accept: application/json" -n https://api.heroku.com/apps
./vendor/heroku-toolbelt/bin/heroku pg:backups capture $DATABASE --app $APP
curl -o $BACKUP_FILE_NAME `./vendor/heroku-toolbelt/bin/heroku pg:backups:url --app $APP`
gzip $BACKUP_FILE_NAME
/tmp/aws/bin/aws s3 cp $BACKUP_FILE_NAME.gz s3://$S3_BUCKET_PATH/$APP/$DATABASE/$BACKUP_FILE_NAME.gz --region $AWS_DEFAULT_REGION
echo "backup $BACKUP_FILE_NAME complete"
