#!/bin/bash
LOGDIR=/var/log/roboshop
LOGFILE=$LOGDIR/$0.log
mkdir -p $LOGDIR
chown -R ec2-user:ec2-user $LOGDIR
chmod 755 -R $LOGDIR
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIME_STAMP=$(date '+%Y-%m-%d %H:M:%S')
CURRENT_USER=$(id -u)

if [ $CURRENT_USER -ne 0 ]; then
    echo "$TIME_STAMP [ERROR] $R swithch to root user $N" | tee -a $LOGFILE
    exit 1
fi

VALIDATE () {
    if [ $1 -ne 0 ]; then
        echo "$TIME_STAMP [ERROR] $R error during $2 .. $N" | tee -a $LOGFILE
        exit 1
        else
        echo "$TIME_STAMP [SUCCESS] $G suceuessfully done $2 .. $N" | tee -a $LOGFILE
    fi
}

dnf module disable nodejs -y &> $LOGFILE
VALIDATE $? "disable default nodejs"

dnf module enable nodejs:20 -y &> $LOGFILE
VALIDATE $? "enable nodejs 20"

dnf install nodejs -y
VALIDATE $? "install nodajs 20"

mkdir /app
VALIDATE $? "create directory"

useradd --system --home /app --shell /sbin/nologin --comment "expense system user" expense
VALIDATE $? "create systemm user"

curl -o /tmp/backend.tar.gz https://raw.githubusercontent.com/daws-90s/expense-documentation/refs/heads/main/artifacts/expense-backend-v3.tar.gz
VALIDATE $? "download file"

cd /app
tar -xzf /tmp/backend.tar.gz 
VALIDATE $? "unarchive the file"

cd /app
npm install
VALIDATE $? " install npm packages"

cp -r backend.service /etc/systemd/system/backend.service
VALIDATE $? "copy the service file"

dnf install mysql -y
VALIDATE $? "install mysql"

mysql -h mysql.sudhakar.shop -u root -pExpenseApp@1 < /app/schema/backend.sql
VALIDATE $? "load the script"

systemctl daemon-reload
VALIDATE $? "reload daemon"

systemctl enable backend
systemctl start backend
VALIDATE $? "enable and start backend"

