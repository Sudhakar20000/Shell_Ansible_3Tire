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
TIME_STAMP=$(date '+%Y-%m-%d %H:%M:%S')
CURRENT_USER=$(id -u)

if [ $CURRENT_USER -ne 0 ]; then
    echo -e "$TIME_STAMP [ERROR] $R swithch to root user $N" | tee -a $LOGFILE
    exit 1
fi

VALIDATE () {
    if [ $1 -ne 0 ]; then
        echo -e "$TIME_STAMP [ERROR] $R error during $2 .. $N" | tee -a $LOGFILE
        exit 1
        else
        echo -e "$TIME_STAMP [SUCCESS] $G suceuessfully done $2 .. $N" | tee -a $LOGFILE
    fi
}

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "disable default nodejs"

dnf module enable nodejs:20 -y &>> $LOGFILE
VALIDATE $? "enable nodejs 20"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "install nodajs 20"

mkdir /app &>> $LOGFILE
VALIDATE $? "create directory"

useradd --system --home /app --shell /sbin/nologin --comment "expense system user" expense &>> $LOGFILE
VALIDATE $? "create systemm user"

curl -o /tmp/backend.tar.gz https://raw.githubusercontent.com/daws-90s/expense-documentation/refs/heads/main/artifacts/expense-backend-v3.tar.gz &>> $LOGFILE
VALIDATE $? "download file"

cd /app &>> $LOGFILE
tar -xzf /tmp/backend.tar.gz &>> $LOGFILE
VALIDATE $? "unarchive the file"

cd /app &>> $LOGFILE
npm install &>> $LOGFILE
VALIDATE $? " install npm packages"

cp -r backend.service /etc/systemd/system/backend.service &>> $LOGFILE
VALIDATE $? "copy the service file"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "install mysql"

mysql -h mysql.sudhakar.shop -u root -pExpenseApp@1 < /app/schema/backend.sql &>> $LOGFILE
VALIDATE $? "load the script"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reload daemon"

systemctl enable backend &>> $LOGFILE
systemctl start backend &>> $LOGFILE
VALIDATE $? "enable and start backend"

