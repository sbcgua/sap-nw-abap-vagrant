#!/usr/bin/expect -f
spawn ./install.sh -s -k
set PASSWORD "SapPwd1!"
set timeout -1
expect "Do you agree to the above license terms? yes/no:"
send "yes\r"
expect "Please enter a password:"
send "$PASSWORD\r"
expect "Please re-enter password for verification:"
send  "$PASSWORD\r"
expect eof
