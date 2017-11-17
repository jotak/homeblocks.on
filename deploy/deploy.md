# Setup & deploy

## Initial setup (any linux)

* Install docker... and make it work
* Copy "users" and "secret" folders to "/homeblocks"
* Eventually update secrets to match URL; also update oauth providers side
* Copy "start.sh" to "/homeblocks"
* Test it

Now, for automatic startup on server restart:

**On CentOS**

* Create /etc/systemd/system/homeblocks.service:

```
[Unit]
Wants=docker.service
After=docker.service

[Service]
RemainAfterExit=yes
ExecStart=/homeblocks/start.sh
ExecStop=/usr/bin/docker stop homeblocks

[Install]
WantedBy=multi-user.target
```

* Enable it:

```bash
sudo systemctl enable homeblocks.service
```

**On AWS (Amazon linux)**

```
ssh -i "aws-homeblocks.pem" ec2-user@ec2-54-186-250-175.us-west-2.compute.amazonaws.com
```

Startup script in /etc/rc.local
To update, just push (from local) the new docker image, and pull from AWS instance, then reboot instance
