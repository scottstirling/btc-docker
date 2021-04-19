#!/bin/bash
# NOTE: script must run as root or with root permissions

# Global Variables
# original test login accounts for testing / demo
users="bitcoin scott mallesh"

# If you need more test logins, set TEST_USER_BASENAME and TEST_USER_COUNT as needed to prepare more test accounts in the image
TEST_USER_COUNT=0
TEST_USER_BASENAME="theflash"
# test user default container login password 
TEST_USER_PASSWORD="b1tc01n"
# test user account rdp shared group
TEST_GROUP=bitcoin-clients

############
# loop as many times as desired to create $TEST_USER_COUNT on top of the original $users.
test_users=""
new_user="${TEST_USER_BASENAME}"

# concatenate a list of as many $test_users as needed for loop(s) below this one.
for i in $(seq 1 $TEST_USER_COUNT)
do
  new_user+="${i}"
  new_user+=" "
  test_users+="${new_user}"
  new_user="$TEST_USER_BASENAME"
done;

# add output of loop to $users set with a white space between
users+=" ${test_users}"

# 1) GROUP ADD - add common rdp group for test users, mainly for demo purposes and testing
addgroup ${TEST_GROUP}

# 2) USER ADD - create test user logins and add them to the test group
# and set test user passwords and initialize home dirs for management
for user in ${users}
do
  adduser --disabled-password --gecos '' ${user}
  usermod -aG ${TEST_GROUP} ${user}
  echo "${user}:${TEST_USER_PASSWORD}" | chpasswd
  # clean up permissions
  chown -v -R ${user}:${user} /home/${user}/
done;

