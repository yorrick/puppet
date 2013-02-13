#!/bin/bash

echo "Script params: <$@>" >> /var/log/ztask/ztask-debug.log

source /home/webapp/virtualenvs/home_automation/bin/activate \
    && /home/webapp/apps/home_automation/manage.py ztaskd $@
