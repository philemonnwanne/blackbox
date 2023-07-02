# Here is a of ssh lockdown practices when I build a new 🖥️

## Here is my list of ssh lockdown practices when I build a new server

- Update the ssh server package and ensure that automatic updates are configured
- Enable SELinux and allow a non-standard ssh port
- Add my ssh public key to the server
- Disable password logins for ssh
- Adjust my `AllowUsers` setting in sshd_config to only allow my user
- Disable root logins
- For servers with sensitive data, I install `fail2ban` 🚫

`Note:` You can decide wether to use the deafult ssh port or not while taking note of the tradeoffs

Paranoid syssdmins can make use of [port knocking](https://wiki.archlinux.org/title/Port_knocking), installing and configuring nftables or iptables is necessary to achieve this.

A session with port knocking may look like this:

```sh
$ ssh username@hostname # No response (Ctrl+c to exit)
^C
$ nmap -Pn --host-timeout 201 --max-retries 0  -p 1111 host #knocking port 1111
$ nmap -Pn --host-timeout 201 --max-retries 0  -p 2222 host #knocking port 2222
$ ssh user@host # Now logins are allowed
user@host's password:
```
