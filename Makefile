RAND_ID = $(shell openssl rand -hex 2)
MASTER = $(shell hcloud server list -o noheader -o columns=name | grep '^master-')
MASTER_IP = $(shell hcloud server list -o noheader -o columns=name,ipv4 | awk '/^master-/{ print $$2 }')

usage:
	@echo 'make [master|destroy|clean_known_hosts]'

master:
	hcloud server create \
		--image ubuntu-18.04 \
		--location fsn1 \
		--ssh-key rokkit2019 \
		--type cx21 \
		--user-data-from-file cloud-config-master.yml \
		--name "master-$(RAND_ID).mhnet.ch"

master_ip:
	@echo $(MASTER_IP)

destroy: clean_known_hosts $(addprefix destroy_,$(MASTER))
	rm -f admin.conf

destroy_%:
	hcloud server delete $*

clean_known_hosts:
	sed -i .bak '/^(159|116)/d' ~/.ssh/known_hosts

.PHONY: usage master destroy clean_known_hosts
