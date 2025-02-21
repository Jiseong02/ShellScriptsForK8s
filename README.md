# ShellScriptsForK8s

Calico를 사용한 초기화는 '단일 네트워크 인터페이스' 환경을 가정하고 있습니다.
다중 네트워크 인터페이스 환경에선 API 서버 접근 경로를 명확히 명시하기 위해 kubeadm init 명령과 함께 --apiserver-advertise-address=주소 를 추가하는 걸 추천합니다!!
