docker run -d --name keystone \
  -p 5000:5000 \
  -e KEYSTONE_ADMIN_PASSWORD=password \
  quay.io/podified-antelope-centos9/openstack-keystone:current-podified
