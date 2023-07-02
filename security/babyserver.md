# Here is a of ssh lockdown practices when I build a new server

## Here is my list of ssh lockdown practices when I build a new server

- Update the ssh server package and ensure that automatic updates are configured
- Enable SELinux and allow a non-standard ssh port
- Add my ssh public key to the server
- Disable password logins for ssh
- Adjust my `AllowUsers` setting in sshd_config to only allow my user
- Disable root logins
- For servers with sensitive data, I install `fail2ban`
