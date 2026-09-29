FROM python:3.10-slim

# 安裝系統相依套件
RUN apt-get update && apt-get install -y \
    gcc libffi-dev libssl-dev sqlite3 curl \
    && rm -rf /var/lib/apt/lists/*

# 安裝 Keystone、Gunicorn 與 OpenStack CLI
RUN pip install --no-cache-dir keystone python-openstackclient gunicorn

# 1. 建立設定檔目錄並配置 SQLite 與 Policy
RUN mkdir -p /etc/keystone && \
    echo '[DEFAULT]' > /etc/keystone/keystone.conf && \
    echo '[oslo_policy]' >> /etc/keystone/keystone.conf && \
    echo 'enforce_scope = false' >> /etc/keystone/keystone.conf && \
    echo '[database]' >> /etc/keystone/keystone.conf && \
    echo 'connection = sqlite:////etc/keystone/keystone.db' >> /etc/keystone/keystone.conf

# 2. 初始化 Fernet Token 金鑰、資料庫與完整 Domain/Project Admin 帳密 bootstrap
RUN keystone-manage fernet_setup --keystone-user root --keystone-group root && \
    keystone-manage credential_setup --keystone-user root --keystone-group root && \
    keystone-manage db_sync && \
    keystone-manage bootstrap \
      --bootstrap-password password \
      --bootstrap-username admin \
      --bootstrap-project-name admin \
      --bootstrap-role-name admin \
      --bootstrap-domain-id Default \
      --bootstrap-admin-url http://localhost:5000/v3/ \
      --bootstrap-internal-url http://localhost:5000/v3/ \
      --bootstrap-public-url http://localhost:5000/v3/ \
      --bootstrap-region-id RegionOne

# 3. 建立 WSGI 啟動腳本 (包含 sys.argv 清理)
RUN python3 -c "open('/etc/keystone/wsgi.py', 'w').write('import sys\nsys.argv = sys.argv[:1]\nfrom keystone.server.wsgi import initialize_public_application\napplication = initialize_public_application()\n')"

EXPOSE 5000

# 啟動 Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--chdir", "/etc/keystone", "wsgi:application"]
