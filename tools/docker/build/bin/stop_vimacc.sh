#!/bin/bash

sudo kill $(ps aux | grep -F 'AccVimacc' | grep -v -F 'grep' | awk '{ print $2 }')

