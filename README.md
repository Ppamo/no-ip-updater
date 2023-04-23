# No-Ip Updater

## Why?

I'm configuring a raspberry pi as a network server and this server has multiple network interfaces.   I tried to configure noip2 client, but it didn't work well with the multiple interfaces, even using the built-in interface selector.

So, I readed a little, and create this script to update the address manually.

&nbsp;

## How?

Following the information in this [article](https://www.noip.com/integrate/request), I did a small script that uses two curl calls to update the address, the first one to get the external ip address, the second one to update the groups/hosts.

&nbsp;

## Usage:

The scripts require four environment vars that are not defined in the file itself, this vars can be defined in the file **/etc/no-ip-updater.settings**, or setted as environment vars in the running shell, the vars are:

- **INTERFACE**: the name of the network interface used to update the address, e.g. *eth0*
- **GROUP**: the groups or hosts to update, e.g. *mytest.example.com*
- **SLEEP_PERIOD**: the time that the script will sleep between attempts of updates, e.g. *5m*
- **NETRC_PATH**: the path to the file where the credentials to the *dynupdate.no-ip.com* host are located, more information about .netrc file can be found in [here](https://everything.curl.dev/usingcurl/netrc), e.g. */home/user/.netrc*

If any of this environment vars are not defined the script will fail at start.

The script's output looks like this:

```sh
> Loading ./settings.sh file

> 2023-04-23 01:58:43.629668234-04:00
> Getting external IP address:
> Got IP 158.247.7.204
> Updating address
> Response nochg 158.247.7.204
> Sleeping...
```

The script writes output to stdout and to the file /var/log/no-ip-updater.prop, with properties used to check the updating status.

&nbsp;

## Service

A service unit file can be found in the repo as **no-ip-updater.service**, to install it use the following commands:

```sh
_$ ln -s $PWD/no-ip-updater.service /etc/systemd/system/no-ip-updater.service
_$ systemctl enable no-ip-updater.service
Created symlink /etc/systemd/system/default.target.wants/no-ip-updater.service → /opt/no-ip-updater/no-ip-updater.service.
```
