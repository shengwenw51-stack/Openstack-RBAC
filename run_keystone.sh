docker run -d --name keystone \
  -p 5000:5000 \
  -e KEYSTONE_ADMIN_PASSWORD=password \
  ghcr.io/openstack-k8s-operators/keystone-standalone:latest
