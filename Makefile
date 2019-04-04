RAND_ID = $(shell openssl rand -hex 2)
COWS = $(shell hcloud server list -o noheader -o columns=name | grep '^cow-')

IMAGE = ubuntu-18.04
LOCATION = fsn1
SSH_KEY = rokkit2019
TYPE = cx21

RANCHER_VERSION = v2.2.1
RANCHER_SERVER = rancher.mhnet.ch
RANCHER_TOKEN = SET ME
RANCHER_ROLES = --etcd --controlplane --worker

usage:
	@echo 'make [cow|destroy|clean_known_hosts]'

cow: $(addprefix cow_,$(RAND_ID))

cow_%: cloud-config.yml
	hcloud server create \
		--image $(IMAGE) \
		--location $(LOCATION) \
		--ssh-key $(SSH_KEY) \
		--type $(TYPE) \
		--user-data-from-file cloud-config.yml \
		--name "cow-$(RAND_ID).mhnet.ch"

cloud-config.yml:
	sed \
		-e 's/%RANCHER_VERSION%/$(RANCHER_VERSION)/' \
		-e 's/%RANCHER_SERVER%/$(RANCHER_SERVER)/' \
		-e 's/%RANCHER_TOKEN%/$(RANCHER_TOKEN)/' \
		-e 's/%RANCHER_ROLES%/$(RANCHER_ROLES)/' \
		cloud-config.tpl.yml > cloud-config.yml

destroy: clean_known_hosts $(addprefix destroy_,$(COWS))
	rm cloud-config.yml

destroy_%:
	hcloud server delete $*

clean_known_hosts:
	sed -i .bak -E '/^(159|116)/d' ~/.ssh/known_hosts

.PHONY: usage cow destroy clean_known_hosts cloud-config.yml
