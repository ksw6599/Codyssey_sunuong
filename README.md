# 코디세이 E1-1 · 내 컴퓨터에 개발자용 작업실 꾸미기

Windows에서 WSL 2로 Linux 작업 환경을 구성했다. 터미널로 파일과 권한을 조작하고, Docker로 NGINX 정적 웹 서버를 빌드했다. 같은 이미지를 두 포트로 실행하고, 바인드 마운트와 Docker 볼륨에서 변경 반영과 데이터 영속성을 각각 확인했다.

## 실행 환경

| 항목 | 실습 환경 |
| --- | --- |
| 호스트 / 터미널 | Windows 11 Home (빌드 26200) / PowerShell 터미널 |
| Linux / 셸 | WSL 2.7.14.0 / Ubuntu 24.04.5 LTS / Bash 5.2.21 |
| 컨테이너 | Docker Engine 29.9.3, 스토리지 드라이버 `overlayfs` |
| 버전 관리 / 편집기 | Git for Windows 2.56.0.windows.4 / Ubuntu Git 2.43.0 / VS Code 1.144.0 |

## 수행 결과

| 항목 | 확인 방법과 결과 |
| --- | --- |
| 터미널 | `pwd`, `ls -la`, `cd`, `mkdir`, `cp`, `mv`, `rm`, `cat`, `touch` 실행. 숨김 파일과 크기 0인 파일을 확인했다. |
| 권한 | `stat`으로 파일 `600 → 644`, 디렉터리 `700 → 755`를 확인했다. |
| Docker 설치 및 운영 | `docker --version`, `docker info`, `docker images`, `docker ps -a`, `docker logs`, `docker stats --no-stream`으로 상태를 확인했다. |
| 기본 컨테이너 | `hello-world`에서 성공 메시지를 받았다. Ubuntu에서 `ls`와 `echo`를 실행했다. |
| 커스텀 이미지 및 포트 | [Dockerfile](Dockerfile)로 `e11-workbench:1.0`을 빌드했다. 8781과 8782에서 모두 HTTP 200을 확인했다. |
| 바인드 마운트 | 호스트의 `index.html`만 바꾸자 컨테이너를 재시작하지 않아도 응답이 `host version 1`에서 `host version 2`로 바뀌었다. |
| Docker 볼륨 | 기록한 컨테이너를 삭제한 뒤 같은 볼륨을 읽기 전용으로 연결한 새 컨테이너에서 `e11-volume-record`를 읽었다. |
| Git과 GitHub | 로컬 저장소에 작성자 정보와 기본 브랜치 `main`을 설정하고, 기존 GitHub 저장소를 `origin`으로 연결했다. [Git 설정과 연결 로그](evidence/git.txt) |
| VS Code | 로컬 작업 폴더를 VS Code로 열었다. VS Code 내부의 GitHub 계정 로그인은 확인 대기 중이다. |

[실행 명령과 전체 출력](evidence/verification.log)은 `set -x`를 켜서 기록했다. 로컬 사용자 폴더명은 가렸다.

## 재현 방법

Windows에서 WSL 2를 사용하는 경우 PowerShell에서 Ubuntu를 설치한다. 기존 Linux 환경에서는 설치를 건너뛰고 배포판에 맞는 Docker Engine을 준비한다.

```powershell
wsl --install -d Ubuntu-24.04 --web-download --no-launch
wsl -d Ubuntu-24.04
```

Ubuntu에서는 [Docker 공식 APT 설치 절차](https://docs.docker.com/engine/install/ubuntu/#install-using-the-apt-repository)에 따라 Docker Engine과 Buildx를 설치한다. 설치 후 데몬을 시작하고 점검한다.

```bash
sudo systemctl enable --now docker
sudo systemctl is-active docker
sudo docker --version
sudo docker info --format 'Server={{.ServerVersion}} OS={{.OperatingSystem}} Driver={{.Driver}}'
```

```text
active
Docker version 29.9.3, build 5457199
Server=29.9.3 OS=Ubuntu 24.04.5 LTS Driver=overlayfs
```

이 저장소를 내려받아 Linux 셸에서 아래 명령을 실행한다. Docker 소켓을 이미 사용할 수 있으면 `sudo`를 생략한다. 스크립트는 8781과 8782를 사용하며, 실행이 끝나면 브라우저 확인용 `e11-web`을 8781에서 계속 실행한다.

```bash
git clone https://github.com/ksw6599/Codyssey_sunuong.git
cd Codyssey_sunuong
sudo bash scripts/verify.sh 2>&1 | tee /tmp/codyssey-e11-verification.log
curl -i http://127.0.0.1:8781/
```

브라우저에서 `http://127.0.0.1:8781/`을 열면 ‘개발 작업실’ 페이지가 표시된다. Windows에서 실행한 [HTTP 요청과 응답](evidence/windows-http.txt)도 같은 포트의 응답을 보여준다. 확인이 끝나면 `sudo docker rm -f e11-web`로 이 실습 컨테이너를 정리한다. 같은 이름을 쓰므로 스크립트를 다시 실행하기 전에도 이 컨테이너를 정리한다.

## 실습에서 확인한 동작

- **경로와 권한.** 실습 로그의 `/tmp/…/practice/notes.txt`는 루트에서 시작하는 절대 경로다. `practice`에 들어간 뒤 쓰는 `./notes.txt`는 현재 위치를 기준으로 하는 상대 경로다. 권한의 `r=4`, `w=2`, `x=1`을 소유자·그룹·기타 사용자별로 더한다. `644`는 `rw-r--r--`, `755`는 `rwxr-xr-x`다. 디렉터리의 `x`는 해당 경로 안으로 들어가거나 경로를 통과할 수 있는 권한이다.
- **이미지와 컨테이너.** `nginx:alpine`의 웹 서버 설정을 사용하고, `COPY app/`으로 서비스할 HTML을 이미지에 넣었다. `LABEL`은 이미지의 용도를 식별하는 메타데이터다. 실행 중인 컨테이너는 같은 이미지로 여러 개 만들 수 있다.
- **`exec`와 `attach`.** `docker exec`로 시작한 보조 셸이 끝난 뒤에도 컨테이너가 `running` 상태였다. `docker attach`는 기본 셸의 입출력에 연결하며, 그 셸을 종료하면 컨테이너도 `exited` 상태가 된다.
- **포트 매핑.** `-p 127.0.0.1:8781:80`은 호스트의 8781로 받은 요청을 컨테이너의 NGINX 포트 80으로 전달한다. 두 컨테이너는 내부에서 모두 80을 사용하고, 호스트에서는 8781과 8782로 각각 접근했다.
- **마운트와 볼륨.** 바인드 마운트는 호스트 디렉터리를 컨테이너에 연결한다. 볼륨은 Docker가 별도로 관리하는 저장 공간이라 컨테이너를 제거해도 남는다.
- **Git과 GitHub.** Git은 로컬에서 변경 이력과 커밋을 관리한다. GitHub는 저장소를 원격에 두고 공유하며 협업할 수 있게 한다. 작성자 정보는 이 저장소에만 적용했다.

## 트러블슈팅

1. **WSL은 설치되어 있었지만 Linux 배포판을 실행할 수 없었다.** `wsl --list --verbose`로 등록된 배포판이 없는 것을 확인했다. `wsl --install -d Ubuntu-24.04 --web-download --no-launch`로 Ubuntu를 설치한 뒤 `/etc/os-release`에서 버전을 확인했다.
2. **Windows 드라이브에 둔 파일의 Unix 권한이 바뀌지 않았다.** WSL 내부에서 `stat -f -c %T`로 확인하니 Windows 드라이브 파일은 `v9fs`였다. `chmod 600` 전후 `stat -c %a`의 결과가 모두 `777`이었다. 실습 파일을 Ubuntu 내부의 `/tmp`에 만들자 `600 → 644`와 `700 → 755`를 검증할 수 있었다.
3. **바인드 마운트 컨테이너를 시작한 직후 첫 HTTP 요청이 끊겼다.** 컨테이너 시작과 NGINX의 요청 수신 사이에 시간이 필요하다고 보고 같은 URL을 재시도했다. `curl --retry 6 --retry-all-errors`로 첫 응답을 기다린 뒤 변경 전후 내용이 모두 예상과 일치했다.
4. **실습이 끝난 뒤 Windows 브라우저에서 연결이 거절됐다.** WSL 실행을 끝낸 뒤 발생했으므로 WSL 인스턴스와 데몬이 살아 있는지 먼저 확인했다. WSL을 다시 시작하고 `systemctl start docker`와 `docker start e11-web`을 실행했다. WSL 세션을 열어 둔 상태로 접속하자 페이지가 표시됐다.
