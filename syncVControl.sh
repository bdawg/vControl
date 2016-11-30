#!/usr/bin/env bash

rsync -rtuv lestat@133.40.162.196:~/code/vControl/* ~/code/vControlTempDev/
rsync -rtuv ~/code/vControlTempDev/* lestat@133.40.162.196:~/code/vControl