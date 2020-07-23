#!/bin/bash
kill $(ps aux | grep '[j]ekyll' | awk '{print $2}')
