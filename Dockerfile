FROM python:3.10-slim

# 安裝系統相依套件
RUN apt-get update && apt-get install -y \
    gcc libffi-dev libssl-dev sqlite3 curl \
    && rm -rf /var/lib/apt/lists/*

# 安裝 Keystone、Gunicorn 與 OpenStack CLI
RUN pip install --no-cache-dir keystone python-openstackclient gunicorn

# 1. 建立設定檔目錄與寫入 SQLite 設定
RUN mkdir -p /etc/keystone && \
    echo '[DEFAULT]' > /etc/keystone/keystone.conf && \
    echo '[database]' >> /etc/keystone/keystone.conf && \
    echo 'connection = sqlite:////etc/keystone/keystone.db' >> /etc/keystone/keystone.conf

# 2. 初始化 Fernet Token 金鑰、資料庫與建立 admin 帳密
RUN keystone-manage fernet_setup --keystone-user root --keystone-group root && \
    keystone-manage credential_setup --keystone-user root --keystone-group root && \
    keystone-manage db_sync && \
    keystone-manage bootstrap \
      --bootstrap-password password \
      --bootstrap-admin-url http://localhost:5000/v3/ \
      --bootstrap-internal-url http://localhost:5000/v3/ \
      --bootstrap-public-url http://localhost:5000/v3/ \
      --bootstrap-region-id RegionOne

# 3. 正確清理 sys.argv 並從 keystone.server.wsgi 初始化應用程式
RUN python3 -c "open('/etc/keystone/wsgi.py', 'w').write('import sys\nsys.argv = sys.argv[:1]\nfrom keystone.server.wsgi import initialize_public_application\napplication = initialize_public_application()\n')"

EXPOSE 5000

# 讓 gunicorn 直接載入 /etc/keystone/wsgi.py 的 application
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--chdir", "/etc/keystone", "wsgi:application"]
