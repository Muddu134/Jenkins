Role Name
=========

This role install rabbitmq on ubuntu/centos/redhat

Requirements
------------



Role Variables
--------------


supported versions
-----------------


Dependencies
------------
NA

Example Playbook
----------------

ansible-playbook -i stacks/localhost playbooks/common_role.yml -e "stack=localhost env=<itt/hp> role_name=rabbitmq action_type=install" -u ec2-user --key-file=/home/alam/Work/Terraform/itt-Alam.pem -vvv

License
-------

BSD

Author Information
------------------


