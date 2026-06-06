#!/bin/bash
LOGDIR=/var/log/roboshop
LOGFILE=$LOGDIR/$0.log
mkdir -r $LOGDIR
chown -R ec2-user:ec2-user $LOGDIR
chmod 755 -R $LOGDIR
R='e\[31m'
G='e\[32m'
Y='e\[33m'
N='e\[0m'
TIME_STAMP=$(date '+%Y-%m-%d-%H-M-%s')
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
}

dnf install mysql-server -y
VALIDATE $? "install mysql"

systemctl enable mysqld
systemctl start mysqld
VALIDATE $? "start and enable mysql"

mysql_secure_installation --set-root-pass ExpenseApp@1

VALIDATE $? "set root password"
