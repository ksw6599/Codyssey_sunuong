# E1-1 수행 명령과 출력

2026년 11월 4일에 수집한 실행 기록을 코드블록으로 정리했다. 아래 출력의 임시 경로와 컨테이너 ID는 실행 시마다 달라진다.

## 터미널·권한·Docker 실습

기록의 +는 Bash가 출력한 실행 명령을 나타낸다. 포트 매핑은 두 URL의 HTTP 200, 바인드 마운트는 host version 1과 host version 2, 볼륨은 서로 다른 컨테이너에서 읽은 e11-volume-record로 검증했다.

```text
+ uname -sr
Linux 6.18.33.2-microsoft-standard-WSL2
+ cat /etc/os-release
PRETTY_NAME="Ubuntu 24.04.5 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
VERSION="24.04.5 LTS (Noble Numbat)"
VERSION_CODENAME=noble
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=noble
LOGO=ubuntu-logo
+ bash --version
+ sed -n 1p
GNU bash, version 5.2.21(1)-release (x86_64-pc-linux-gnu)
+ git --version
git version 2.43.0
+ cd /tmp/tmp.Y71vkepywD
+ pwd
/tmp/tmp.Y71vkepywD
+ mkdir practice
+ cd practice
+ printf '%s\n' 'E1-1 terminal practice'
+ touch .hidden empty.txt
+ ls -la
total 12
drwxr-xr-x 2 root root 4096 Nov  4 17:21 .
drwx------ 3 root root 4096 Nov  4 17:21 ..
-rw-r--r-- 1 root root    0 Nov  4 17:21 .hidden
-rw-r--r-- 1 root root    0 Nov  4 17:21 empty.txt
-rw-r--r-- 1 root root   23 Nov  4 17:21 notes.txt
+ cat notes.txt
E1-1 terminal practice
+ cp -v notes.txt copy.txt
'notes.txt' -> 'copy.txt'
+ mv -v copy.txt renamed.txt
renamed 'copy.txt' -> 'renamed.txt'
+ rm -v renamed.txt
removed 'renamed.txt'
+ wc -c empty.txt
0 empty.txt
+ mkdir shared
+ chmod 600 notes.txt
+ chmod 700 shared
+ stat -c '%a %A %n' notes.txt shared
600 -rw------- notes.txt
700 drwx------ shared
+ chmod 644 notes.txt
+ chmod 755 shared
+ stat -c '%a %A %n' notes.txt shared
644 -rw-r--r-- notes.txt
755 drwxr-xr-x shared
+ cd /mnt/c/Users/<USER>/Documents/Codex/codyssey-e1-1
+ docker --version
Docker version 29.9.3, build 5457199
+ docker info --format 'Server={{.ServerVersion}} OS={{.OperatingSystem}} Driver={{.Driver}}'
Server=29.9.3 OS=Ubuntu 24.04.5 LTS Driver=overlayfs
+ docker run --rm hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
4f55086f7dd0: Pulling fs layer
4f55086f7dd0: Download complete
4f55086f7dd0: Pull complete
d5e71e642bf5: Download complete
Digest: sha256:c567b231f65614688711a75f31518a064258a51d442117a3e771a3a8fdba78ef
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

+ docker pull ubuntu:24.04
24.04: Pulling from library/ubuntu
7a48b8f0e5c7: Pulling fs layer
7a48b8f0e5c7: Download complete
98144013299c: Download complete
7a48b8f0e5c7: Pull complete
Digest: sha256:fe81560990fae86dc4743202b2cb4d3df98d0bcf949173cecef15ce1127ef852
Status: Downloaded newer image for ubuntu:24.04
docker.io/library/ubuntu:24.04
+ docker run -dit --name e11-ubuntu ubuntu:24.04 bash
4369e59dcf4091c37c656863434ae779454a1ec82f63a16e3574fb79b9f89716
+ docker exec e11-ubuntu bash -c 'ls /; echo exec-finished'
bin
boot
dev
etc
home
lib
lib64
media
mnt
opt
proc
root
run
sbin
srv
sys
tmp
usr
var
exec-finished
+ docker inspect -f '{{.State.Status}}' e11-ubuntu
running
+ docker stop e11-ubuntu
e11-ubuntu
+ docker ps -a --filter name=e11-ubuntu
CONTAINER ID   IMAGE          COMMAND   CREATED          STATUS                                PORTS     NAMES
4369e59dcf40   ubuntu:24.04   "bash"    11 seconds ago   Exited (137) Less than a second ago             e11-ubuntu
+ docker rm e11-ubuntu
e11-ubuntu
+ docker run -di --name e11-attach ubuntu:24.04 bash
0c7d9e506cc6e4eaf4113aed3c241d13a60a2257ed0a17ca4be42e4332d07ad1
+ printf '%s\n' 'echo attached-to-main-shell' 'exit 0'
+ docker attach e11-attach
+ docker wait e11-attach
0
+ docker inspect -f '{{.State.Status}}' e11-attach
exited
+ docker rm e11-attach
e11-attach
+ docker build -t e11-workbench:1.0 .
#0 building with "default" instance using docker driver

#1 [internal] load build definition from Dockerfile
#1 transferring dockerfile: 151B 0.0s done
#1 DONE 0.1s

#2 [internal] load metadata for docker.io/library/nginx:alpine
#2 DONE 3.1s

#3 [internal] load .dockerignore
#3 transferring context: 68B 0.0s done
#3 DONE 0.1s

#4 [1/2] FROM docker.io/library/nginx:alpine@sha256:785835ea65db4bba6f021acc0f3be91b0fef76a53fe41f8588c6698d2aed0606
#4 resolve docker.io/library/nginx:alpine@sha256:785835ea65db4bba6f021acc0f3be91b0fef76a53fe41f8588c6698d2aed0606 0.1s done
#4 ...

#5 [internal] load build context
#5 transferring context: 852B 0.0s done
#5 DONE 0.1s

#4 [1/2] FROM docker.io/library/nginx:alpine@sha256:785835ea65db4bba6f021acc0f3be91b0fef76a53fe41f8588c6698d2aed0606
#4 DONE 0.4s

#4 [1/2] FROM docker.io/library/nginx:alpine@sha256:785835ea65db4bba6f021acc0f3be91b0fef76a53fe41f8588c6698d2aed0606
#4 sha256:b9b388a21ecfde6ac80505f23f527146a2129dfb104e79b029bbd00d4cc1a919 0B / 20.53MB 0.2s
#4 sha256:b9b388a21ecfde6ac80505f23f527146a2129dfb104e79b029bbd00d4cc1a919 5.24MB / 20.53MB 0.3s
#4 sha256:9b0f7dfe35b2711a17f60dadd6d4035dc0cdee152538cc5c0987029e94679548 0B / 1.40kB 0.2s
#4 sha256:2ec5fb117ffa9a78b15fb6a78745ffc569c8da0aee9f36ace4cd67a44b1fef79 0B / 1.21kB 0.2s
#4 sha256:26185d08a3ec318dd85a6c9f2172e714ec13cececd7f33c533b40b1689f9fedb 0B / 404B 0.2s
#4 sha256:b9b388a21ecfde6ac80505f23f527146a2129dfb104e79b029bbd00d4cc1a919 20.53MB / 20.53MB 0.5s
#4 sha256:b9b388a21ecfde6ac80505f23f527146a2129dfb104e79b029bbd00d4cc1a919 20.53MB / 20.53MB 0.5s done
#4 sha256:9b0f7dfe35b2711a17f60dadd6d4035dc0cdee152538cc5c0987029e94679548 1.40kB / 1.40kB 0.4s done
#4 sha256:2ec5fb117ffa9a78b15fb6a78745ffc569c8da0aee9f36ace4cd67a44b1fef79 1.21kB / 1.21kB 0.6s done
#4 sha256:26185d08a3ec318dd85a6c9f2172e714ec13cececd7f33c533b40b1689f9fedb 404B / 404B 0.7s done
#4 sha256:7cc330898115ce55acccb0cc1e7dd091df4410c8c5f3c540710ee0ac689f5fcb 964B / 964B 0.2s done
#4 sha256:657023555a2a19dc6036468198bb350d2c7feaac7f2d0a3901b4dd3cb25e40c5 0B / 629B 0.2s
#4 sha256:657023555a2a19dc6036468198bb350d2c7feaac7f2d0a3901b4dd3cb25e40c5 629B / 629B 0.3s done
#4 sha256:12b85cff06fd7d383d36a9c96503fe049c9d4bf3dfda5cbb9ffa6ae99b9c07a6 0B / 1.94MB 0.2s
#4 sha256:12b85cff06fd7d383d36a9c96503fe049c9d4bf3dfda5cbb9ffa6ae99b9c07a6 1.94MB / 1.94MB 0.3s done
#4 sha256:7b229517ed222597277036d94892173207d01a731ab3a88eeb1de2e963a2c788 3.85MB / 3.85MB 0.3s done
#4 extracting sha256:7b229517ed222597277036d94892173207d01a731ab3a88eeb1de2e963a2c788 0.1s done
#4 DONE 1.6s

#4 [1/2] FROM docker.io/library/nginx:alpine@sha256:785835ea65db4bba6f021acc0f3be91b0fef76a53fe41f8588c6698d2aed0606
#4 extracting sha256:12b85cff06fd7d383d36a9c96503fe049c9d4bf3dfda5cbb9ffa6ae99b9c07a6
#4 extracting sha256:12b85cff06fd7d383d36a9c96503fe049c9d4bf3dfda5cbb9ffa6ae99b9c07a6 0.2s done
#4 DONE 1.8s

#4 [1/2] FROM docker.io/library/nginx:alpine@sha256:785835ea65db4bba6f021acc0f3be91b0fef76a53fe41f8588c6698d2aed0606
#4 extracting sha256:657023555a2a19dc6036468198bb350d2c7feaac7f2d0a3901b4dd3cb25e40c5 0.0s done
#4 extracting sha256:7cc330898115ce55acccb0cc1e7dd091df4410c8c5f3c540710ee0ac689f5fcb 0.0s done
#4 extracting sha256:26185d08a3ec318dd85a6c9f2172e714ec13cececd7f33c533b40b1689f9fedb 0.0s done
#4 DONE 1.9s

#4 [1/2] FROM docker.io/library/nginx:alpine@sha256:785835ea65db4bba6f021acc0f3be91b0fef76a53fe41f8588c6698d2aed0606
#4 extracting sha256:2ec5fb117ffa9a78b15fb6a78745ffc569c8da0aee9f36ace4cd67a44b1fef79 0.0s done
#4 extracting sha256:9b0f7dfe35b2711a17f60dadd6d4035dc0cdee152538cc5c0987029e94679548 0.0s done
#4 extracting sha256:b9b388a21ecfde6ac80505f23f527146a2129dfb104e79b029bbd00d4cc1a919
#4 extracting sha256:b9b388a21ecfde6ac80505f23f527146a2129dfb104e79b029bbd00d4cc1a919 0.4s done
#4 DONE 2.4s

#6 [2/2] COPY app/ /usr/share/nginx/html/
#6 DONE 0.1s

#7 exporting to image
#7 exporting layers
#7 exporting layers 0.2s done
#7 exporting manifest sha256:9bbcf656dedf15b1223fccba2d44958609443ebfaa91df331bf04145426ef067 0.0s done
#7 exporting config sha256:a1276b901edc05e3091c9003690f6dfa5915b9b57f5b5edd493453ecaf49bca2 0.0s done
#7 exporting attestation manifest sha256:052cbdf57d16fb8684e3863ac7b45161be2d5f83bd636f3764eff948ad623973
#7 exporting attestation manifest sha256:052cbdf57d16fb8684e3863ac7b45161be2d5f83bd636f3764eff948ad623973 0.1s done
#7 exporting manifest list sha256:46375f4174c7c924eb65460a933726d3a5165bc2b616f076137123a1c7b755f9 0.0s done
#7 naming to docker.io/library/e11-workbench:1.0
#7 naming to docker.io/library/e11-workbench:1.0 done
#7 unpacking to docker.io/library/e11-workbench:1.0
#7 unpacking to docker.io/library/e11-workbench:1.0 1.1s done
#7 DONE 1.6s
+ docker images
IMAGE                ID             DISK USAGE   CONTENT SIZE   EXTRA
e11-workbench:1.0    46375f4174c7       93.6MB         26.3MB        
hello-world:latest   c567b231f656       25.9kB         9.49kB        
ubuntu:24.04         fe81560990fa        119MB         31.7MB        
+ docker run -d --name e11-web -p 127.0.0.1:8781:80 e11-workbench:1.0
46294fef6e5b21c94ffab74bfb7823fb95c845bcd675a6a8a2f236d0192c7a77
+ docker run -d --name e11-web-second -p 127.0.0.1:8782:80 e11-workbench:1.0
1a59a856d2448860c0c2a99e29d6739586cc81222186724106e922b72b810a7c
+ for port in 8781 8782
+ curl -fsS --retry 6 --retry-all-errors -D - http://127.0.0.1:8781/
+ sed -n '1p; /NGINX 응답 정상/p'
HTTP/1.1 200 OK
    <p class="status">NGINX 응답 정상</p>
+ for port in 8781 8782
+ curl -fsS --retry 6 --retry-all-errors -D - http://127.0.0.1:8782/
+ sed -n '1p; /NGINX 응답 정상/p'
HTTP/1.1 200 OK
    <p class="status">NGINX 응답 정상</p>
+ docker ps --filter name=e11-web
CONTAINER ID   IMAGE               COMMAND                  CREATED         STATUS                  PORTS                    NAMES
1a59a856d244   e11-workbench:1.0   "/docker-entrypoint.…"   1 second ago    Up Less than a second   127.0.0.1:8782->80/tcp   e11-web-second
46294fef6e5b   e11-workbench:1.0   "/docker-entrypoint.…"   2 seconds ago   Up Less than a second   127.0.0.1:8781->80/tcp   e11-web
+ docker logs --tail 5 e11-web
2026/11/04 08:21:50 [notice] 1#1: start worker process 38
2026/11/04 08:21:50 [notice] 1#1: start worker process 39
2026/11/04 08:21:50 [notice] 1#1: start worker process 40
2026/11/04 08:21:50 [notice] 1#1: start worker process 41
172.17.0.1 - - [04/Nov/2026:08:21:50 +0000] "GET / HTTP/1.1" 200 782 "-" "curl/8.5.0" "-"
+ docker stats --no-stream e11-web e11-web-second
CONTAINER ID   NAME             CPU %     MEM USAGE / LIMIT     MEM %     NET I/O           BLOCK I/O     PIDS
46294fef6e5b   e11-web          0.00%     11.1MiB / 15.16GiB    0.07%     1.49kB / 1.53kB   0B / 12.3kB   13
1a59a856d244   e11-web-second   0.00%     11.75MiB / 15.16GiB   0.08%     981B / 1.48kB     0B / 8.19kB   13
+ docker stop e11-web-second
e11-web-second
+ docker ps -a --filter name=e11-web-second
CONTAINER ID   IMAGE               COMMAND                  CREATED         STATUS                              PORTS     NAMES
1a59a856d244   e11-workbench:1.0   "/docker-entrypoint.…"   4 seconds ago   Exited (0) Less than a second ago             e11-web-second
+ docker rm e11-web-second
e11-web-second
+ mkdir /tmp/tmp.Y71vkepywD/bind
+ printf '%s\n' 'host version 1'
+ docker run -d --name e11-bind -p 127.0.0.1:8782:80 --mount type=bind,source=/tmp/tmp.Y71vkepywD/bind,target=/usr/share/nginx/html,readonly e11-workbench:1.0
41dfcf7b0433f7589957b606dd6f51f56bf7188bbb100676c71989591c23e4d5
++ curl -fsS --retry 6 --retry-all-errors http://127.0.0.1:8782/
curl: (56) Recv failure: Connection reset by peer
+ before='host version 1'
+ printf '%s\n' 'host version 1'
host version 1
+ test 'host version 1' = 'host version 1'
+ printf '%s\n' 'host version 2'
++ curl -fsS http://127.0.0.1:8782/
+ after='host version 2'
+ printf '%s\n' 'host version 2'
host version 2
+ test 'host version 2' = 'host version 2'
+ docker stop e11-bind
e11-bind
+ docker rm e11-bind
e11-bind
++ docker volume create
+ volume=62381bc2c4a3efb888f75db1256c6d8b8b9369e6f56ac0387e28e371edba0ac0
+ docker run --name e11-volume-writer -v 62381bc2c4a3efb888f75db1256c6d8b8b9369e6f56ac0387e28e371edba0ac0:/data ubuntu:24.04 bash -c 'echo e11-volume-record > /data/check.txt; cat /data/check.txt'
e11-volume-record
+ docker rm e11-volume-writer
e11-volume-writer
++ docker run --rm -v 62381bc2c4a3efb888f75db1256c6d8b8b9369e6f56ac0387e28e371edba0ac0:/data:ro ubuntu:24.04 cat /data/check.txt
+ persisted=e11-volume-record
+ printf '%s\n' e11-volume-record
e11-volume-record
+ test e11-volume-record = e11-volume-record
+ docker volume rm 62381bc2c4a3efb888f75db1256c6d8b8b9369e6f56ac0387e28e371edba0ac0
62381bc2c4a3efb888f75db1256c6d8b8b9369e6f56ac0387e28e371edba0ac0
+ set +x
All checks passed. Web server: http://127.0.0.1:8781/
```

## Windows에서 호스트 포트 접속

아래 명령은 Windows에서 실행한 HTTP 요청이다. 응답은 Docker의 NGINX 컨테이너가 반환했다.

```text
PS> curl.exe -fsS -i http://127.0.0.1:8781/
HTTP/1.1 200 OK
Server: nginx/1.31.8
Date: Wed, 04 Nov 2026 08:24:46 GMT
Content-Type: text/html
Content-Length: 782
Last-Modified: Wed, 04 Nov 2026 08:20:59 GMT
Connection: keep-alive
ETag: "6aeaeaeb-30e"
Accept-Ranges: bytes

<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Codyssey E1-1 개발 작업실</title>
  <style>
    body { margin: 0; min-height: 100vh; display: grid; place-items: center;
      background: #101d2e; color: #eff6ff; font-family: system-ui, sans-serif; }
    main { margin: 1.5rem; padding: 2rem; max-width: 32rem;
      background: #192c44; border: 1px solid #527294; border-radius: 1rem; }
    .status { color: #a2f4d3; }
  </style>
</head>
<body>
  <main>
    <p>CODYSSEY / E1-1</p>
    <h1>개발 작업실</h1>
    <p class="status">NGINX 응답 정상</p>
    <p>Docker 이미지에 포함된 정적 페이지를 호스트에서 확인했습니다.</p>
  </main>
</body>
</html>
```

## Git 설정과 원격 저장소 연결

초기 설정 때 수집한 로그다. 커밋 작성자 이메일은 GitHub의 공개 noreply 주소를 사용했다.

```text
$ git --version
git version 2.56.0.windows.4

$ git config --local --list
core.repositoryformatversion=0
core.filemode=false
core.bare=false
core.logallrefupdates=true
core.symlinks=false
core.ignorecase=true
user.name=ksw6599
user.email=91269255+ksw6599@users.noreply.github.com
init.defaultbranch=main
remote.origin.url=https://github.com/ksw6599/Codyssey_sunuong.git
remote.origin.fetch=+refs/heads/*:refs/remotes/origin/*

$ git remote -v
origin	https://github.com/ksw6599/Codyssey_sunuong.git (fetch)
origin	https://github.com/ksw6599/Codyssey_sunuong.git (push)

$ git log -1 --oneline origin/main
f7245a1 Initial commit
```

## 문서 보완 전 저장소 상태

다음은 이번 보완 작업 중 확인한 원격 커밋이다. GitHub 업로드는 연결된 GitHub 도구로 수행했다. VS Code 내부의 계정 로그인은 별도로 확인해야 한다.

```text
$ git status --short --branch
## main...origin/main
 M README.md

$ git log -1 --oneline
6cd1437 Complete Codyssey E1-1 development workstation exercise

$ git ls-remote origin refs/heads/main
6cd14372562f12e180d5d6407d671094f0d5d3e2	refs/heads/main
```

## 시각적 증거 수집 상태

- 웹 접속은 HTTP 응답으로 검증했다. 주소창이 포함된 스크린샷은 아직 수집하지 못했다.
- VS Code의 GitHub 계정 로그인과 해당 저장소 연동 화면은 아직 확인하지 못했다.
