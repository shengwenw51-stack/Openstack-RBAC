# Openstack-RBAC

## Test
```
# 使用 pip 在 Mac 安裝輕量 CLI
pip3 install python-openstackclient

export OS_AUTH_URL=http://localhost:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_USERNAME=admin
export OS_PASSWORD=password
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default

openstack token issue
```
