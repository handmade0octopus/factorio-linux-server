#!/bin/bash


sudo systemctl enable factorio-update.service
sudo systemctl enable factorio-update.timer
sudo systemctl start --no-block factorio-update.service
sudo systemctl start --no-block factorio-update.timer