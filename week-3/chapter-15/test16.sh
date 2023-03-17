#! /bin/bash

exec 3<> testfile
read line <&3
echo "Read: $line"
echo "This is a test line" >&3
