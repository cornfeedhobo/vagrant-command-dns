VagrantPlugins::CommandDns
==========================


# Installation
```
vagrant plugin install vagrant-command-dns
```


# Configuration
- [optional] `aliases` List of FQDNs to register this box's ip with
- [optional] `route53_version` The version of the AWS api to use
- [optional] `route53_access_key_id` The access key ID for accessing AWS
- [optional] `route53_secret_access_key` The secret access key for accessing AWS
- [optional] `route53_session_token` The token associated with the key for accessing AWS
- [optional] `route53_zone_id` The Route53 Zone ID


# Usage
```
vagrant dns
Usage: vagrant dns <subcommand>

Available subcommands:
     host
     ip
     route53

For help on any individual subcommand run `vagrant dns <subcommand> -h`
```


## Hostname and Aliases
The hostname and any aliases will be used to create records
```
config.vm.hostname = "www.example.com"
config.route53.aliases = ["alias.example.com", "alias2.example.com"]
```


## Network
This plugin works only for `:private_network` and `:public_network`.
```
config.vm.network :private_network, ip: "172.18.7.1"
```

or

```
config.vm.network :public_network
```


## Box Providers
Currently only VirtualBox is supported, because that is what I have to test with.

Pull requests are welcome.


## DNS Providers
Currently only editing the host's (linux/osx) `/etc/hosts` file and AWS Route53 are supported.

Pull requests are welcome.


# Route53
## IAM Permissions
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "route53:CreateHostedZone",
                "route53:GetHostedZone",
                "route53:ListHostedZones",
                "route53:ChangeResourceRecordSets",
                "route53:ListResourceRecordSets"
            ],
            "Resource": [
                "arn:aws:route53:::hostedzone/1A2B3C4D5E6F"
            ]
        }
    ]
}
```


# FAQ
Q) I reloaded my box and the `dns` command is only returning the VirtualBox NAT interface.
A) Run reload once more. This is a known issue with no workaround at the moment.


# Shortfalls
- Untested in multi-machine environments
- Does not support Windows hosts or guests


# Sponsors
This plugin was made possible by [Shiftgig](https://www.shiftgig.com)


# Contributing
Pull requests are welcome on GitHub at https://github.com/[USERNAME]/vagrant-command-dns.

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


# License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
