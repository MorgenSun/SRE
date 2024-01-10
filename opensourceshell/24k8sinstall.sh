#!/bin/sh


echo 'Start to Install Docker Service'
sh /root/opensourceshell/22dockerandcompose.sh

ulimit -SHn 65535  #这条命令设置了软限制（soft limit）和硬限制（hard limit）的文件描述符数量为
cat >> /etc/security/limits.conf <<EOF
* soft nofile 655360 #设置了所有用户的文件描述符数量限制
* hard nofile 131072 #设置了所有用户的文件描述符数量限制
* soft nproc 655350 #设置了所有用户的进程数量限制
* hard nproc 655350 #设置了所有用户的进程数量限制
* soft memlock unlimited #试图设置内存锁定限制
* hard memlock unlimited #试图设置内存锁定限制
EOF


#系统级别启用overlay、br_netfilter模块
#overlay支持Docker等其他容器运行时
#overlay文件系统允许容器镜像层以轻量级、高效的方式被挂载和管理，对于实现容器镜像的分层和共享非常关键。

#br_netfilter增加了k8s对于数据包过滤、网络隔离和安全通信、流量的入向出向的管控更细致
cat <<EOF | sudo tee /etc/modules-load.d/crio.conf
overlay
br_netfilter
EOF

# Set up required sysctl params, these persist across reboots.
#IPV4 IPV6流量通过iptables管理  IPV4流量转发
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF


sudo modprobe overlay
sudo modprobe br_netfilter


sudo sysctl --system
#关闭Swap
sed -ri 's/.*swap.*/#&/' /etc/fstab




filename="kubectlkubeadmin.zip"
folderpath="/app/server/"

#Download the installation package in private cloud depends on nginx
if [ -d $folderpath ];then
   echo $folderpath ready
else
  mkdir -p $folderpath
  info "$folderpath folder has been created"
fi
wget http://download.mylab.local:8888/$filename -P $folderpath >/dev/null 2>&1
cd $folderpath/
unzip kubectlkubeadmin.zip
cd  kubectlkubeadmin
yum localinstall -y *
rm -rf /app/server/kubectlkubeadmin
rm -rf $folderpath/$filename
systemctl enable kubelet

containerd config default > /etc/containerd/config.toml
grep sandbox_image  /etc/containerd/config.toml
sed -i "s#registry.k8s.io/pause#registry.aliyuncs.com/google_containers/pause#g"       /etc/containerd/config.toml
grep sandbox_image  /etc/containerd/config.toml

#cat >/etc/docker/daemon.json<<EOF
#{
#   "registry-mirrors": [ "https://xxx.mirror.aliyuncs.com",
#    "https://hub-mirror.c.163.com/",
#    "https://reg-mirror.qiniu.com",
#    "https://docker.mirrors.ustc.edu.cn",
#    "https://dockerhub.azk8s.cn",
#    "https://registry.docker-cn.com"]
#}
#EOF
systemctl daemon-reload
systemctl reload docker
systemctl status docker kubelet containerd


#runtime-endpoint: unix:///run/containerd/containerd.sock:
# 这一行指定了 crictl 命令与容器运行时（container runtime）进行通信的端点。
# 在这里，它设置为使用 containerd 的 UNIX 套接字文件。
# 这意味着 crictl 将通过这个套接字与 containerd 进行通信。

#image-endpoint: unix:///run/containerd/containerd.sock:
# 这一行指定了用于容器镜像管理的端点，它也被设置为 containerd 的 UNIX 套接字。
# 这表明容器镜像的管理也是通过 containerd 进行的。

cat <<EOF> /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
EOF

###containerd 使用 systemd 的 cgroup 驱动，而不是默认的 cgroupfs 驱动。
sed -i 's#SystemdCgroup = false#SystemdCgroup = true#g' /etc/containerd/config.toml
# 应用所有更改后,重新启动containerd
systemctl restart containerd


folderpath="/app/server/"
cd $folderpath
filename2="k8s128-4.zip"
wget http://download.mylab.local:8888/$filename2 -P $folderpath >/dev/null 2>&1
unzip k8s128-4.zip
cd k8s128-4
for i in $(ls);do ctr images import $i;done
rm -rf /app/server/k8s128-4/
rm -rf $folderpath/$filename2

#ctr images pull registry.aliyuncs.com/google_containers/kube-apiserver:v1.28.0
#ctr images pull registry.aliyuncs.com/google_containers/kube-controller-manager:v1.28.4
#ctr images pull registry.aliyuncs.com/google_containers/kube-scheduler:v1.28.4
#ctr images pull registry.aliyuncs.com/google_containers/kube-proxy:v1.28.4
#ctr images pull registry.aliyuncs.com/google_containers/pause:3.9
#ctr images pull registry.aliyuncs.com/google_containers/etcd:3.5.9-0
#ctr images pull registry.aliyuncs.com/google_containers/coredns:v1.10.1
#crictl images pull registry.aliyuncs.com/google_containers/coredns:v1.9.3

#使得containerd有能力从私有镜像仓库harbor.mylab.local拉取镜像
cat << EOF > /etc/containerd/config.toml
disabled_plugins = []
imports = []
oom_score = 0
plugin_dir = ""
required_plugins = []
root = "/var/lib/containerd"
state = "/run/containerd"
temp = ""
version = 2

[cgroup]
  path = ""

[debug]
  address = ""
  format = ""
  gid = 0
  level = ""
  uid = 0

[grpc]
  address = "/run/containerd/containerd.sock"
  gid = 0
  max_recv_message_size = 16777216
  max_send_message_size = 16777216
  tcp_address = ""
  tcp_tls_ca = ""
  tcp_tls_cert = ""
  tcp_tls_key = ""
  uid = 0

[metrics]
  address = ""
  grpc_histogram = false

[plugins]

  [plugins."io.containerd.gc.v1.scheduler"]
    deletion_threshold = 0
    mutation_threshold = 100
    pause_threshold = 0.02
    schedule_delay = "0s"
    startup_delay = "100ms"

  [plugins."io.containerd.grpc.v1.cri"]
    device_ownership_from_security_context = false
    disable_apparmor = false
    disable_cgroup = false
    disable_hugetlb_controller = true
    disable_proc_mount = false
    disable_tcp_service = true
    enable_selinux = false
    enable_tls_streaming = false
    enable_unprivileged_icmp = false
    enable_unprivileged_ports = false
    ignore_image_defined_volumes = false
    max_concurrent_downloads = 3
    max_container_log_line_size = 16384
    netns_mounts_under_state_dir = false
    restrict_oom_score_adj = false
    sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.6"
    selinux_category_range = 1024
    stats_collect_period = 10
    stream_idle_timeout = "4h0m0s"
    stream_server_address = "127.0.0.1"
    stream_server_port = "0"
    systemd_cgroup = false
    tolerate_missing_hugetlb_controller = true
    unset_seccomp_profile = ""

    [plugins."io.containerd.grpc.v1.cri".cni]
      bin_dir = "/opt/cni/bin"
      conf_dir = "/etc/cni/net.d"
      conf_template = ""
      ip_pref = ""
      max_conf_num = 1

    [plugins."io.containerd.grpc.v1.cri".containerd]
      default_runtime_name = "runc"
      disable_snapshot_annotations = true
      discard_unpacked_layers = false
      ignore_rdt_not_enabled_errors = false
      no_pivot = false
      snapshotter = "overlayfs"

      [plugins."io.containerd.grpc.v1.cri".containerd.default_runtime]
        base_runtime_spec = ""
        cni_conf_dir = ""
        cni_max_conf_num = 0
        container_annotations = []
        pod_annotations = []
        privileged_without_host_devices = false
        runtime_engine = ""
        runtime_path = ""
        runtime_root = ""
        runtime_type = ""

        [plugins."io.containerd.grpc.v1.cri".containerd.default_runtime.options]

      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]

        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          base_runtime_spec = ""
          cni_conf_dir = ""
          cni_max_conf_num = 0
          container_annotations = []
          pod_annotations = []
          privileged_without_host_devices = false
          runtime_engine = ""
          runtime_path = ""
          runtime_root = ""
          runtime_type = "io.containerd.runc.v2"

          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            BinaryName = ""
            CriuImagePath = ""
            CriuPath = ""
            CriuWorkPath = ""
            IoGid = 0
            IoUid = 0
            NoNewKeyring = false
            NoPivotRoot = false
            Root = ""
            ShimCgroup = ""
            SystemdCgroup = true

      [plugins."io.containerd.grpc.v1.cri".containerd.untrusted_workload_runtime]
        base_runtime_spec = ""
        cni_conf_dir = ""
        cni_max_conf_num = 0
        container_annotations = []
        pod_annotations = []
        privileged_without_host_devices = false
        runtime_engine = ""
        runtime_path = ""
        runtime_root = ""
        runtime_type = ""

        [plugins."io.containerd.grpc.v1.cri".containerd.untrusted_workload_runtime.options]

    [plugins."io.containerd.grpc.v1.cri".image_decryption]
      key_model = "node"

    [plugins."io.containerd.grpc.v1.cri".registry]
      config_path = ""

      [plugins."io.containerd.grpc.v1.cri".registry.auths]

      [plugins."io.containerd.grpc.v1.cri".registry.configs]

      [plugins."io.containerd.grpc.v1.cri".registry.headers]

      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."harbor.mylab.local"]
          endpoint = ["http://harbor.mylab.local"]

    [plugins."io.containerd.grpc.v1.cri".x509_key_pair_streaming]
      tls_cert_file = ""
      tls_key_file = ""

  [plugins."io.containerd.internal.v1.opt"]
    path = "/opt/containerd"

  [plugins."io.containerd.internal.v1.restart"]
    interval = "10s"

  [plugins."io.containerd.internal.v1.tracing"]
    sampling_ratio = 1.0
    service_name = "containerd"

  [plugins."io.containerd.metadata.v1.bolt"]
    content_sharing_policy = "shared"

  [plugins."io.containerd.monitor.v1.cgroups"]
    no_prometheus = false

  [plugins."io.containerd.runtime.v1.linux"]
    no_shim = false
    runtime = "runc"
    runtime_root = ""
    shim = "containerd-shim"
    shim_debug = false

  [plugins."io.containerd.runtime.v2.task"]
    platforms = ["linux/amd64"]
    sched_core = false

  [plugins."io.containerd.service.v1.diff-service"]
    default = ["walking"]

  [plugins."io.containerd.service.v1.tasks-service"]
    rdt_config_file = ""

  [plugins."io.containerd.snapshotter.v1.aufs"]
    root_path = ""

  [plugins."io.containerd.snapshotter.v1.btrfs"]
    root_path = ""

  [plugins."io.containerd.snapshotter.v1.devmapper"]
    async_remove = false
    base_image_size = ""
    discard_blocks = false
    fs_options = ""
    fs_type = ""
    pool_name = ""
    root_path = ""

  [plugins."io.containerd.snapshotter.v1.native"]
    root_path = ""

  [plugins."io.containerd.snapshotter.v1.overlayfs"]
    mount_options = []
    root_path = ""
    sync_remove = false
    upperdir_label = false

  [plugins."io.containerd.snapshotter.v1.zfs"]
    root_path = ""

  [plugins."io.containerd.tracing.processor.v1.otlp"]
    endpoint = ""
    insecure = false
    protocol = ""

[proxy_plugins]

[stream_processors]

  [stream_processors."io.containerd.ocicrypt.decoder.v1.tar"]
    accepts = ["application/vnd.oci.image.layer.v1.tar+encrypted"]
    args = ["--decryption-keys-path", "/etc/containerd/ocicrypt/keys"]
    env = ["OCICRYPT_KEYPROVIDER_CONFIG=/etc/containerd/ocicrypt/ocicrypt_keyprovider.conf"]
    path = "ctd-decoder"
    returns = "application/vnd.oci.image.layer.v1.tar"

  [stream_processors."io.containerd.ocicrypt.decoder.v1.tar.gzip"]
    accepts = ["application/vnd.oci.image.layer.v1.tar+gzip+encrypted"]
    args = ["--decryption-keys-path", "/etc/containerd/ocicrypt/keys"]
    env = ["OCICRYPT_KEYPROVIDER_CONFIG=/etc/containerd/ocicrypt/ocicrypt_keyprovider.conf"]
    path = "ctd-decoder"
    returns = "application/vnd.oci.image.layer.v1.tar+gzip"

[timeouts]
  "io.containerd.timeout.bolt.open" = "0s"
  "io.containerd.timeout.shim.cleanup" = "5s"
  "io.containerd.timeout.shim.load" = "5s"
  "io.containerd.timeout.shim.shutdown" = "3s"
  "io.containerd.timeout.task.state" = "2s"

[ttrpc]
  address = ""
  gid = 0
  uid = 0
EOF



#重新加载 systemd 并重载相关服务
systemctl daemon-reload
systemctl restart kubelet  docker containerd

#sudo kubeadm init  --image-repository=registry.aliyuncs.com/google_containers  --kubernetes-version=v1.28.4 --apiserver-advertise-address=192.168.31.20 --apiserver-cert-extra-sans=192.168.31.20,192.168.31.21,192.168.31.22,192.168.31.100 --pod-network-cidr="10.244.0.0/16" --node-name centos51   --control-plane-endpoint=192.168.31.20:6443  --upload-certs
echo 'all done'