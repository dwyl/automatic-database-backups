
if [[ -z "$APP" ]]; then
  echo "Missing APP variable which must be set to the name of your app where the db is located"
  exit 1
fi

if [[ -z "$DATABASE" ]]; then
  echo "Missing DATABASE variable which must be set to the name of the DATABASE you would like to backup"
  exit 1
fi

if [[ -z "$DB_PASSWORD" ]]; then
  echo "Missing DB_PASSWORD variable which must be set to the password of the DATABASE you would like to backup"
  exit 1
fi

if [[ -z "$DB_USER" ]]; then
  echo "Missing DB_USER variable which must be set to the user of the DATABASE you would like to backup"
  exit 1
fi

if [[ -z "$DB_HOST" ]]; then
  echo "Missing DB_HOST variable which must be set to the user of the DATABASE you would like to backup"
  exit 1
fi

if [[ -z "$S3_BUCKET_PATH" ]]; then
  echo "Missing S3_BUCKET_PATH variable which must be set the directory in s3 where you would like to store your database backups"
  exit 1
fi


# install leftover and create /tmp/aws_install directory for new installation
rm -rf /tmp/aws && rm -rf /tmp/aws_install
mkdir /tmp/aws_install

# download and unzip aws cli tools to /tmp/aws
curl https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o /tmp/aws_install/awscli-bundle.zip
unzip /tmp/aws_install/awscli-bundle.zip -d /tmp/aws_install/
chmod +x /tmp/aws_install/awscli-bundle/install
/tmp/aws_install/awscli-bundle/install -i /tmp/aws

# new backup file name
BACKUP_FILE_NAME="$(date +"%Y-%m-%d-%H-%M")-$APP-$DATABASE.sql"


# if directory '/tmp/db-backups' doesn't exist, create it
if [ ! -d "/tmp/db-backups" ]; then
  mkdir -p /tmp/db-backups/
fi

# dump the current DB into /tmp/db-backups/<new-file-name>
./bin/mysqldump -u $DB_USER -h $DB_HOST -p$DB_PASSWORD --databases $DATABASE | gzip -c > "/tmp/db-backups/$BACKUP_FILE_NAME.gz"

# using the aws cli, copy the new backup to our s3 bucket
/tmp/aws/bin/aws s3 cp /tmp/db-backups/$BACKUP_FILE_NAME.gz s3://$S3_BUCKET_PATH/$DATABASE/$BACKUP_FILE_NAME.gz --region=$AWS_DEFAULT_REGION

echo "backup $BACKUP_FILE_NAME.gz complete"
