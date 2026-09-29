# 1. 建立 Domain 1 (如你的圖示)
openstack domain create Domain1

# 2. 在 Domain1 內建立兩個隔離的 Project (Project_DB 與 Project_k8s)
openstack project create Project_DB --domain Domain1
openstack project create Project_k8s --domain Domain1

# 3. 建立測試使用者 Alice
openstack user create alice --domain Domain1 --password secret

# 4. 指派 Role Assignment：給予 Alice 在 Project_DB 擁有 member 角色
openstack role add --project Project_DB --project-domain Domain1 --user alice --user-domain Domain1 member

# 5. 驗證情境 A：Alice 成功取得 Project_DB 的 Token
openstack --os-auth-url http://localhost:5001/v3 \
          --os-username alice \
          --os-password secret \
          --os-user-domain-name Domain1 \
          --os-project-name Project_DB \
          --os-project-domain-name Domain1 \
          token issue

# 6. 驗證情境 B：Alice 嘗試越界取得 Project_k8s 的 Token (應被拒絕)
openstack --os-auth-url http://localhost:5001/v3 \
          --os-username alice \
          --os-password secret \
          --os-user-domain-name Domain1 \
          --os-project-name Project_k8s \
          --os-project-domain-name Domain1 \
          token issue
