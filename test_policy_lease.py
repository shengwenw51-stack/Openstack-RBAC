from oslo_policy import policy

# 1. 模擬 OpenStack Ironic 官方對 Node 操作的 Policy 規則：
# 規定：必須具備 member 角色，而且 Token 的 project_id 必須是 Node 的 owner OR lessee
rules = [
    policy.RuleDefault(
        name="baremetal:node:power_action",
        check_str="role:member and (project_id:%(owner_project_id)s or project_id:%(lessee_project_id)s)"
    )
]

# 初始化 oslo.policy 引擎並註冊規則
enforcer = policy.Enforcer(conf={})
enforcer.register_defaults(rules)

# 2. 模擬 Ironic 內的資源（Server D1 P2，擁有者是 Project Infra，租給 Project DB）
ironic_node = {
    "name": "Server_D1_P2",
    "owner_project_id": "project_infra_id",
    "lessee_project_id": "project_db_id"  # Lease 給 P1 (Project DB)
}

print("=== 開始模擬 Ironic Lease Policy 比對 ===\n")

# --- 測試情境 1：Project DB 的 member（合法 Lessee 承租人）---
credentials_db_user = {
    "roles": ["member"],
    "project_id": "project_db_id"  # 匹配 lessee_project_id
}

result_db = enforcer.authorize(
    rule="baremetal:node:power_action",
    target=ironic_node,
    creds=credentials_db_user,
    do_raise=False
)
print(f"1. [Project DB 使用者] 嘗試重啟 Server D1 P2 -> 驗證結果: {result_db}")
# 預期：True (因為 project_id 匹配 lessee_project_id)


# --- 測試情境 2：Project k8s 的 member（非租戶，越界請求）---
credentials_k8s_user = {
    "roles": ["member"],
    "project_id": "project_k8s_id"  # 既不是 Owner 也不是 Lessee
}

result_k8s = enforcer.authorize(
    rule="baremetal:node:power_action",
    target=ironic_node,
    creds=credentials_k8s_user,
    do_raise=False
)
print(f"2. [Project k8s 使用者] 嘗試重啟 Server D1 P2 -> 驗證結果: {result_k8s}")
# 預期：False (拒絕存取，會被微服務報 403 Forbidden)


# --- 測試情境 3：Project Infra 的 member（資源擁有者 Owner）---
credentials_infra_user = {
    "roles": ["member"],
    "project_id": "project_infra_id"  # 匹配 owner_project_id
}

result_infra = enforcer.authorize(
    rule="baremetal:node:power_action",
    target=ironic_node,
    creds=credentials_infra_user,
    do_raise=False
)
print(f"3. [Project Infra 使用者] 嘗試重啟 Server D1 P2 -> 驗證結果: {result_infra}")
# 預期：True (因為 project_id 匹配 owner_project_id)
