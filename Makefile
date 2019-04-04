RAND_ID = $(shell openssl rand -hex 2)
MASTER = $(shell hcloud server list -o noheader -o columns=name | grep '^master-')
MASTER_IP = $(shell hcloud server list -o noheader -o columns=name,ipv4 | awk '/^master-/{ print $$2 }')
NODES = $(shell hcloud server list -o noheader -o columns=name | grep '^node-')

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

node: cloud-config-node.generated.yml
	hcloud server create \
		--image ubuntu-18.04 \
		--location fsn1 \
		--ssh-key rokkit2019 \
		--type cx21 \
		--user-data-from-file cloud-config-node.generated.yml \
		--name "node-$(RAND_ID).mhnet.ch"

master_ip:
	@echo $(MASTER_IP)

admin.conf:
	scp root@$(MASTER_IP):/etc/kubernetes/admin.conf .

join-command:
	scp root@$(MASTER_IP):/root/join-command .

cloud-config-node.generated.yml: join-command
	cat cloud-config-node.yml > cloud-config-node.generated.yml
	echo "  - $(shell cat join-command | tr -d '\n\\')" >> cloud-config-node.generated.yml

destroy: clean_known_hosts $(addprefix destroy_,$(MASTER)) $(addprefix destroy_,$(NODES))
	rm -f admin.conf

destroy_%:
	hcloud server delete $*

clean_known_hosts:
	sed -i .bak -E '/^(159|116)/d' ~/.ssh/known_hosts

.PHONY: usage master destroy clean_known_hosts
