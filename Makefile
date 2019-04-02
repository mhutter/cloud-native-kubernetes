usage:
	@echo 'make [master|destroy|clean_known_hosts]'

master:
	hcloud server create \
		--image ubuntu-18.04 \
		--location fsn1 \
		--ssh-key rokkit2019 \
		--type cx21 \
		--user-data-from-file cloud-config-master.yml \
		--name master0.mhnet.ch

destroy: clean_known_hosts
	hcloud server delete master0.mhnet.ch

clean_known_hosts:
	sed -i .bak '/^(159|116)/d' ~/.ssh/known_hosts

.PHONY: usage master destroy clean_known_hosts
