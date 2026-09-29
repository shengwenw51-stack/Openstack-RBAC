docker run -d --name keystone \
  -p 5001:5000 \
  -e KEYSTONE_ADMIN_PASSWORD=password \
  openio/openstack-keystone
