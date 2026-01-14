# Proxmox VE host specific info
# Displays cluster status, VM/CT counts, and storage info

if command -v pvesh > /dev/null 2>&1; then
    # Cluster info
    PVE_VERSION=$(pveversion 2>/dev/null | awk -F'/' '{print $2}')
    PVE_CLUSTER=$(pvesh get /cluster/status --output-format=json 2>/dev/null | grep -o '"name":"[^"]*"' | head -1 | awk -F'"' '{print $4}')
    PVE_CLUSTER=${PVE_CLUSTER:-'standalone'}
    
    # Node status
    PVE_NODE=$(hostname -s)
    PVE_NODE_STATUS=$(pvesh get /nodes/${PVE_NODE}/status --output-format=json 2>/dev/null)
    
    # VM and CT counts
    PVE_VM_COUNT=$(pvesh get /nodes/${PVE_NODE}/qemu --output-format=json 2>/dev/null | grep -c '"vmid"' || echo "0")
    PVE_CT_COUNT=$(pvesh get /nodes/${PVE_NODE}/lxc --output-format=json 2>/dev/null | grep -c '"vmid"' || echo "0")
    PVE_VM_RUNNING=$(pvesh get /nodes/${PVE_NODE}/qemu --output-format=json 2>/dev/null | grep -c '"status":"running"' || echo "0")
    PVE_CT_RUNNING=$(pvesh get /nodes/${PVE_NODE}/lxc --output-format=json 2>/dev/null | grep -c '"status":"running"' || echo "0")
    
    # Storage info (local storage usage)
    PVE_STORAGE=$(pvesh get /nodes/${PVE_NODE}/storage --output-format=json 2>/dev/null | grep -o '"storage":"[^"]*"' | awk -F'"' '{print $4}' | tr '\n' ',' | sed 's/,$//')
    PVE_STORAGE=${PVE_STORAGE:-'N/A'}

    echo -e "===== PROXMOX VE INFO =========================================================
 ${COLOR_COLUMN}${COLOR_VALUE}- PVE Version${RESET_COLORS}........: ${PVE_VERSION}
 ${COLOR_COLUMN}${COLOR_VALUE}- Cluster${RESET_COLORS}............: ${PVE_CLUSTER}
 ${COLOR_COLUMN}${COLOR_VALUE}- VMs${RESET_COLORS}.................: ${PVE_VM_RUNNING}/${PVE_VM_COUNT} running
 ${COLOR_COLUMN}${COLOR_VALUE}- Containers${RESET_COLORS}.........: ${PVE_CT_RUNNING}/${PVE_CT_COUNT} running
 ${COLOR_COLUMN}${COLOR_VALUE}- Storage${RESET_COLORS}............: ${PVE_STORAGE}"
fi
