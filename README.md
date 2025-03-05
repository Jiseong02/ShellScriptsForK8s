# ShellScriptsForK8s
쿠버네티스를 통한 클러스터 서버 초기 환경 설정을 위한 리포지토리.

1. base - Basement settings for all nodes 
2. master - settings for master node
3. worker - settings for worker node (Soon)


## Tips
kubeadm reset 명령어 실행 후에는 반드시 (1)잔여 설정 파일을 모두 삭제한 후, (2)리부팅 할 것!!! => 남아있는 설정(네트워크, CNI 등)을 모두 초기화 해주기 위한 조치
