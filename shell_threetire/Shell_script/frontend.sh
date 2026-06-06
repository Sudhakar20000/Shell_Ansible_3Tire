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

dnf install nginx -y

VALIDATE $? "install nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "remove the default application"

rm -rf /tmp/frontend.tar.gz

curl -o /tmp/frontend.tar.gz https://raw.githubusercontent.com/daws-90s/expense-documentation/refs/heads/main/artifacts/expense-frontend-v3.tar.gz
VALIDATE $? "download the file"

cd /usr/share/nginx/html
tar -xzf /tmp/frontend.tar.gz 
VALIDATE $? "unarchive the file"

rm -rf /etc/nginx/default.d/expense.conf
VALIDATE $? "remove conf"

cp -r expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "cpoy thr conf file"

systemctl restart nginx
VALIDATE $? "reatart the nginx"
