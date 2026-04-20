# Server Setup

Docker creates volume mount directories as `root:root`. Run this **after every `kamal deploy`** to fix permissions so `ec2-user` can deploy `index.html`.

```bash
ssh ec2-user@<server> 'bash -s' < bin/setup-server
```
