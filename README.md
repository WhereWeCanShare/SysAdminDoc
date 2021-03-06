# SysAdminDoc

System Document is in [Wiki](https://github.com/WhereWeCanShare/SysAdminDoc/wiki)

Initially, would like to have all my Linux system admin written here but checking on some of my [bash script gist](https://gist.github.com/wannadrunk) and found some outdated. Better push the updated ones here as well. It will slowly push as it requires to revise first for more generic use or less edit.

## scripts

suggest to have these scripts in `/opt/scripts`. Have to edit some variables to suitable your environment e.g. `BAKDIR`, `LOGDIR`, and etc. Those variables normally define at the top of script.

- [chkport.sh](scripts/chkport.sh) for checking the service network port, it requires `nc` which may not be available on some Linux distro. [Search for one](https://duckduckgo.com/?q=linux+nc+ncat) for its replacement.

- [dbbak.sh](scripts/dbbak.sh) script to do the Postgresql DBs dump and compress.

- [chkdskspace.sh](scripts/chkdskspace.sh) provide the disk space info.

## extras

contain the extra scripts which require other external services and do a very specific job.

- [updipv6.sh](extras/updipv6.sh) to update the IPv6 to dynv6.com to maintain the accessibility via domain name.

### sample use

normally, those scripts will be put in cron job. Learn how to schedule a job at https://crontab.guru

`$ crontab -e`

```
0	8,18	*	*	*	/opt/scripts/chkdskspace.sh

*/2	*	*	*	*	/opt/scripts/chkport.sh 192.168.1.200 443 HTTPS
*/2	*	*	*	*	/opt/scripts/chkport.sh 192.168.1.200 22 SSH
*/2	*	*	*	*	/opt/scripts/chkport.sh 192.168.1.201 5432 Postgresql

# update the IPv6 DDNS
*/5 *   *   *   *   /opt/scripts/extras/updipv6.sh
```

For postgresql db backup, have to run under postgres account

`$ sudo su postgres`

`$ crontab -e`

```
0	0	*	*	*	/opt/scripts/dbbak.sh
```



## disclaimer

Use it on your own risk. All bash scripts run well on my Debian/Rasbain 10 buster.
