82 - Run Concourse on bosh-lite/AWS
===================================

Boot bosh-lite on aws
---------------------

See https://github.com/cloudfoundry/bosh-lite/blob/master/docs/aws-provider.md

The output of `vagrant up --provider=aws` will show the public IP, such as `54.1.2.3`.

You will later need inbound HTTP traffic to the host VM on AWS through to the concourse `web/0` worker at `10.244.8.2:8080`.

In the bosh-lite folder run:

```
vagrant ssh -c 'sudo iptables -t nat -A PREROUTING -p tcp -d $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4) --dport 8080 -j DNAT --to 10.244.8.2:8080'
```

Target BOSH
-----------

```
bosh target 54.1.2.3
```

The username and password are `admin` by default.

Upload assets
-------------

```
bosh upload release https://bosh.io/d/github.com/concourse/concourse
bosh upload release https://bosh.io/d/github.com/cloudfoundry-incubator/garden-linux-release
```

You also need a stemcell for the BOSH Warden CPI root filesystem:

```
bosh upload stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent
```

The three commands above can be run in parallel on different terminal windows.

Get manifest and deploy
-----------------------

```
curl -L -o concourse.yml https://raw.githubusercontent.com/concourse/concourse/develop/manifests/bosh-lite.yml

bosh deployment concourse.yml
bosh deploy
```

Wiring up the internet
----------------------

Once the `bosh deploy` completes you will have the 3 jobs running in 3 local containers:

```
$ bosh vms
Deployment `concourse'

+-----------+---------+---------------+-------------+
| Job/index | State   | Resource Pool | IPs         |
+-----------+---------+---------------+-------------+
| db/0      | running | concourse     | 10.244.8.6  |
| web/0     | running | concourse     | 10.244.8.2  |
| worker/0  | running | concourse     | 10.244.8.10 |
+-----------+---------+---------------+-------------+
```

Browser
-------

You can now access the Concourse Web UI via the Elastic IP on port 8080. E.g. http://54.1.2.3:8080

You can now download the `fly` CLI and place it in your `$PATH`.

Also, set `$ATC_URL` to the same URL, e.g. `http://54.1.2.3:8080`.
